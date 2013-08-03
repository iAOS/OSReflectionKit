OSReflectionKit
===============

Lightweight object reflection library for iOS and Mac OS X. that allows you to instantiate objects from a simple [NSDictionary](http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSDictionary_Class/Reference/Reference.html) objects. For example, here's how easy it is to instantiate an object from a dictionary:

```objective-c
NSURL *url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
NSURLRequest *request = [NSURLRequest requestWithURL:url];
AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    NSLog(@"App.net Global Stream: %@", JSON);
} failure:nil];
[operation start];
```
