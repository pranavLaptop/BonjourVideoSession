#import "BonjourViewController.h"

#import <netinet/in.h>
#import <arpa/inet.h>

@implementation BonjourViewController

@synthesize tbView;
@synthesize debug;
@synthesize browser;
@synthesize services;

@synthesize clientSocket;
@synthesize serviceIP;
@synthesize btnSynchronize;
@synthesize btnRecord;


BonjourViewController *rootViewController=NULL;
@synthesize message;

+(BonjourViewController *) getRootViewController
{
    return  rootViewController;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSData             *address = nil;
	struct sockaddr_in *socketAddress = nil;
	
	if ([[[services objectAtIndex:indexPath.row] addresses] count] > 0) {
		address = [[[services objectAtIndex:indexPath.row] addresses] objectAtIndex: 0];
		socketAddress = (struct sockaddr_in *) [address bytes];
		//---save the IP address of the service selected---
		self.serviceIP = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
	}	
}

-(IBAction) btnConnect:(id)sender {
	NSError *err;	
	debug.text = [debug.text stringByAppendingFormat:@"%@\n", serviceIP];
	
    AsyncSocket	*socket = [[AsyncSocket alloc] initWithDelegate:self];			
    if(![socket connectToHost:self.serviceIP onPort:12345 error:&err])
	{
		debug.text = [debug.text stringByAppendingString:@"Error connecting\n"];
	}
	else {
		debug.text = [debug.text stringByAppendingString:@"Connected\n"];
        NSLog ( @"The current date and time is: %f", [[NSDate date] timeIntervalSince1970] );
		self.clientSocket = socket;
	}
	[socket release];	
  [btnSynchronize setEnabled:TRUE];
}

-(IBAction)btnSynchronize:(id)sender
{
  NSString* synchString = [NSString stringWithFormat:@"%f\r\n",[[NSDate date] timeIntervalSince1970]];
  [self sendDataToServer:synchString];
  
}

-(void) sendDataToServer:(NSString*) stringToSend
{
  NSData* data = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
  [self.clientSocket writeData:data withTimeout:-1 tag:1];
}

-(IBAction)btnRecord:(id)sender
{
  isRecording = TRUE;
  NSString *msg =[NSString stringWithFormat:@"record_signal:startRecording\r\n"];
	[self sendDataToServer:msg];
  vManager=[[VideoManager alloc] init];
  [vManager initOverlayView:self.view.frame.size :self.view];
  [vManager initCapture];
}


-(IBAction) btnSend:(id)sender {
	NSString *msg =[NSString stringWithFormat:@"synch_signal:%@\r\n",message.text];
	[self sendDataToServer:msg];
  [btnRecord setEnabled:TRUE];
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
	[connectedSockets addObject:newSocket];
	debug.text = [debug.text stringByAppendingString:@"didAcceptNewSocket\n"];
    NSLog ( @"The current date and time is: %f", [[NSDate date] timeIntervalSince1970] );

}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	debug.text = [debug.text stringByAppendingString:@"didConnectToHost\n"];
	
    NSLog ( @"The current date and time is: %f", [[NSDate date] timeIntervalSince1970] );

    
    //---this statment is meant for the server so that it can reply to clients connected to it---
	self.clientSocket = sock;
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	debug.text = [debug.text stringByAppendingString:@"didWriteDataWithTag\n"];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	debug.text = [debug.text stringByAppendingString:@"didReadData\n"];
	
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if (msg) 
  {
		NSRange colon = [msg rangeOfString:@":"];
    NSRange headerRange = NSMakeRange(0, colon.location);
    NSRange dataRange = NSMakeRange(colon.location+1, msg.length);
    NSString* header = [msg substringWithRange:headerRange];
    NSString* data = [msg substringWithRange:dataRange];
    NSLog(@"Header: %@",header);
    NSLog(@"Data received: %@",data);
    
    if([header isEqualToString:@"synch_signal"])
    {
      synchSignal = [data floatValue];
      [btnRecord setEnabled:TRUE];
    }
    else if([header isEqualToString:@"record_signal"] && !isRecording)
    {
      isRecording = TRUE;
      vManager=[[VideoManager alloc] init];
      [vManager initOverlayView:self.view.frame.size :self.view];
      [vManager initCapture];
    }
    
    /*else if([header isEqualToString:@"ping_signal"])
    {
      NSString* pingString = [NSString stringWithFormat:@"ping_response:%@",@"handShake"];
      NSData* pingData = [pingString dataUsingEncoding:NSUTF8StringEncoding];
      sendTime = [[NSDate date] timeIntervalSince1970];
      [self.clientSocket writeData:pingData withTimeout:-1 tag:1];
    }
    else if([header isEqualToString:@"ping_response"])
    {
      receivedTime = [data floatValue];
    }*/
    
		/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Received" 
														message:msg 
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];	*/	
	}
	else {
		debug.text = [debug.text stringByAppendingString:@"Error converting received data into UTF-8 String\n"];
	}
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	debug.text = [debug.text stringByAppendingString:@"willDisconnectWithError\n"];
	debug.text = [debug.text stringByAppendingFormat:@"Client Disconnected: %@:%hu\n", [sock connectedHost], [sock connectedPort]];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	[connectedSockets removeObject:sock];
	debug.text = [debug.text stringByAppendingString:@"onSocketDidDisconnect\n"];
}

