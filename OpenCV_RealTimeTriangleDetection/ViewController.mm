//
//  ViewController.m
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 15/04/2018.
//  Copyright 2018 Mohammad Zulqurnain.
//

#import "HelpViewController.h"
#import "ViewController.h"
#import "opencv2/opencv_modules.hpp"
#import "opencv2/nonfree/features2d.hpp"
#import <stdio.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "opencv2/features2d/features2d.hpp"
#include <iostream>


#import "MSERManager.h"
#import "MLManager.h"
#import "ImageUtils.h"
#import "GeometryUtil.h"

#ifdef DEBUG
#import "FPS.h"
#endif

//this two values are dependant on defaultAVCaptureSessionPreset
#define W (480)
#define H (640)

@interface ViewController ()

@end

@implementation ViewController
@synthesize sgmtResolutionAdjustment, settingsMenu;
//Default Image
UIImage *sampleImage = [UIImage imageNamed:@"N"];
bool isBackCamera = true;
//default minimum number for the features
int numberOfGoodMatches = 10;
//default minimum number for the features
bool isSettingsMenuVisible = true;
//default zoom parameter
float zoomScale = 1.0f;
//show far features
bool showFarFeature = false;
//show all MSER features
bool showAllMSERs = false;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initViewSettings];
    [self initVideoCamera];
    [self.videoCamera start];
    //[self pickImageFromGallery];
}

/**
 * initViewSettings
 * @Description - Initializes the viewcontroller settings
 */
-(void)initViewSettings{
    settingsMenu.layer.cornerRadius = 15;
    [self.navigationController setNavigationBarHidden:true];
}

/**
 * initVideoCamera
 * @Description - Initializes the camera parameters
 */
-(void)initVideoCamera{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    _videoCamera = [[CvVideoCamera alloc] initWithParentView:_cameraView];
    _videoCamera.delegate = self;
    _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _videoCamera.rotateVideo = YES;
    _videoCamera.defaultFPS = 30;
    _videoCamera.grayscaleMode = NO;
    _videoCamera.imageHeight = height;
    _videoCamera.imageWidth = width;
    
    [[_videoCamera parentView] setNeedsDisplay];
    
    [self.videoCamera unlockFocus];
    [self.videoCamera unlockExposure];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * MSERFeatureDetection
 * @param videoFrame, reference image
 * @return resultant matrix with requested features higlighted(i.e. matching features in green, Entire MSER features in red, and unrelated features in blue)
 */
Mat MSERFeatureDetection(cv::Mat image){

    cv::Mat gray;
    cvtColor(image, gray, CV_BGRA2GRAY);
    
    std::vector<std::vector<cv::Point>> msers;
    [[MSERManager sharedInstance] detectRegions: gray intoVector: msers];
    if (msers.size() == 0) { return image; };
    
    std::vector<cv::Point> *bestMser = nil;
    double bestPoint = numberOfGoodMatches;
    
    std::for_each(msers.begin(), msers.end(), [&] (std::vector<cv::Point> &mser)
      {
          MSERFeature *feature = [[MSERManager sharedInstance] extractFeature: &mser];
          
          if(feature != nil)
          {
              if([[MLManager sharedInstance] isReferenceLogo: feature] )
              {
                  double tmp = [[MLManager sharedInstance] distance: feature ];
                  if ( bestPoint > tmp ) {
                      bestPoint = tmp;
                      bestMser = &mser;
                  }
                  
                  [ImageUtils drawMser: &mser intoImage: &image withColor: GREEN];
              }
              else if(showFarFeature)
              {
                  NSLog(@"%@", [feature toString]);
                  [ImageUtils drawMser: &mser intoImage: &image withColor: RED];
              }
          }
          else if(showAllMSERs)
          {
              [ImageUtils drawMser: &mser intoImage: &image withColor: BLUE];
          }
      });
    
    if (bestMser)
    {
        NSLog(@"minDist: %f", bestPoint);
        
        cv::Rect bound = cv::boundingRect(*bestMser);
        cv::rectangle(image, bound, GREEN, 3);
    }
    else
    {
        //cv::rectangle(image, cv::Rect(0, 0, W, H), RED, 3);
    }
    
    /*#if DEBUG
    
    const char* str_fps = [[NSString stringWithFormat: @"MSER: %ld", msers.size()] cStringUsingEncoding: NSUTF8StringEncoding];
    cv::putText(image, str_fps, cv::Point(5, H - 5), CV_FONT_HERSHEY_PLAIN, 1.0, RED);
    #endif*/
    
    return image;
}

/**
 * processFrameFeatures
 * @param videoFrame, reference image
 * @return resultant matrix(if enough features are detected then it displays feature correspondance between video frame and the reference image otherwise it just returns the current video frame)
 */
Mat processFrameFeatures(const cv::Mat& videoFrame, const cv::Mat& referenceImage) {
    
    [[MLManager sharedInstance] learn:[ImageUtils UIImageFromCVMat:referenceImage]];
    
    return MSERFeatureDetection(videoFrame);
}

/**
 * swtchExposureAction
 * @Description - switches the video camera exposure from locked to unlocked state
 */
- (IBAction)swtchExposureAction:(UISwitch*)sender {
    
    [sender setOn:![sender isOn]];
    
    if(sender.isOn){
        [self.videoCamera lockExposure];
    }else{
     [self.videoCamera unlockExposure];
    }
}

/**
 * swtchFocusAction
 * @Description - switches the video camera focus from locked to unlocked state
 */
- (IBAction)swtchFocusAction:(UISwitch*)sender {
    
    [sender setOn:![sender isOn]];
    
    if(sender.isOn){
        [self.videoCamera lockFocus];
    }else{
        [self.videoCamera unlockFocus];
    }
}

/**
 * selectLogoAction
 * @Description - We upload the different logo images in this method(Note: if you want to insert your own logo to detect
     then make sure it is in the same format as the other logos
     in the image assets i.e. the actual logo occupies only 60% of
     the image in the center location)
 */
- (IBAction)selectLogoAction:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        sampleImage = [UIImage imageNamed:@"N"];
        printf("Netvirta logo");
    } else if(sender.selectedSegmentIndex == 1) {
        sampleImage = [UIImage imageNamed:@"apple"];
        printf("apple logo");
    } else if(sender.selectedSegmentIndex == 2) {
        sampleImage = [UIImage imageNamed:@"coke"];
        printf("coke logo");
    } else if(sender.selectedSegmentIndex == 3) {
        sampleImage = [UIImage imageNamed:@"google"];
        printf("google logo");
    }
}

