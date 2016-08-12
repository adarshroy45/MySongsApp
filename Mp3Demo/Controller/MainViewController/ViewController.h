//
//  ViewController.h
//  Mp3Demo
//
//  Created by Adarsh Roy on 15/06/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import "MarqueeLabel.h"
#import "Mp3ListController.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaPickerController.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,AVAudioPlayerDelegate>{
//    NSURL *assetURL;
    AVAudioPlayer *player;
    NSTimer *sliderTimer;
    NSMutableArray *mp3Array;
    NSMutableArray * directoryContents;
    BOOL playStatus;
}
- (IBAction)btnPlayAction:(id)sender;
//- (IBAction)btnPauseAction:(id)sender;
//- (IBAction)btnStopAction:(id)sender;
- (IBAction)btnShowListAction:(id)sender;
- (IBAction)btnDownloadAction:(id)sender;

@property (weak, nonatomic) IBOutlet MarqueeLabel *lblMp3Name;
@property (weak, nonatomic) IBOutlet UIImageView *mp3Image;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UIImageView *bigMp3Image;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayOutlet;
//@property (weak, nonatomic) IBOutlet UIButton *btnPauseOutlet;
//@property (weak, nonatomic) IBOutlet UIButton *btnStopOutlet;
- (IBAction)btnPreviousAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPreviousOutlet;
- (IBAction)btnNextAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnNextOutlet;
@property (weak, nonatomic) IBOutlet UITextView *mp3Lyrics;

@end

