//
//  ViewController.h
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 15/04/2018.
//  Copyright 2018 Mohammad Zulqurnain.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>


using namespace cv;

@interface ViewController : UIViewController<UINavigationControllerDelegate,
UIImagePickerControllerDelegate, CvVideoCameraDelegate, UIAlertViewDelegate> {
}
//UI elements declarations
@property IBOutlet UIImageView *cameraView;
@property CvVideoCamera* videoCamera;
@property UIImage *cameraImage;
@property (weak, nonatomic) IBOutlet UIButton *btnHelp;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnShiftCamera;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmtResolutionAdjustment;
@property (weak, nonatomic) IBOutlet UIView *settingsMenu;

//UI elements Actions declarations
- (IBAction)sgmtResolutionAdjustmentAction:(UISegmentedControl*)sender;
- (IBAction)btnMenuAction:(id)sender;
- (IBAction)btnShiftCameraAction:(id)sender;
- (IBAction)sldrNumberOfFeatureAction:(UISlider *)sender;
- (IBAction)sldrZoomAdjustmentAction:(UISlider *)sender;
- (IBAction)swtchExposureAction:(UISwitch*)sender;
- (IBAction)swtchFocusAction:(UISwitch*)sender;
- (IBAction)selectLogoAction:(UISegmentedControl*)sender;
- (IBAction)showFarFeaturesAction:(UISwitch*)sender;
- (IBAction)showAllMSERsAction:(id)sender;


//Method declarations
- (UIImage *)LocalUIImageFromCVMat:(cv::Mat)cvMat ;


@end
