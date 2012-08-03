GzipInputStream
===============

A dead simple subclass of NSInputStream that reads .gz files with reading line by line functionality.

Notes:
------
- Requires Clang/LLVM 2.0 compiler
- The `-(id)initWithData:(NSData *)data` initializer is not supported

Example Usage:
--------------

```objective-c
#import "GzipInputStream.h"

GzipInputStream *is = [[GzipInputStream alloc] initWithFileAtPath:@"text.gz"];
[is open];
NSString *line;
while ((line = [is readLine])) {
    // do something with line
}
[is close];
[is release];
```

Link with libz.dylib and compile :)
