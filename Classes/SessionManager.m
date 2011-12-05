//
//  SessionManager.m
//  Bonjour
//
//  Created by PRANAV KAPOOR on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
