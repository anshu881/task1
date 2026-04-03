enum CustomerType {
  dealer,
  retail,
}

extension CustomerTypeLabel on CustomerType {
  String get label => switch (this) {
        CustomerType.dealer => 'Dealer',
        CustomerType.retail => 'Retail',
      };
}
