#import "SessionManager.h"

SessionManager *sessionInstance=NULL;
@implementation SessionManager
@synthesize connectionTime;
@synthesize recordStartTime;


+(SessionManager *) getInstance
{
    return sessionInstance;
}

-(void) initSessionManager
{
    sessionInstance=self;
}


@end
