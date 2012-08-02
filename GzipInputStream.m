#import "GzipInputStream.h"

@implementation GzInputStream

- (id)initWithFileAtPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    self = [super init];
    if (self) {
        residualData = nil;
        filepath = [path retain];
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        residualData = [data copy];
        filepath = nil;
    }
    return self;    
}

- (void)dealloc
{
    [self close];
    [filepath release];
    [residualData release];
    [super dealloc];
}

- (void)open
{
    if (filepath) {
        gzfile = gzopen([filepath UTF8String], "rb");
        residualData = [[NSMutableData alloc] initWithCapacity:1024];
    }
}


- (void)close
{
    if (gzfile) {
        gzclose(gzfile);
        gzfile = NULL;
    }
    if (residualData) {
        [residualData release];
        residualData = nil;
    }
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    int bytesRead = gzread(gzfile, buffer, len);
    return bytesRead;
}

- (NSString *)readLine
{
    uint8_t buffer[1024];
    NSString * line = [self firstLineFromData:residualData];
    while (!line) {
        NSInteger bytesRead = [self read:buffer maxLength:sizeof(buffer)];
        if (bytesRead > 0) {
            [residualData appendBytes:buffer length:bytesRead];
            line = [self firstLineFromData:residualData];
        }
        else if (residualData.length == 0) {
            return nil;
        }
        else {
            line = [[[NSString alloc] initWithBytes:residualData.bytes 
                                             length:residualData.length 
                                           encoding:NSUTF8StringEncoding] 
                    autorelease];
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            [residualData setLength:0];
        }
    }
    return line;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    if (residualData.length > 0) {
        *buffer = (uint8_t *)residualData.bytes;
        *len = residualData.length;
        return YES;
    }
    else
        return NO;
}

- (BOOL)hasBytesAvailable
{
    if (gzeof(gzfile) || residualData.length > 0) {
        return NO;
    }
    return YES;
}

- (NSError *)streamError
{
    const char * error_string;
    int err;
    error_string = gzerror(gzfile, &err);
    return [NSError errorWithDomain:NSCocoaErrorDomain code:err userInfo:nil];
}

#pragma mark helper private method
- (NSString *)firstLineFromData:(NSMutableData *)data
{
    NSString * line = nil;
    
    uint8_t *buf = (uint8_t *)data.bytes;
    uint8_t *pos = memchr(buf, '\n', data.length);
    if (pos) {
        size_t len = pos - buf;
        line = [[[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding] autorelease];
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [data replaceBytesInRange:NSMakeRange(0,len+1) withBytes:NULL length:0];
    }
    return line;
}

@end
