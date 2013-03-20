//
//  CaptureViewController.m
//  handbooklite
//
//  Created by han on 13-3-15.
//
//

#import "CaptureViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController
@synthesize session;
@synthesize preview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  btnStop = [[UIButton alloc] initWithFrame:CGRectMake(581, 447, 130, 45)];
  [btnStop setTitle:@"取  消" forState:UIControlStateNormal];
  [[btnStop titleLabel] setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
  [btnStop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  UIImage *bg =[UIImage imageNamed:@"btn_green.png"];
  [btnStop setBackgroundImage:bg forState:UIControlContentVerticalAlignmentCenter];
  [btnStop addTarget:self action:@selector(stopAF) forControlEvents:UIControlEventTouchUpInside];
}

-(void) initQR{
  //初始化二维码解码器
  qrReader = [[NSMutableSet alloc] init];
  QRCodeReader *qrCodeReader = [[QRCodeReader alloc] init];
  [qrReader addObject:qrCodeReader];
  scanningQR = NO;
}
-(void) initAVC{
  //初始化拍摄过程
  NSError *error = nil;
  session = [[AVCaptureSession alloc] init];
  // 可以配置session以产生解析度较低的视频帧，如果你的处理算法能够应付（这种低解析度）。
  // 我们将选择的设备指定为中等质量。
  session.sessionPreset = AVCaptureSessionPresetMedium;
  // 找到一个合适的AVCaptureDevice
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  // 用device对象创建一个设备对象input，并将其添加到session
  input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
  if (!input) {
    // 处理相应的错误
  }
  [session addInput:input];
  // 创建一个VideoDataOutput对象，将其添加到session
  output = [[AVCaptureVideoDataOutput alloc] init];
  [session addOutput:output];
  // 配置output对象
  dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
  [output setSampleBufferDelegate:self queue:queue];
  dispatch_release(queue);
  // 指定像素格式
  output.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                     forKey:(id)kCVPixelBufferPixelFormatTypeKey];
}

-(void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  if (UIDeviceOrientationLandscapeLeft == [[UIDevice currentDevice] orientation]) {
    btnStop.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
  } else{
    btnStop.transform = CGAffineTransformMakeRotation(degreesToRadians(-90));
  }
  [self initQR];
  [self initAVC];
  [session startRunning];
  [self embedPreviewInView];
  [self.view addSubview:btnStop];
  TwoCapture *tc = [TwoCapture newInstence];
  tc.isSendTwoCodeNoti = NO;
}

- (void)stopAF{
  [session stopRunning];
  input = nil;
  [output setSampleBufferDelegate:nil queue:nil];
  output = nil;
  TwoCapture *tc = [TwoCapture newInstence];
  tc.isSendTwoCodeNoti = NO;
   [[NSNotificationCenter defaultCenter] postNotificationName:@"TWOCODEWITHRRESULT" object:@""];
}

-(void) embedPreviewInView{
  if (!session) return;
  
  preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
  preview.frame = CGRectMake(0, 0, 768, 1024);
  preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self.view.layer addSublayer:preview];
  
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
  // 通过抽样缓存数据创建一个UIImage对象
  UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
  Decoder *d = [[Decoder alloc] init];
  d.readers = qrReader;
  d.delegate = self;
  scanningQR = [d decodeImage:image] == YES ? NO : YES;
  if (scanningQR) {
    [session stopRunning];
  }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection NS_AVAILABLE(10_7, 6_0){
  
}

// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
  // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // 锁定pixel buffer的基地址
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  
  // 得到pixel buffer的基地址
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  
  // 得到pixel buffer的行字节数
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // 得到pixel buffer的宽和高
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  
  // 创建一个依赖于设备的RGB颜色空间
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
  CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                               bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  // 根据这个位图context中的像素数据创建一个Quartz image对象
  CGImageRef quartzImage = CGBitmapContextCreateImage(context);
  // 解锁pixel buffer
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
  // 释放context和颜色空间
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  // 用Quartz image创建一个UIImage对象image
  UIImage *image = [UIImage imageWithCGImage:quartzImage];
  
  // 释放Quartz image对象
  CGImageRelease(quartzImage);
  
  return (image);
}

#pragma mark -- DecoderDelegate
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result {
  scanningQR = YES;
  [session stopRunning];
  [self stopAF];
  TwoCapture *tc = [TwoCapture newInstence];
  tc.isSendTwoCodeNoti = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"TWOCODEWITHRRESULT" object:[result text]];
  
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason{
  
}

- (BOOL)shouldAutorotate
{
  return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
  btnStop = nil;
  [super viewDidUnload];
}
@end