/**
 * showFarFeaturesAction
 * @Description - turns on all far features
 */
- (IBAction)showFarFeaturesAction:(UISwitch*)sender {
    showFarFeature = sender.on;
}

/**
 * showFarFeaturesAction
 * @Description - turns on all mser features
 */
- (IBAction)showAllMSERsAction:(UISwitch*)sender {
    showAllMSERs = sender.on;
}


// ============================================
// Protocol CvVideoCameraDelegate
// ============================================
/**
 * processImage
 * @Description - delegate method for processing the realtime image obtained from the opencv camera video stream
 **/
- (void)processImage:(Mat&)imageParam {
   
    cv::Mat image =  imageParam.clone();

    Mat sampleImageMat = [self cvMatWithImage: sampleImage];

    cv::Size sizeReferenceImage(sampleImageMat.cols * 0.2, sampleImageMat.rows * 0.4);
    resize(sampleImageMat, sampleImageMat, sizeReferenceImage);
    
    cvtColor(image, image, CV_BGRA2RGB);
    cvtColor(sampleImageMat, sampleImageMat, CV_BGRA2RGB);

    cv::Size size(image.rows * zoomScale, image.cols * zoomScale);
    Mat dst = image;
    
    if(zoomScale != 1.0f){
    resize(image,dst,size);
    }
    
    imageParam = processFrameFeatures(dst, sampleImageMat);
}

/**
 * sldrZoomAdjustmentAction
 * @Description - Adjusts the Zoom of the camera display
 **/
- (IBAction)sldrZoomAdjustmentAction:(UISlider *)sender {
    zoomScale = sender.value;
}

/**
 * cvMatWithImage
 * @Description - Converts UIImage to openCV image cv::Mat type
 **/
-(cv::Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    (kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst) |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

/**
 * UIImageFromCVMat
 * @Description - Converts openCV image cv::Mat type to UIImage
 **/
-(UIImage *)LocalUIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Little | (
                                                   cvMat.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst
                                                   );
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(
                                        cvMat.cols,                 //width
                                        cvMat.rows,                 //height
                                        8,                          //bits per component
                                        8 * cvMat.elemSize(),       //bits per pixel
                                        cvMat.step[0],              //bytesPerRow
                                        colorSpace,                 //colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   //CGDataProviderRef
                                        NULL,                       //decode
                                        false,                      //should interpolate
                                        kCGRenderingIntentDefault   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage; 
}

/**
 * sldrNumberOfFeatureAction
 * @Description - Adjusts the minimum number of features detected to display feature correspondance
 **/
- (IBAction)sldrNumberOfFeatureAction:(UISlider *)sender {
    numberOfGoodMatches = sender.value;
}

/**
 * sgmtResolutionAdjustmentAction
 * @Description - Adjusts the resolution of the video camera
 **/
- (IBAction)sgmtResolutionAdjustmentAction:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    } else if(sender.selectedSegmentIndex == 1) {
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    } else if(sender.selectedSegmentIndex == 2) {
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    }
}

/**
 * btnMenuAction
 * @Description - Displays the main menu
 **/
- (IBAction)btnMenuAction:(id)sender {
    
    isSettingsMenuVisible = !isSettingsMenuVisible;
    settingsMenu.hidden = isSettingsMenuVisible;
}

/**
 * btnShiftCameraAction
 * @Description - Flips between back camera to front camera
 **/
- (IBAction)btnShiftCameraAction:(id)sender {
    
    [_videoCamera stop];
    isBackCamera = !isBackCamera;
    
    if (isBackCamera){
     _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    }else{
    _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    [_videoCamera start];
}

- (IBAction)btnImageGalleryAction:(id)sender {
    [self pickImageFromGallery];
}


/**
 * pickImageFromGallery
 * @Description - Accessess the image gallery to pick the image whose feature are to be corresponded with the video camera frame
 **/
- (void)pickImageFromGallery{

    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
  
    [self presentViewController:pickerController animated:YES completion:nil
     ];
}

// ============================================
// Protocol imagePicker
// ============================================

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    image = [UIImage imageWithCGImage:[image CGImage]
                                scale:(image.scale * 7.0)
                          orientation:(image.imageOrientation)];
    sampleImage = image;
  
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
