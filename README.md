GzipInputStream
===============

A dead simple subclass of NSInputStream that reads .gz files with reading line by line functionality.

Notes:
------
- Requires Clang/LLVM 2.0 compiler
- The only initializer supported is (id)initWithFileAtPath:(NSString *)path

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