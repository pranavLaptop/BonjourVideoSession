//
//  videoManager.m
//  Bonjour
//
//  Created by PRANAV KAPOOR on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "videoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "BonjourViewController.h"

@implementation VideoManager
@synthesize  captureSession;
@synthesize  imageView;
@synthesize  customLayer;
@synthesize  prevLayer;
@synthesize callBackObject;



- (void)initCapture {
	/*We setup the input*/
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
                                        deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] 
                                        error:nil];
    captureOutput = [[AVCaptureMovieFileOutput alloc] init];

	/*We create a serial queue to handle the processing of our frames*/
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	//[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	//[captureOutput setVideoSettings:videoSettings]; 
    
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
	self.customLayer = [CALayer layer];
  
	self.customLayer.frame = CGRectMake(0, 0, 320, 420);
	self.customLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
	self.customLayer.contentsGravity = kCAGravityResizeAspectFill;
  
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
	self.prevLayer.frame = CGRectMake(0, 0, 320, 420);
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[captureOverlayView.layer addSublayer: self.prevLayer];
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        [fileManager removeItemAtURL:[self tempFileURL] error:nil]; 
    }
    [self.captureSession startRunning];
    
    [captureOutput startRecordingToOutputFileURL:[self tempFileURL] recordingDelegate:self];

}

- (NSURL *) tempFileURL
{
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        
    }
    [outputPath release];
    return [outputURL autorelease];
}

-(void) initOverlayView:(CGSize)size:(UIView *)_view{
  captureOverlayView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    UIToolbar *toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-60, 320, 44)];
    UIBarButtonItem *barItem=[[UIBarButtonItem alloc] initWithTitle:@"Stop" 
                                                                 style:UIBarButtonItemStyleDone 
                                                                target:self 
                                                                action:@selector(stopRecording)];

    toolbar.items=[NSArray arrayWithObjects:barItem,nil];
    [_view addSubview:captureOverlayView];
    [_view addSubview:toolbar];

}

-(void) stopRecording
{
    NSLog(@"stopRecording");
    self.callBackObject.isRecording = FALSE;
    [[BonjourViewController getRootViewController] stopRecording];
    [captureSession stopRunning];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return [[connection retain] autorelease];
            }
        }
    }
    return nil;
}
     
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
fromConnections:(NSArray *)connections
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error){}];
    }
    
    [library release];    
    
}





#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection 
{ 
	/*We create an autorelease pool because as we are not in the main_queue our code is
	 not executed in the main thread. So we have to create an autorelease pool for the thread we are in*/
  
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
  /*Lock the image buffer*/
  CVPixelBufferLockBaseAddress(imageBuffer,0); 
  /*Get information about the image*/
  uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
  size_t width = CVPixelBufferGetWidth(imageBuffer); 
  size_t height = CVPixelBufferGetHeight(imageBuffer);  
  
  /*Create a CGImageRef from the CVImageBufferRef*/
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
  
  /*We release some components*/
  CGContextRelease(newContext); 
  CGColorSpaceRelease(colorSpace);
  
  /*We display the result on the custom layer. All the display stuff must be done in the main thread because
	 UIKit is no thread safe, and as we are not in the main thread (remember we didn't use the main_queue)
	 we use performSelectorOnMainThread to call our CALayer and tell it to display the CGImage.*/
	[self.customLayer performSelectorOnMainThread:@selector(setContents:) withObject: (id) newImage waitUntilDone:YES];
  
	/*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly).
	 Same thing as for the CALayer we are not in the main thread so ...*/
	UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
  
	/*We relase the CGImageRef*/
	CGImageRelease(newImage);
  
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
  
	/*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
	[pool drain];
} 
@end