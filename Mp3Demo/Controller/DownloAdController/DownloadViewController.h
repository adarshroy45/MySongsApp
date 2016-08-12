//
//  DownloadViewController.h
//  Mp3Demo
//
//  Created by Adarsh Roy on 15/06/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomButton.h"
#import "Mp3Cell.h"
#import "AFURLSessionManager.h"
#import <UIKit/UIKit.h>

@interface DownloadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate,UITextFieldDelegate,UIAlertViewDelegate>{
    NSMutableArray * directoryContents ;
    AVAudioPlayer *player;
    NSIndexPath *cellIndexPath;
    NSIndexPath *cellDeleteIndexPath;
    NSTimer *sliderTimer;
    BOOL viewUP;
}
- (IBAction)btnDownloadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textUrl;
@property (weak, nonatomic) IBOutlet UITableView *mp3TableView;
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadOutlet;
@property (weak, nonatomic) IBOutlet UIView *downloadOverLay;
- (IBAction)btnBackAction:(id)sender;


@end
