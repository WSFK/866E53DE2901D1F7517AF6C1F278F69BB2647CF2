//
//  CaptureViewController.h
//  handbooklite
//
//  Created by han on 13-3-15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Decoder.h"
#import "TwoDDecoderResult.h"
#import "QRCodeReader.h"
#import "TwoCapture.h"
#import "Config.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)

@interface CaptureViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,DecoderDelegate>{
  AVCaptureSession *session;
  AVCaptureDeviceInput *input;
  AVCaptureVideoDataOutput *output;
  
  AVCaptureVideoPreviewLayer *__weak preview;
  NSMutableSet *qrReader;
  BOOL scanningQR;
  UIButton *btnStop;
}
@property (strong) AVCaptureSession *session;
@property (weak) AVCaptureVideoPreviewLayer *preview;

@end
