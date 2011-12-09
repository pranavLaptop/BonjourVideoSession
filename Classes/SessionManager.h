#import <Foundation/Foundation.h>

@interface SessionManager : NSObject
{
    float connectionTime;
    float recordStartTime;

}
@property (readwrite,assign) float connectionTime;
@property (readwrite,assign) float recordStartTime;

+(SessionManager *) getInstance;
-(void) initSessionManager;

@end
