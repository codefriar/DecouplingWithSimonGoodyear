public with sharing class CustomMDTTriggerHandler extends TriggerHandler {
  /*
   * This trigger handler class exists as a 'catch-all' trigger handler for
   * objects who's trigger handler logic is actually managed by Custom Metadata

   * Because the Trigger Framework in use is designed to be overridden where needed
   * and because we want to enable incremental changes twoards metadata driven
   * trigger logic, we're overriding the run() method here to find and execute
   * the metadata designated trigger logic.
  */

  public override void run() {
    /*
     * Our first task is to identify the object on which this trigger fired.
     * The good news is Trigger.new will only every contain one type of object
     * which makes this detection easier. see the helper method below
     */

    String firedOnsObjectType = getSObjectType();

    /*
     * This query executes against our custom metadata to return records that detail
     * what trigger handlers, and in what order, they should be called.
     */
    List<TriggersOfAwesome__mdt> triggerHandlersToRun = [
      SELECT Execution_Order__c, Class_Name__c
      FROM TriggersOfAwesome__mdt
      WHERE sObjectType__c = :firedOnsObjectType
      ORDER BY Execution_Order__c
    ];

    /*
     * this loops over each of the trigger handlers identified in the query above, executing them.
     * Please tweet @simongoodyear to ask him about Tryggers
     */
    for (TriggersOfAwesome__mdt trygger: triggerHandlersToRun) {
      /*
       * This next line of code is crucial to transforming the string we get from
       * the custom metadata and transforming that into an actual object we can
       * call methods on.
       * Note: all of these methods *must* extend TriggerHandler if you have a mis-match
       * between your trigger handler class name, or the class it's extending here, the 
       * Type.forName call can fail. 
       */

      TriggerHandler handler;
      try{
        handler = (TriggerHandler) Type.forName(trygger.Class_Name__c).newInstance();
      } catch (NullPointerException npe) {
        /*
         * If we fail to instantiate a valid object from the string name, or if
         * the returned object does not extend TriggerHandler, skip to the next
         * iteration of the for loop. Might want to at least tell someone.
        */
        continue;
      }
      
      // dispatch to the correct handler method
      switch on this.context {
        when BEFORE_INSERT {
          handler.beforeInsert();
        }
        when BEFORE_UPDATE {
          handler.beforeUpdate();
        }
        when BEFORE_DELETE {
          handler.beforeDelete();
        }
        when AFTER_INSERT {
          handler.afterInsert();
        }
        when AFTER_UPDATE {
          handler.afterUpdate();
        }
        when AFTER_DELETE {
          handler.afterDelete();
        }
        when AFTER_UNDELETE {
          handler.afterUndelete();
        }
      }
    }
  }

  // Helper methods

  /*
   * function returns a string representation of the object type for the first object
   * in Trigger.New. Because Trigger.new is not populated in delete and undelete
   * Trigger Contexts, this is quasi-smart in determining which to execute against.
   */
  private String getSObjectType() {
    if(Trigger.new != null){
      return Trigger.new[0].getSObjectType().getDescribe().getName();
    } else {
      return Trigger.old[0].getSObjectType().getDescribe().getName();
    }
  }
}
