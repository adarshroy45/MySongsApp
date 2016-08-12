//
//  Mp3ListCell.h
//  Mp3Demo
//
//  Created by Adarsh Roy on 08/07/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import "MarqueeLabel.h"
#import <UIKit/UIKit.h>

@interface Mp3ListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mp3Image;
@property (weak, nonatomic) IBOutlet MarqueeLabel *mp3Title;
@property (weak, nonatomic) IBOutlet MarqueeLabel *mp3Description;
@property (weak, nonatomic) IBOutlet UILabel *mp3Count;
@property (weak, nonatomic) IBOutlet UILabel *mp3Duration;

@end
