#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "VideoManager.h"

@class  BonjourViewController;

@interface VideoManager :NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *_captureSession;
    UIView *view;
	UIImageView *_imageView;
	CALayer *_customLayer;
	AVCaptureVideoPreviewLayer *_prevLayer;
    UIView  *captureOverlayView;
    UIImageView *overlayImageView;
    AVCaptureMovieFileOutput *captureOutput;
    UIViewController *viewController;
    BonjourViewController* _callBackObject;
}

////Camera Session Init
@property (nonatomic, retain) AVCaptureSession *captureSession;

////OnScreen ViewPort for showing captured Video
@property (nonatomic, retain) UIImageView *imageView;

////OnScreen Layer to show captured Video
@property (nonatomic, retain) CALayer *customLayer;

///Find out more
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

@property (nonatomic, retain) BonjourViewController* callBackObject;

- (void)initCapture;
- (void)endCapture;
- (void) stopRecording;
- (void)beginCapture;
-(void) initOverlayView:(CGSize)size:(UIView *)_view;
@end