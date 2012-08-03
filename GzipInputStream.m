#import "GzipInputStream.h"

@interface GzipInputStream() 
{
    gzFile* gzfile;
    NSString *filepath;
    NSMutableData *residualData;
    NSStreamStatus streamStatus;    
}
- (NSString *)firstLineFromData:(NSMutableData *)data;
@end

@implementation GzipInputStream

- (id)initWithFileAtPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self release];
        return nil;
    }
    if (self = [super init]) {
        residualData = nil;
        filepath = [path retain];
        streamStatus = NSStreamStatusNotOpen;
    }
    return self;
}

- (id)initWithData:(NSData *)data { [self release]; return nil; }
- (id)initWithURL:(NSURL *)url { [self release]; return nil; }
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}


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
        streamStatus = NSStreamStatusOpen;
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
    streamStatus = NSStreamStatusClosed;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    streamStatus = NSStreamStatusReading;
    int bytesRead = gzread(gzfile, buffer, (unsigned)len);
    if (bytesRead < 0) {
        streamStatus = NSStreamStatusError;
    }
    else if (bytesRead == 0) {
        streamStatus = NSStreamStatusAtEnd;
    }
    else {
        streamStatus = NSStreamStatusOpen;
    }
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
            streamStatus = NSStreamStatusAtEnd;
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

- (NSStreamStatus)streamStatus
{
    return streamStatus;
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
