//
//  Mp3ListController.m
//  Mp3Demo
//
//  Created by Adarsh Roy on 08/07/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import "AppDelegate.h"
#import "Mp3ListController.h"

@interface Mp3ListController ()

@end

@implementation Mp3ListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mp3ListTableView.tableFooterView=[[UIView alloc] init];
    if(self.mp3Array.count==0){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"No Music Found!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mp3Array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifire=@"Mp3ListCell";
    Mp3ListCell *cell=[self.mp3ListTableView dequeueReusableCellWithIdentifier:identifire];
    int row=(int)indexPath.row;
    MP3ObjectsClass *objMp3=[self.mp3Array objectAtIndex:row];
    cell.mp3Image.image=objMp3.mp3Image;
    cell.mp3Title.text=objMp3.mp3Name;
    cell.mp3Duration.text=[self timeFormatConvertToSeconds:[objMp3.mp3Duration floatValue]];
    cell.mp3Description.text=[NSString stringWithFormat:@"%@, %@",objMp3.mp3AlbumTitle,objMp3.mp3ArtistName];
    cell.mp3Count.text=[NSString stringWithFormat:@"%d",row+1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int row=(int)indexPath.row;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:row forKey:MUSIC_FILE_INDEX];
    NSDictionary *info = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:row]] forKeys:@[MUSIC_FILE_INDEX]];
    [[NSNotificationCenter defaultCenter] postNotificationName:MUSIC_CHANGE_NOTIFICATION object:self userInfo:info];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnCloseAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSString *)timeFormatConvertToSeconds:(float )timeSecs
{
    int totalSeconds=timeSecs ;
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
         [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
