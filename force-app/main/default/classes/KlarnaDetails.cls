public with sharing class KlarnaDetails {
  public Integer amount { get; set; }
  public String reference { get; set; }
  public String type { get; set; }
  public Klarna klarna { get; set; }

  public with sharing class Klarna {
    public String description { get; set; }
    public List<Products> products { get; set; }
    public List<ShippingInfo> shipping_info { get; set; }
    public Integer shipping_delay { get; set; }
  }

  public with sharing class Products {
    public String name { get; set; }
    public Integer quantity { get; set; }
    public Integer unit_price { get; set; }
    public Integer tax_rate { get; set; }
    public Integer total_amount { get; set; }
    public Integer total_tax_amount { get; set; }

    public Products() {
    }

    public Products(
      String name,
      Integer quantity,
      Integer unit_price,
      Integer tax_rate,
      Integer total_amount,
      Integer total_tax_amount
    ) {
      this.name = name;
      this.quantity = quantity;
      this.unit_price = unit_price;
      this.tax_rate = tax_rate;
      this.total_amount = total_amount;
      this.total_tax_amount = total_tax_amount;
    }
  }

  public with sharing class ShippingInfo {
    public string shipping_company { get; set; }
    public string shipping_method { get; set; }
    public string tracking_number { get; set; }
    public string tracking_uri { get; set; }

    public ShippingInfo(
      String shipping_company,
      String shipping_method,
      String tracking_number,
      String tracking_uri
    ) {
      this.shipping_company = shipping_company;
      this.shipping_method = shipping_method;
      this.tracking_number = tracking_number;
      this.tracking_uri = tracking_uri;
    }
  }
}
