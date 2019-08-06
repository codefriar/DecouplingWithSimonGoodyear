trigger BoatyMcBoatFaceTrigger on Account(before insert, before update) {
  /*
   * This (Account) trigger is fired by the Salesforce Platform, and calls our
   * trigger handler class called CustomMDTTriggerHandler. It's run() method
   * has been overridden to: 
   *   * Identify custom metadata records that specify trigger logic for this 
   *      specific sObject (Account, in this case).
   *   * Instantiates an object from the String stored in the CMD records.
   *   * Executes the context appropriate methods. I.e: if this is a 
   *      beforeUpdate trigger context, execute the custom trigger handler's 
   *      beforeUpdate() method.
   * 
   * It's important to note, that to fully adopt this pattern, *all* of your 
   * actual .trigger files need to call this exact same single line of code.
   * However, to facilitate gradual adoption of the pattern, it's still possible
   * to call a distinct trigger handler here, rather than the custom Metadata 
   * driven handler. 
  */
  new CustomMDTTriggerHandler().run();
}
