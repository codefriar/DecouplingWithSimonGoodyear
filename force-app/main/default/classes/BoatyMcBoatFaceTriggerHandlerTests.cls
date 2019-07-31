@isTest
public with sharing class BoatyMcBoatFaceTriggerHandlerTests {
  @TestSetup
  static void makeData() {
    Account awesomeAccount = new Account(name = 'not caps');
    insert awesomeAccount;
  }

  static void canWeSeeTheMetadatas() {
    Test.startTest();
    new TestableTriggerHandlerLogic().run();
    Test.stopTest();
  }
}
