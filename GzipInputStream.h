#import <Foundation/Foundation.h>
#include <zlib.h>

@interface GzipInputStream : NSInputStream

- (NSString *)readLine;

@end