-(IBAction) doneEditing:(id) sender {
	[sender resignFirstResponder];	
}

//—-set the number of rows in the TableView—-
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return [services count];   
}

//—-display the individual rows in the TableView—-
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = 
	    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:CellIdentifier] autorelease];
    }

    //—-display the hostname of each service—-
    cell.textLabel.text = [[services objectAtIndex:indexPath.row] hostName];
	
    return cell;	
}

//—-browse for services—-
-(void) browseServices {
	services = [NSMutableArray new];
    self.browser = [[NSNetServiceBrowser new] autorelease];
    self.browser.delegate = self;	
    [self.browser searchForServicesOfType:@"_MyService._tcp." inDomain:@""];
}

-(void) viewDidLoad {
	debug.text = @"";
	rootViewController=self;
	//---create a server socket and start listening---
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];		
	connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
	NSError *error = nil;
	if(![listenSocket acceptOnPort:12345 error:&error])
	{
		debug.text = [debug.text stringByAppendingString:@"Error listening\n"];
	}
	else {
		debug.text = [debug.text stringByAppendingString:@"Listening...\n"];
	}	
	
    [self browseServices];
    [super viewDidLoad];
}

//—-services found—-
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
          didFindService:(NSNetService *)aService
              moreComing:(BOOL)more {	
	
    [services addObject:aService];	
    debug.text = [debug.text stringByAppendingString:				  
				  @"Found service. Resolving address...\n"];	
    [self resolveIPAddress:aService];	
}

//—-services removed from the network—-
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
        didRemoveService:(NSNetService *)aService 
			  moreComing:(BOOL)more {
	
    [services removeObject:aService];
    debug.text = [debug.text stringByAppendingFormat:@"Removed: %@\n",				  
				  [aService hostName]];
	
    [self.tbView reloadData];	
}

//—-resolve the IP address(es) of a service—-
-(void) resolveIPAddress:(NSNetService *)service {   
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

//—-managed to resolve—-
-(void)netServiceDidResolveAddress:(NSNetService *)service {
   // NSString           *name = nil;
    NSData             *address = nil;
    struct sockaddr_in *socketAddress = nil;
    NSString           *ipString = nil;
    int                port;
	
    //—-get the IP address(es) of a service—-
    for(int i=0;i < [[service addresses] count]; i++ ) {
        //name = [service name];
        address = [[service addresses] objectAtIndex: i];
        socketAddress = (struct sockaddr_in *) [address bytes];
        ipString = [NSString stringWithFormat: @"%s",
					inet_ntoa(socketAddress->sin_addr)];
		
        port = socketAddress->sin_port;		
        debug.text = [debug.text stringByAppendingFormat:					  
					  @"Resolved: %@—>%@:%hu\n", [service hostName], ipString, port];		
    }
	
    [self.tbView reloadData];	
}

//—-did not manage to resolve—-
-(void)netService:(NSNetService *)service
    didNotResolve:(NSDictionary *)errorDict {
    debug.text = [debug.text stringByAppendingFormat:
				  @"Could not resolve: %@\n", errorDict];	
}

- (void)dealloc {
	[tbView release];
    [debug release];   
    [browser release];
    [services release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
