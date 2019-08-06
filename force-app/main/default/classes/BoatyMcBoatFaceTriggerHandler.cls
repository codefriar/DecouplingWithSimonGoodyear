public with sharing class BoatyMcBoatFaceTriggerHandler extends TriggerHandler {
  List<Account> accounts;
  public BoatyMcBoatFaceTriggerHandler() {
    this.accounts = (List<Account>) Trigger.new;
  }

  public override void beforeUpdate() {
    upperCaseNames();
  }

  public override void beforeInsert() {
    upperCaseNames();
  }

  // Helper methods!
  private void upperCaseNames() {
    for (Account acc: this.accounts) {
      acc.Name = acc.Name.toUpperCase();
    }
  }
}
