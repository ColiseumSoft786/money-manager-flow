enum SubscriptionStatus {
  active,
  cancelled,
  paused,
}
extension SubscriptionStatusStorage on SubscriptionStatus {
  String get storageValue=>name;
  static SubscriptionStatus fromStorage(String? value)=>switch(value){
    "cancelled"=>SubscriptionStatus.cancelled,
    "paused"=>SubscriptionStatus.paused,
    _=> SubscriptionStatus.active,

  };
}