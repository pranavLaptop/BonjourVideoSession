#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
#import "VideoManager.h"

@interface BonjourViewController : UIViewController 
  <UITableViewDelegate, 
  UITableViewDataSource,
  NSNetServiceDelegate, 
  NSNetServiceBrowserDelegate> {
      
	//—-outlets—-
  IBOutlet UITableView *tbView;
  IBOutlet UITextView *debug;
  IBOutlet UIButton* btnSynchronize;
  IBOutlet UIButton* btnRecord;  
	
	//—-use for browsing services—-	
  NSNetServiceBrowser *browser;	
  NSMutableArray *services;
	
	IBOutlet UITextField *message;
	NSString *serviceIP;
  AsyncSocket *listenSocket;
  AsyncSocket *clientSocket;
  NSMutableArray *connectedSockets;		
  float synchSignal;
  float sendTime;
  float recordStartTime;
  float currentTime;
  bool isRecording;
  VideoManager* vManager;
}

-(void) resolveIPAddress:(NSNetService *)service;
-(void) browseServices;

//—-expose the outlets as properties—-
@property (nonatomic, retain) UITableView *tbView;
@property (nonatomic, retain) UITextView *debug;
@property (nonatomic, retain) UIButton* btnSynchronize;
@property (nonatomic, retain) UIButton* btnRecord;

@property (nonatomic, retain) UITextField *message;

@property (readwrite, retain) NSNetServiceBrowser *browser;
@property (readwrite, retain) NSMutableArray *services;

@property (nonatomic, retain) AsyncSocket *clientSocket;
@property (nonatomic, retain) NSString *serviceIP;

@property bool isRecording;

-(IBAction) btnConnect:(id)sender;
-(IBAction) btnSend:(id)sender;
-(IBAction) doneEditing:(id) sender;
-(IBAction) btnSynchronize:(id)sender;
-(IBAction)btnRecord:(id)sender;
-(void) sendDataToServer:(NSString*) stringToSend;
+(BonjourViewController *) getRootViewController;
- (void) stopRecording;

@end

