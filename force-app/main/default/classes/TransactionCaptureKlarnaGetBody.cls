public with sharing class TransactionCaptureKlarnaGetBody {
  List<Shipment> shippingItems;
  List<OrderItemSummary> orderItems;

  private List<KlarnaDetails.ShippingInfo> shippingInfos;
  private List<KlarnaDetails.Products> productsList;

  public String getBody(
    Klarna_Setting__mdt klarnaSettings,
    String orderSummaryId,
    String reference,
    Double amount
  ) {
    KlarnaDetails klarnaDetails = new KlarnaDetails();
    klarnaDetails.klarna = new KlarnaDetails.Klarna();

    if (klarnaSettings.checkoutcom__Include_Description__c) {
      klarnaDetails.klarna.description = klarnaSettings.checkoutcom__Description_Details__c;
    }

    if (klarnaSettings.checkoutcom__Include_Products__c) {
      orderItems = new OrderItemSummaryQuery()
        .loadByOrderSummaryId(orderSummaryId);

      if (orderItems != null) {
        klarnaDetails.klarna.products = productsBuilder(orderItems);
      }
    }

    if (klarnaSettings.checkoutcom__Include_Shipping_Info__c) {
      shippingItems = new ShipmentQuery().loadByOrderSummaryId(orderSummaryId);

      if (shippingItems != null) {
        klarnaDetails.klarna.shipping_info = shippingInfoBuilder(shippingItems);
      }
    }

    if (klarnaSettings.checkoutcom__Include_Shipping_Delay__c) {
      klarnaDetails.klarna.shipping_delay = Integer.valueOf(
        klarnaSettings.checkoutcom__Shipping_Delay_Value__c
      );
    }

    klarnaDetails.type = 'klarna';
    klarnaDetails.reference = reference;
    klarnaDetails.amount = Integer.valueOf(amount * 100);

    return JSON.serialize(klarnaDetails);
  }

  private List<KlarnaDetails.Products> productsBuilder(
    List<OrderItemSummary> orderItemSummaryList
  ) {
    productsList = new List<KlarnaDetails.Products>();
    for (OrderItemSummary orderItemSummary : orderItemSummaryList) {
      productsList.add(
        new KlarnaDetails.Products(
          orderItemSummary.name,
          Integer.valueOf(orderItemSummary.Quantity),
          setIntegerAmounts(orderItemSummary.UnitPrice),
          setIntegerAmounts(orderItemSummary.TotalLineTaxAmount),
          setIntegerAmounts(orderItemSummary.TotalPrice),
          setIntegerAmounts(orderItemSummary.TotalTaxAmount)
        )
      );
    }

    return productsList;
  }

  private Integer setIntegerAmounts(Decimal amount) {
    return Integer.valueOf(amount * 100);
  }

  private List<KlarnaDetails.ShippingInfo> shippingInfoBuilder(
    List<Shipment> shippingItems
  ) {
    for (Shipment shipment : shippingItems) {
      shippingInfos = new List<KlarnaDetails.ShippingInfo>();
      shippingInfos.add(
        new KlarnaDetails.ShippingInfo(
          shipment.Provider,
          shipment.DeliveryMethod.Name,
          shipment.TrackingUrl,
          shipment.TrackingNumber
        )
      );
    }
    return shippingInfos;
  }
}
