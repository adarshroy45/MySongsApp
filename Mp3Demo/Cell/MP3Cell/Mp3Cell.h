//
//  Mp3Cell.h
//  Mp3Demo
//
//  Created by Adarsh Roy on 15/06/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import "MarqueeLabel.h"
#import "CustomButton.h"
#import <UIKit/UIKit.h>

@interface Mp3Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblNumber;
@property (weak, nonatomic) IBOutlet MarqueeLabel *lblMp3Name;

@property (weak, nonatomic) IBOutlet CustomButton *btnPlayOutlet;
@property (weak, nonatomic) IBOutlet CustomButton *btnPauseOutlet;
@property (weak, nonatomic) IBOutlet CustomButton *btnStopOutlet;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTotaTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@end
