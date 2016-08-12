//
//  Mp3ListCell.m
//  Mp3Demo
//
//  Created by Adarsh Roy on 08/07/16.
//  Copyright © 2016 INT. All rights reserved.
//

#import "Mp3ListCell.h"

@implementation Mp3ListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [UIView animateKeyframesWithDuration:5 delay:0 options:UIViewKeyframeAnimationOptionRepeat|UIViewAnimationOptionCurveLinear animations:^{
//        //label is my created sample label
//        _mp3Title.frame=CGRectMake(0, _mp3Title.frame.origin.y, _mp3Title.frame.size.width, _mp3Title.frame.size.height);
//        
//    } completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
