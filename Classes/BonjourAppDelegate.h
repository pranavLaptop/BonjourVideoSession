#import <UIKit/UIKit.h>

@class BonjourViewController;

@interface BonjourAppDelegate : NSObject <UIApplicationDelegate, NSNetServiceDelegate> {
    UIWindow *window;
    BonjourViewController *viewController;
	
	//—-use this to publish a service—-   	
    NSNetService *netService;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BonjourViewController *viewController;

@end

