GzipInputStream
===============

A dead simple subclass of NSInputStream that reads .gz files with reading line by line functionality.

Example Usage:
--------------

```objective-c
GzInputStream *is = [[GzInputStream alloc] initWithFileAtPath:@"text.gz"];
[is open];
NSString *line;
while ((line = [is readLine])) {
    // do something with line
}
[is close];
[is release];
```