/**
 * @description       : Batchble class, that updates the status of the paymentes
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-29-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-29-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class Webhooksfallback_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
  private String secretKey;

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Utils.validateFieldSecurity(
        Payment.class.getName(),
        new List<String>{
          'GatewayRefNumber',
          'Status',
          'OrderPaymentSummaryId',
          'PaymentGatewayId'
        },
        Constants.IS_ACCESSIBLE
      )
      ? Database.getQueryLocator(
          'SELECT Id, GatewayRefNumber, Status, OrderPaymentSummaryId, PaymentGatewayId FROM Payment WHERE Status = \'Pending\' '
        )
      : null;
  }

  public void execute(Database.BatchableContext bc, List<Payment> scope) {
    List<Payment> paymentsToUpdate = new List<Payment>();
    List<PaymentGatewayLog> gatewayLogs = new List<PaymentGatewayLog>();
    List<Exception> exceptionLogs = new List<Exception>();

    PaymentDetails paymentData;
    secretKey = CheckoutPaymentConfigQuery.getSecretKey();

    for (Payment paymentRecord : scope) {
      if (String.isNotBlank(paymentRecord.GatewayRefNumber)) {
        try {
          HttpRequest request = getPaymentRequest(
            secretKey,
            paymentRecord.GatewayRefNumber
          );
          HttpResponse response = new http().send(request);

          if (response.getStatusCode() == 200) {
            paymentData = (PaymentDetails) JSON.deserialize(
              response.getBody(),
              PaymentDetails.class
            );
          }

          if (
            Utils.validateFieldSecurity(
              PaymentGatewayLog.class.getName(),
              new List<String>{
                'ReferencedEntityId',
                'OrderPaymentSummaryId',
                'PaymentGatewayId',
                'GatewayRefNumber',
                'GatewayResultCode',
                'GatewayResultCodeDescription',
                'Request',
                'Response',
                'Status',
                'InteractionType',
                'GatewayDate'
              },
              Constants.IS_CREATEABLE
            )
          ) {
            PaymentGatewayLog gatewayLog = new PaymentGatewayLog();
            gatewayLog.ReferencedEntityId = paymentRecord.Id;
            gatewayLog.OrderPaymentSummaryId = paymentRecord.OrderPaymentSummaryId;
            gatewayLog.PaymentGatewayId = paymentRecord.PaymentGatewayId;
            gatewayLog.GatewayRefNumber = paymentRecord.GatewayRefNumber;
            gatewayLog.GatewayResultCode = String.valueOf(
              response.getStatusCode()
            );
            gatewayLog.GatewayResultCodeDescription = response.getStatus();
            gatewayLog.Request =
              'Endpoint: ' +
              request.getEndpoint() +
              ', Body: ' +
              request.getBody();
            gatewayLog.Response = response.getBody();
            gatewayLog.InteractionStatus = 'Success';
            gatewayLog.InteractionType = 'Capture';
            gatewayLog.GatewayDate = Datetime.now();

            gatewayLogs.add(gatewayLog);
          }

          if (
            paymentData != null &&
            String.isNotBlank(paymentData.status) &&
            paymentData.status.equalsIgnoreCase(
              Enums.PaymentStatus.CAPTURED.name()
            ) &&
            Utils.validateFieldSecurity(
              Payment.class.getName(),
              new List<String>{ 'Status' },
              Constants.IS_UPDATEABLE
            )
          ) {
            paymentRecord.Status = Enums.PaymentStatus.PROCESSED.name();
            paymentsToUpdate.add(paymentRecord);
          }
        } catch (Exception e) {
          exceptionLogs.add(e);
        }
      }
    }

    if (
      !paymentsToUpdate.isEmpty() &&
      Utils.validateObjectSecurity(
        Payment.class.getName(),
        Constants.IS_UPDATEABLE
      )
    ) {
      update paymentsToUpdate;
    }

    if (
      !gatewayLogs.isEmpty() &&
      Utils.validateObjectSecurity(
        PaymentGatewayLog.class.getName(),
        Constants.IS_CREATEABLE
      )
    ) {
      insert gatewayLogs;
    }

    if (!exceptionLogs.isEmpty()) {
      new CustomException().log(exceptionLogs);
    }
  }

  public void finish(Database.BatchableContext bc) {
  }

  private HttpRequest getPaymentRequest(
    String secretKey,
    String gatewayRefNumber
  ) {
    String relativeUrl = DomainConstants.getCheckoutUrl(
      Enums.CheckoutRequestType.GET_DETAILS_WEBHOOK
    );

    String uri = String.format(
      relativeUrl,
      new List<String>{ gatewayRefNumber }
    );

    return CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_GET,
      uri,
      null,
      secretKey
    );
  }
}
