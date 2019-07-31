trigger BoatyMcBoatFaceTrigger on Account(before insert, before update) {
  new BoatyMcBoatFaceTriggerHandler().run();
}
