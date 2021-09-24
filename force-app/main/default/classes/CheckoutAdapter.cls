/**
 * @description       : Process payment requests for checkout
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-22-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-05-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class CheckoutAdapter implements commercepayments.PaymentGatewayAsyncAdapter, commercepayments.PaymentGatewayAdapter {
  private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO = new commercepayments.SalesforceResultCodeInfo(
    commercepayments.SalesforceResultCode.Success
  );
  private static final commercepayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO = new commercepayments.SalesforceResultCodeInfo(
    commercepayments.SalesforceResultCode.Decline
  );

  //The payment platform receives a API request, which the adapter will do the evalutation.
  public commercepayments.GatewayResponse processRequest(
    commercepayments.paymentGatewayContext gatewayContext
  ) {
    commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
    commercepayments.GatewayResponse response;

    try {
      if (requestType == commercepayments.RequestType.Capture) {
        response = createCaptureResponse(
          (commercepayments.CaptureRequest) gatewayContext.getPaymentRequest()
        );
      } else if (requestType == commercepayments.RequestType.ReferencedRefund) {
        response = createRefundResponse(
          (commercepayments.ReferencedRefundRequest) gatewayContext.getPaymentRequest()
        );
      }
      return response;
    } catch (SalesforceValidationException e) {
      return new commercepayments.GatewayErrorResponse('400', e.getMessage());
    }
  }

  public commercepayments.GatewayResponse createCaptureResponse(
    commercepayments.CaptureRequest captureRequest
  ) {
    commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();

    if (captureRequest.amount != null) {
      captureResponse.setAmount(captureRequest.amount);
    } else {
      throw new SalesforceValidationException(
        Constants.REQUIRED_FIELD_MISSING_AMOUNT
      );
    }

    PaymentAuthorizationQuery paymentAuthorizationQuery = new PaymentAuthorizationQuery();
    PaymentAuthorization paymentAuthorization = paymentAuthorizationQuery.loadById(
      captureRequest.paymentAuthorizationId
    );

    //Check if the payment is already captured before initiate the capture transaction.
    TransactionGetPayment getPayment = new TransactionGetPayment();
    getPayment.paymentRefId = paymentAuthorization.GatewayRefNumber;

    commercepayments.PaymentsHttp paymentDetailsRequest = new commercepayments.PaymentsHttp();
    HttpResponse responsePayment = paymentDetailsRequest.send(
      getPayment.getRequest()
    );

    if (
      !String.isBlank(responsePayment.getBody()) &&
      isValidStatusCode(responsePayment.getStatusCode())
    ) {
      PaymentDetails paymentDetailsObj = (PaymentDetails) System.JSON.deserialize(
        responsePayment.getBody(),
        PaymentDetails.class
      );

      if (
        paymentDetailsObj.status.equalsIgnoreCase(
          Enums.PaymentStatus.CAPTURED.name()
        )
      ) {
        captureResponse.setSalesforceResultCodeInfo(
          SUCCESS_SALESFORCE_RESULT_CODE_INFO
        );
        captureResponse.setAmount(paymentDetailsObj.getAmount());
        captureResponse.setGatewayDate(system.now());
        captureResponse.setGatewayReferenceNumber(
          paymentAuthorization.GatewayRefNumber
        );

        captureResponse.setGatewayResultCode(
          String.valueOf(responsePayment.getStatusCode())
        );
        captureResponse.setGatewayResultCodeDescription(
          responsePayment.getStatus()
        );

        return captureResponse;
      } else {
        // The payment is not captured in Checkout hub, try to do the capture
        return doTransactionCapture(
          captureResponse,
          captureRequest,
          paymentAuthorization,
          paymentDetailsObj.source.type
        );
      }
    } else {
      // Set the details from get payment request
      captureResponse.setSalesforceResultCodeInfo(
        DECLINE_SALESFORCE_RESULT_CODE_INFO
      );
      captureResponse.setGatewayDate(system.now());
      captureResponse.setGatewayReferenceNumber(
        paymentAuthorization.GatewayRefNumber
      );

      captureResponse.setGatewayResultCode(
        String.valueOf(responsePayment.getStatusCode())
      );
      captureResponse.setGatewayResultCodeDescription(
        responsePayment.getStatus()
      );

      return captureResponse;
    }
  }

  public commercepayments.GatewayResponse createRefundResponse(
    commercepayments.ReferencedRefundRequest refundRequest
  ) {
    TransactionRefund refundTransaction = new TransactionRefund();
    commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();

    refundTransaction.paymentId = refundRequest.paymentId;
    refundTransaction.amount = refundRequest.amount;

    commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
    HttpResponse res = http.send(refundTransaction.getRequest());

    if (res != null) {
      if (isValidStatusCode(res.getStatusCode())) {
        refundResponse.setSalesforceResultCodeInfo(
          SUCCESS_SALESFORCE_RESULT_CODE_INFO
        );
        refundResponse.setAsync(true);
      } else {
        refundResponse.setSalesforceResultCodeInfo(
          DECLINE_SALESFORCE_RESULT_CODE_INFO
        );
      }

      refundResponse.setGatewayDate(system.now());

      Payment payment = new PaymentQuery().loadById(refundRequest.paymentId);
      refundResponse.setGatewayReferenceNumber(payment.GatewayRefNumber);
      refundResponse.setGatewayResultCode(String.valueOf(res.getStatusCode()));
      refundResponse.setGatewayResultCodeDescription(res.getStatus());
    }

    return refundResponse;
  }

  public commercepayments.GatewayNotificationResponse processNotification(
    commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext
  ) {
    commercepayments.PaymentGatewayNotificationRequest notificationRequest = gatewayNotificationContext.getPaymentGatewayNotificationRequest();

    commercepayments.NotificationSaveResult saveResult = commercepayments.NotificationClient.record(
      processNotificationResponse(notificationRequest.getRequestBody())
    );
    commercepayments.GatewayNotificationResponse gatewayResponse = new commercepayments.GatewayNotificationResponse();

    if (saveResult.isSuccess()) {
      gatewayResponse.setStatusCode(200);
      gatewayResponse.setResponseBody(Blob.valueOf('[OK]'));
    } else {
      gatewayResponse.setStatusCode(500);
      gatewayResponse.setResponseBody(
        Blob.valueOf(saveResult.getErrorMessage())
      );
    }

    return gatewayResponse;
  }

  @TestVisible
  private commercepayments.GatewayResponse doTransactionCapture(
    commercepayments.CaptureResponse captureResponse,
    commercepayments.CaptureRequest captureRequest,
    PaymentAuthorization paymentAuthorization,
    String paymentType
  ) {
    TransactionCapture transactionCapture = new TransactionCapture();
    transactionCapture.amount = captureRequest.amount;
    transactionCapture.gatewayRefNumber = paymentAuthorization.GatewayRefNumber;
    transactionCapture.paymentType = paymentType;
    TransactionCapture.orderSummaryObj = paymentAuthorization.OrderPaymentSummary.OrderSummary;

    commercepayments.PaymentsHttp requestCapture = new commercepayments.PaymentsHttp();
    HttpResponse httpResponseCapture = requestCapture.send(
      transactionCapture.getRequest()
    );

    if (httpResponseCapture != null) {
      if (isValidStatusCode(httpResponseCapture.getStatusCode())) {
        captureResponse.setSalesforceResultCodeInfo(
          SUCCESS_SALESFORCE_RESULT_CODE_INFO
        );
        captureResponse.setAsync(true);
      } else {
        captureResponse.setSalesforceResultCodeInfo(
          DECLINE_SALESFORCE_RESULT_CODE_INFO
        );
      }

      captureResponse.setGatewayResultCode(
        String.valueOf(httpResponseCapture.getStatusCode())
      );
      captureResponse.setGatewayResultCodeDescription(
        httpResponseCapture.getStatus()
      );
    } else {
      captureResponse.setSalesforceResultCodeInfo(
        DECLINE_SALESFORCE_RESULT_CODE_INFO
      );
    }

    captureResponse.setGatewayReferenceNumber(
      paymentAuthorization.GatewayRefNumber
    );
    captureResponse.setGatewayDate(system.now());

    return captureResponse;
  }

  @testVisible
  private commercepayments.BaseNotification processNotificationResponse(
    Blob request
  ) {
    commercepayments.BaseNotification notification = null;

    WebhookResponse webhookInformation = (WebhookResponse) JSON.deserialize(
      request.toString(),
      WebhookResponse.class
    );

    if (
      webhookInformation.type == Enums.WebhookRequestType.PAYMENT_CAPTURED ||
      webhookInformation.type ==
      Enums.WebhookRequestType.PAYMENT_CAPTURE_DECLINED
    ) {
      notification = new commercepayments.CaptureNotification();
    } else if (
      webhookInformation.type == Enums.WebhookRequestType.PAYMENT_REFUNDED ||
      webhookInformation.type ==
      Enums.WebhookRequestType.PAYMENT_REFUND_DECLINED
    ) {
      notification = new commercepayments.ReferencedRefundNotification();
    }

    notification.setAmount(webhookInformation.data.getAmount());

    commercepayments.NotificationStatus notificationStatus = webhookInformation.type.name()
        .contains('DECLINED')
      ? commercepayments.NotificationStatus.Failed
      : commercepayments.NotificationStatus.Success;

    notification.setStatus(notificationStatus);
    notification.setGatewayReferenceNumber(webhookInformation.data.id);
    notification.setGatewayDate(system.now());

    return notification;
  }

  private Boolean isValidStatusCode(Integer statusCode) {
    return statusCode >= 200 && statusCode <= 299;
  }
}