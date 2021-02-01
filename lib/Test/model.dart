class Product {
  final int idProduct;
  final String productName;
  final int productPrice;
  final int productAmount;
  final String productType;
  final String productSubType;
  final String productImg;
        int numberOfItem;

  Product(this.idProduct, this.productName, this.productPrice, this.productAmount, this.productType, this.productSubType, this.productImg, this.numberOfItem);

  Map<String,dynamic> toJson() => {
    'idProduct' : idProduct,
    'productName': productName,
    'productPrice': productPrice,
    'productAmount': productAmount,
    'productType': productType,
    'productSubType': productSubType,
    'productImg': productImg,
    'numberOfItem': numberOfItem,
  };
}