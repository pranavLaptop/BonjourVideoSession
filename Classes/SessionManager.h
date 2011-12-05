//
//  SessionManager.h
//  Bonjour
//
//  Created by PRANAV KAPOOR on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
