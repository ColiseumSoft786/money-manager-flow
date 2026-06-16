enum SubscriptionKind {
  cancellable,
  essential,
  annualContract,
}

extension SubscriptionKindStorage on SubscriptionKind {
  String get storageValue=>name;


  static SubscriptionKind fromStorage(String? value)=>switch(value){
    "essential"=>SubscriptionKind.essential,
    "annualContract"=>SubscriptionKind.annualContract,
    _=>SubscriptionKind.cancellable
    
  };
}