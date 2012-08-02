#import <Foundation/Foundation.h>
#include <zlib.h>

@interface GzInputStream : NSInputStream
{
    gzFile* gzfile;
    NSString *filepath;
    NSMutableData *residualData;
}

- (NSString *)readLine;

@end
