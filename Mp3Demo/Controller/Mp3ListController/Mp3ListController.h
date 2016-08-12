//
//  Mp3ListController.h
//  Mp3Demo
//
//  Created by Adarsh Roy on 08/07/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import "MP3ObjectsClass.h"
#import "Mp3ListCell.h"
#import <UIKit/UIKit.h>

@interface Mp3ListController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mp3ListTableView;
@property(nonatomic,retain) NSMutableArray *mp3Array;
- (IBAction)btnCloseAction:(id)sender;

@end
