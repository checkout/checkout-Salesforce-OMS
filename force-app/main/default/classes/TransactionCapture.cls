/**
 * @description       : Prepare capture payment Checkout
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-24-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-10-2021   roberto.ehlert@osf.digital   Initial Version
 * 1.1   03-24-2021   roberto.ehlert@osf.digital   Added Klarna RequestType
 **/

public with sharing class TransactionCapture extends BaseRequest {
  public Double amount;
  public String gatewayRefNumber;
  public String paymentType;
  public OrderSummary orderSummaryObj;
  private Klarna_Setting__mdt klarnaSettings;

  public TransactionCapture() {
  }

  public override HttpRequest getRequest() {
    Enums.CheckoutRequestType enumType = paymentType.equalsIgnoreCase(
        Enums.PaymentMethod.KLARNA.name()
      )
      ? Enums.CheckoutRequestType.KLARNA_CAPTURE
      : Enums.CheckoutRequestType.CAPTURE;

    klarnaSettings = paymentType.equalsIgnoreCase(
        Enums.PaymentMethod.KLARNA.name()
      )
      ? CheckoutPaymentConfigQuery.getKlarnaSettings()
      : null;

    String relativeUrl = DomainConstants.getCheckoutUrl(enumType);
    String bodyContent = setBodyContent(
      enumType,
      amount,
      orderSummaryObj.OrderNumber
    );

    String uri = String.format(
      relativeUrl,
      new List<String>{ gatewayRefNumber }
    );

    if (paymentType.equalsIgnoreCase(Enums.PaymentMethod.KLARNA.name())) {
      if (
        Constants.PRODUCTION_ENVIRONMENT.equalsIgnoreCase(
          klarnaSettings.Environment__c
        )
      ) {
        // For production 'klarna' is used, for sandbox 'klarna-external'
        // By default 'klarna-external' is set in DomainConstants
        // Checkout documentation: https://docs.checkout.com/payments/payment-methods/invoice-and-pay-later/klarna#Klarna-Capturethepaymentcapturepayment
        uri = uri.replace(Constants.KLARNA_EXTERNAL, Constants.KLARNA);
      }
    }

    String secretKey = CheckoutPaymentConfigQuery.getSecretKey();

    return CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_POST,
      uri,
      bodyContent,
      secretKey
    );
  }

  public String setBodyContent(
    Enums.CheckoutRequestType requestType,
    Double amount,
    String orderNumber
  ) {
    TransactionBody body = TransactionBody.getInstance();
    String bodyContent = body.getBody(amount, orderNumber);
    //Klarna capture requests an klarna json object;
    switch on requestType {
      when KLARNA_CAPTURE {
        bodyContent = new TransactionCaptureKlarnaGetBody()
          .getBody(klarnaSettings, orderSummaryObj.Id, orderNumber, amount);
      }
    }
    return bodyContent;
  }
}
