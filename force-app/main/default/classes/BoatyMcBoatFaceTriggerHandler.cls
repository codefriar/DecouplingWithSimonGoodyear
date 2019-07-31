public with sharing class BoatyMcBoatFaceTriggerHandler extends TriggerHandler {
  List<Account> accounts;
  public BoatyMcBoatFaceTriggerHandler(List<Account> accounts) {
    this.accounts = accounts;
  }

  public override beforeUpdate() {
    upperCaseNames();
  }

  public override beforeInsert() {
    upperCaseNames();
  }

  // Helper methods!
  private void upperCaseNames() {
    for (Account acc: this.accounts) {
      acc.Name = acc.Name.toUpperCase();
    }
  }
}
