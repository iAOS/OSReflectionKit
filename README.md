OSReflectionKit
===============

Lightweight object reflection library for iOS and Mac OS X, that allows you to instantiate objects from a simple [NSDictionary](http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSDictionary_Class/Reference/Reference.html) objects. For example, here's how easy it is to instantiate an object from a dictionary:

```objective-c
NSDictionary *categoryDict = nil;

// ... Obtain the dictionary data
categoryDict = @{@"name" : @"Restaurants", @"itemsCount" : @(12)}; // Sample
// ...

// Instantiate the Category object with the content from the dictionary
Category *category = [Category objectFromDictionary:categoryDict];

```
OSReflectionKit is based on the AZReflection classes from Alexander Zats.
