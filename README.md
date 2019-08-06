# Live Coding with Simon Goodyear 

Last Wednesday Simon Goodyear and I did a Live coding stream with a live studio audience here at Forcelandia (http://forcelandia.com/). In case you couldn't tune in, here's the recording. (https://www.youtube.com/watch?v=ilZ4-UWH6n8) Our mission for this stream was to facilitate multi-package development when there are Triggers in play. For as long as I can remember, the Trigger rule has always been: One Trigger Per Object. This makes multiple packages difficult, because the triggers, and their associated logic often cross-depend on one another. Finding a way to decouple triggers, and trigger logic from one another is a bit of a sticky wicket. 

![Architectural overview of what we're building](https://github.com/codefriar/DecouplingWithSimonGoodyear/blob/master/overview.png)

The diagram above shows what we're building. The orange rectangle represents a package containing everything related to actual .trigger files, along with the Trigger Framework and a custom trigger handler class: CustomMDTTriggerHandler.cls. With this trigger package installed, any other package we create can include both the custom trigger handlers we want executed, as well as custom metadata records registering those trigger handlers. 

To meet our goals of maintaining the single trigger per object, while decoupling triggers to enable packaging required us to find a way to find, at runtime, the trigger logic we wanted to run, regardless of what package it may be in. To accomplish this we used a combination of three technologies: A Trigger Framework, Custom Metadata, and Meta Programming. 

To save time on the stream, we started with a Trigger Framework byKevin O'Hara (https://github.com/kevinohara80)that both Simon and I have used in the past. You can read more about it here: Trigger Framework (https://github.com/kevinohara80/sfdc-trigger-framework). The key to this framework, is the virtual class it provides. Because it's virtual, extending classes can override when necessary, and inherit when no override is present. The provided virtual class defines a default .run() method. This allows your actual triggers to have nothing more than a single line of logic: 

```apex
new MyTriggerHandlerOfAwesome().run()
```

Custom Metadata types (https://help.salesforce.com/articleView?id=custommetadatatypes_overview.htm&type=5) are a Lightning Platform feature. Not only do Custom Metadata Types allow you to create new types of data, you can package and deploy that data as well. In a multi-package Org, this means you could easily create one package defining the custom metadata type, and other packages as necessary could include deployable records. Our solution uses this technology to define a custom metadata type describing Trigger Logic. We then created records of that type to describe specific classes we wanted executed, and in what order. Having a custom metadata records means our trigger can query and get a list of classes to execute. However, the query is, at best, able to return strings of class names to us. Converting those class names into actual instantiated objects that we can manipulate is where Meta-programming comes in.

Apex has a fairly robust Type class. One of it's charms is the ability to get a Type object for a given string. With this, we can convert the string 'SomeType' into a Type object. It's important to note that this is possible, not only with sObjects like Account and Custom_Object__C but also Apex class types. Once we have a Type object, we can call the newInstance() method to return a new object of that type. Using these two Type methods together, allows us to construct a new object dynamically, based on the string representation of the class's name we pulled from our Custom Metadata Records. Here's what that Apex looks like, fully formed

```apex
TriggerHandler handler = (TriggerHandler)Type.forName(trygger.Class_Name__c).newInstance();
```

Note, we're having to cast the resulting object to TriggerHandler. The Trigger framework we started with requires our specific trigger handlers to extend the provided TriggerHandler class. Because our individual trigger handler classes all extend this class, we can safely cast any object we dynamically create to that Type. While this may seem like a limitation it gives us access to all of the methods defined in TriggerHandler including things like beforeInsert(), afterUpdate() etc. 

These three bits, when combined, allow us to define a generic CustomMDTTriggerHandler class that all triggers can call. That generic TriggerMDTHandler class, is then responsible for: 

1. Determining the sObject DML has been preformed on 
2. Querying for Custom Metadata related to the sObject for individual trigger handlers to execute
3. Meta-programming those class names into actual objects that are executed. 

Using this pattern we can ship one package, (Trigger Package) with the Trigger Framework, CustomMDTTriggerHandler, Custom Metadata Type, as well as a single trigger per object, without depending on any other code. Other packages (Domain Packages) in the org can ship specific trigger handler classes and custom metadata type records. These Domain Packages will maintain a dependency on the Trigger Package, but this is most likely, a dependency that won't cause you heartache — I.e. Updating one would likely requires no change in other packages. 

We'll be doing more Live Coding streams here in the near future. Keep a watch on this page (https://developer.salesforce.com/event/live-coding) to register for our next one! In the mean time, if you've got an idea for something you'd like to see us Live Code, reach out to @codefriar (https://twitter.com/codefriar) on twitter with your suggestions and requests. Like what you've seen here? Check out the code base! (https://github.com/codefriar/DecouplingWithSimonGoodyear)We've also set up a Trailmix with more information on Custom Metadata, Triggers and Types (Oh My!)
