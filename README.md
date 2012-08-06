GzipInputStream
===============

A dead simple subclass of NSInputStream that reads .gz files with reading line by line functionality.

Notes:
------
- Requires Clang/LLVM 2.0 compiler.
- Only works with gzip file. The `-(id)initWithData:(NSData *)data` initializer is not supported. Use instead https://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/Foundation/GTMNSData%2Bzlib.h
- Avoid mixing `read:maxLength:` and `readLine` calls. It's not prohibited, but `readLine` calls `read:maxLength:` behind the scene and stores residual data in a buffer. It would be ideal to have `read:maxLength:` drain the residual data from buffer first before calling `gzread()`.

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
