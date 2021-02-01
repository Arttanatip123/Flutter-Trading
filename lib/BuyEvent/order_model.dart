class Order {
  final int idOrderList;
  final int idUserProfile;
  final String userName;
  final int idUserShop;
  final String shopName;
  final String timeReceive;
  final int totalPrice;
  final String productList;
  final int orderStatus;

  Order(
      this.idOrderList,
      this.idUserProfile,
      this.userName,
      this.idUserShop,
      this.shopName,
      this.timeReceive,
      this.totalPrice,
      this.productList,
      this.orderStatus,
      );
}