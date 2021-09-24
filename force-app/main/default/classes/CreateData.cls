/**
 * @description       : Class used for creating data for unit tests
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 06-05-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0  06-05-2021   roberto.ehlerto@osf.digital   Initial Version
 **/
@isTest
public with sharing class CreateData {
  private static final String GATEWAY_REFERENCE_NUMBER = '999999';

  public static String initializeAndReturnPaymentAuthorization() {
    Id pricebookId = Test.getStandardPricebookId();
    Account accountA = createTestAccount();
    SalesChannel salesChannel = createTestSalesChannel();
    Order orderRecord = createTestOrder(accountA, salesChannel, pricebookId);
    PaymentGroup paymentGroupRecord = createTestPaymentGroup(orderRecord);
    AlternativePaymentMethod paymentMethod = createTestAlternativePaymentMethod(
      accountA,
      'klarna'
    );
    PaymentAuthorization paymentAuthorization = createTestPaymentAuthorization(
      paymentGroupRecord,
      paymentMethod
    );
    createTestPayment(paymentAuthorization);
    Product2 product2 = createTestProduct2();
    OrderDeliveryMethod orderDeliveryMethod = createTestOrderDeliveryMethod(
      product2
    );
    OrderDeliveryGroup deliveryGroup = createTestOrderDeliveryGroup(
      orderDeliveryMethod,
      orderRecord
    );

    PricebookEntry pricebookEntry = createTestPricebookEntry(
      pricebookId,
      product2
    );
    createTestOrderItems(orderRecord, pricebookEntry, deliveryGroup);

    String orderSummaryId = createTestSummaryOrderId(orderRecord);
    createTestShipment(orderSummaryId);

    return paymentAuthorization.Id;
  }

  public static Account createTestAccount() {
    Account accountA = new Account(Name = 'Test');
    insert accountA;
    return accountA;
  }

  public static SalesChannel createTestSalesChannel() {
    SalesChannel salesChanelRecord = new SalesChannel();
    salesChanelRecord = new SalesChannel();
    salesChanelRecord.SalesChannelName = 'Test';
    salesChanelRecord.Description = 'Test';
    salesChanelRecord.ExternalChannelNumber = 'test';

    insert salesChanelRecord;
    return salesChanelRecord;
  }

  public static Order createTestOrder(
    Account accountA,
    Saleschannel salesChannel,
    Id pricebookId
  ) {
    Order orderRecord = new Order();
    orderRecord.AccountId = accountA.Id;
    orderRecord.EffectiveDate = System.today();
    orderRecord.Status = 'Draft';
    orderRecord.Pricebook2Id = pricebookId;
    orderRecord.SalesChannelId = salesChannel.Id;
    orderRecord.BillingStreet = '1166 W Newport Center Dr';
    orderRecord.BillingCity = 'Deerfield Beach';
    orderRecord.BillingState = 'AR';
    orderRecord.BillingPostalCode = '33442';
    orderRecord.BillingCountry = 'usa';
    orderRecord.BillingPhoneNumber = '3333333333';
    orderRecord.BillingEmailAddress = 'test@argentina.com';
    orderRecord.BillingState = 'AR';

    insert orderRecord;
    return orderRecord;
  }

  public static PaymentGroup createTestPaymentGroup(Order orderRecord) {
    PaymentGroup paymentGroupRecord = new PaymentGroup();
    paymentGroupRecord.SourceObjectId = orderRecord.Id;

    insert paymentGroupRecord;
    return paymentGroupRecord;
  }

  public static AlternativePaymentMethod createTestAlternativePaymentMethod(
    Account accountA,
    String nickName
  ) {
    AlternativePaymentMethod paymentMethod = new AlternativePaymentMethod();
    paymentMethod.AccountId = accountA.Id;
    paymentMethod.ProcessingMode = Enums.ProcessingMode.EXTERNAL.name();
    paymentMethod.NickName = nickName;
    paymentMethod.Status = 'Active';

    insert paymentMethod;
    return paymentMethod;
  }

  public static PaymentAuthorization createTestPaymentAuthorization(
    PaymentGroup paymentGroupRecord,
    AlternativePaymentMethod paymentMethod
  ) {
    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 15.5,
      GatewayRefNumber = GATEWAY_REFERENCE_NUMBER,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL',
      PaymentGroupId = paymentGroupRecord.Id,
      PaymentMethodId = paymentMethod.Id
    );
    insert paymentAuthorization;
    return paymentAuthorization;
  }

  public static Payment createTestPayment(
    PaymentAuthorization paymentAuthorization
  ) {
    Payment payment = new Payment();
    payment.PaymentAuthorizationId = paymentAuthorization.Id;
    payment.EffectiveDate = Datetime.now();
    payment.Type = Enums.PaymentType.CAPTURE.name();
    payment.Amount = (Double) 15.5;
    payment.Status = Enums.PaymentStatus.Processed.name();
    payment.ProcessingMode = Enums.ProcessingMode.EXTERNAL.name();
    payment.GatewayRefNumber = GATEWAY_REFERENCE_NUMBER;

    insert Payment;
    return payment;
  }

  public static Product2 createTestProduct2() {
    Product2 product2 = new Product2();
    product2.Name = 'Test';
    product2.Description = 'Test';
    product2.IsActive = true;
    product2.ProductCode = '12314';

    insert product2;
    return product2;
  }

  public static OrderDeliveryMethod createTestOrderDeliveryMethod(
    Product2 product2
  ) {
    OrderDeliveryMethod deliveryMethod = new OrderDeliveryMethod();
    deliveryMethod.IsActive = true;
    deliveryMethod.Name = 'Fedex';
    deliveryMethod.ReferenceNumber = '001';
    deliveryMethod.ProductId = product2.Id;

    insert deliveryMethod;
    return deliveryMethod;
  }

  public static OrderDeliveryGroup createTestOrderDeliveryGroup(
    OrderDeliveryMethod deliveryMethod,
    Order orderRecord
  ) {
    OrderDeliveryGroup deliveryGroup = new OrderDeliveryGroup();

    deliveryGroup.EmailAddress = 'test@argentina.com';
    deliveryGroup.OrderId = orderRecord.Id;
    deliveryGroup.DeliverToName = 'Test';
    deliveryGroup.DeliverToCity = 'Deerfield Beach';
    deliveryGroup.DeliverToCountry = 'us';
    deliveryGroup.DeliverToState = 'AR';
    deliveryGroup.DeliverToStreet = '1166 W Newport Center Dr';
    deliveryGroup.PhoneNumber = '3333333333';
    deliveryGroup.DeliverToPostalCode = '33442';
    deliveryGroup.OrderDeliveryMethodId = deliveryMethod.Id;

    insert deliveryGroup;
    return deliveryGroup;
  }

  public static PricebookEntry createTestPricebookEntry(
    Id pricebookId,
    Product2 product2
  ) {
    PricebookEntry pricebookEntry = new PricebookEntry();

    pricebookEntry.Pricebook2Id = pricebookId;
    pricebookEntry.UnitPrice = 15.5;
    pricebookEntry.Product2Id = product2.Id;

    insert pricebookEntry;
    return pricebookEntry;
  }

  public static void createTestOrderItems(
    Order orderRecord,
    PricebookEntry pricebookEntry,
    OrderDeliveryGroup deliveryGroup
  ) {
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(
      new OrderItem(
        Description = 'test',
        Type = 'Order Product',
        UnitPrice = (Double) 15.5,
        Quantity = 1,
        OrderId = orderRecord.Id,
        PricebookEntryId = pricebookEntry.Id,
        LineNumber = 1000,
        TotalLineAmount = (Double) 15.5,
        OrderDeliveryGroupId = deliveryGroup.Id
      )
    );

    orderItems.add(
      new OrderItem(
        Description = 'test2',
        Type = 'Order Product',
        UnitPrice = (Double) 25.5,
        Quantity = 1,
        OrderId = orderRecord.Id,
        PricebookEntryId = pricebookEntry.Id,
        LineNumber = 1000,
        TotalLineAmount = (Double) 25.5,
        OrderDeliveryGroupId = deliveryGroup.Id
      )
    );

    insert orderItems;

    orderRecord.Status = 'Activated';
    update orderRecord;
  }

  public static String createTestSummaryOrderId(Order orderRecord) {
    String orderSummaryId;
    List<OrderSummary> orderSummary = [
      SELECT Id
      FROM OrderSummary
      WHERE OriginalOrderId = :orderRecord.Id
      LIMIT 1
    ];

    if (orderSummary.isEmpty()) {
      ConnectApi.OrderSummaryInputRepresentation orderSummaryInput = new ConnectApi.OrderSummaryInputRepresentation();
      orderSummaryInput.orderId = orderRecord.Id;

      ConnectApi.OrderSummaryOutputRepresentation summOut = ConnectApi.OrderSummaryCreation.createOrderSummary(
        orderSummaryInput
      );
      orderSummaryId = summOut.orderSummaryId;
    } else {
      orderSummaryId = orderSummary[0].Id;
    }

    return orderSummaryId;
  }

  public static Shipment createTestShipment(String orderSummaryId) {
    Shipment shipment = new Shipment(
      ShipToName = 'Test',
      TrackingNumber = '1234',
      TrackingUrl = 'www.osf.com',
      orderSummaryId = orderSummaryId
    );
    insert shipment;
    return shipment;
  }

  public static ConnectApi.OrderSummaryOutputRepresentation createOrderSummaryOutput() {
    Account acc = createTestAccount();
    Order order = new Order(AccountId = acc.Id);
    insert order;

    ConnectApi.OrderSummaryInputRepresentation orderSummaryInput = new ConnectApi.OrderSummaryInputRepresentation();
    orderSummaryInput.orderId = order.Id;
    return ConnectApi.OrderSummaryCreation.createOrderSummary(
      orderSummaryInput
    );
  }
}
