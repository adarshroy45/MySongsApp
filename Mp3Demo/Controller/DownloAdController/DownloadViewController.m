//
//  DownloadViewController.m
//  Mp3Demo
//
//  Created by Adarsh Roy on 15/06/16.
//  Copyright © 2016 INT. All rights reserved.
//

#import "DownloadViewController.h"

@implementation DownloadViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _mp3TableView.tableFooterView=[[UIView alloc] init];
    [self loadMp3OnStart];
    cellIndexPath=nil;
    cellDeleteIndexPath=nil;
    _btnDownloadOutlet.layer.cornerRadius=10.0f;
    self.mp3TableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

}
- (void)keyboardDidShow: (NSNotification *) notification{
    // Do something here
    NSLog(@"Keyboard show...");
    if(!viewUP){
        viewUP=YES;
        [self viewUp];
    }
}

- (void)keyboardDidHide: (NSNotification *) notification{
    // Do something here
    [self keyBoardDown];
}
#pragma mark TouchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self keyBoardDown];
}
#pragma mark ViewUpAndDown methods
- (void)viewUp
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.mp3TableView.frame = CGRectMake(self.mp3TableView.frame.origin.x, self.mp3TableView.frame.origin.y, self.mp3TableView.frame.size.width, self.mp3TableView.frame.size.height-216);
        NSLog(@"main scroll view frame UP=%@",NSStringFromCGRect(self.mp3TableView.frame));
    }];
}
- (void)viewDown
{
    [UIView animateWithDuration:0.3f animations:^{
        self.mp3TableView.frame = CGRectMake(self.mp3TableView.frame.origin.x, self.mp3TableView.frame.origin.y, self.mp3TableView.frame.size.width, self.mp3TableView.frame.size.height+216+55);
        NSLog(@"main scroll view frame DOWN=%@",NSStringFromCGRect(self.mp3TableView.frame));
    }];
}
-(void)keyBoardDown{
    if(viewUP){
        viewUP=NO;
        [self.view endEditing:YES];
        [self viewDown];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (player) {
        [self disableCurrentPlayMP3];
        player=nil;
    }
}
-(void)loadMp3OnStart{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    directoryContents =  [[[NSFileManager defaultManager]
                          contentsOfDirectoryAtPath:documentsDirectory error:&error] mutableCopy];
    
    NSLog(@"directoryContents ====== %@",directoryContents);
    [_mp3TableView reloadData];
}
- (IBAction)btnDownloadAction:(id)sender {
    
    if (_textUrl.text.length <= 0) {
        return;
    }
    NSString *extension = [[_textUrl.text pathExtension] lowercaseString];
    NSLog(@"Extention =%@",extension);
    if([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"aif"] || [extension isEqualToString:@"m4a"] || [extension isEqualToString:@"aac"] || [extension isEqualToString:@"mp4"] || [extension isEqualToString:@"amr"] || [extension isEqualToString:@"flac"] ){
        
        NSArray *urlArray=[_textUrl.text componentsSeparatedByString:@"/"];
        if (urlArray.count>1) {
            NSString *mp3Name=[urlArray lastObject];
            if([self findFileByName:mp3Name]){
                [[[UIAlertView alloc]initWithTitle:@"MY SONGS" message:@"Audio already downloaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }else{
                _downloadOverLay.hidden=NO;
                [SVProgressHUD showWithStatus:@"Downloading Audio... 0%"];
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                
                NSURL *URL = [NSURL URLWithString:_textUrl.text];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                
                NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull taskProgress) {
                    // This is not called back on the main queue.
                    // You are responsible for dispatching to the main queue for UI updates
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Update the progress view
                        int prgs=taskProgress.fractionCompleted*100;
                        NSString *per=@"%";
                        [SVProgressHUD showProgress:taskProgress.fractionCompleted status:[NSString stringWithFormat:@"Downloading Audio... %d%@",prgs,per]] ;
                    });
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                    
                    return [documentsDirectoryURL URLByAppendingPathComponent:[[response suggestedFilename] stringByRemovingPercentEncoding]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    NSLog(@"File downloaded to: %@", filePath);
                    _downloadOverLay.hidden=YES;
                    [SVProgressHUD dismiss];
                    
                    [self keyBoardDown];
                    [self loadMp3OnStart];
                }];
                [downloadTask resume];
            }
        }
        
    }else{
        [[[UIAlertView alloc]initWithTitle:nil message:@"Please give an audio link." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return directoryContents.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Mp3Cell *cell=[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([Mp3Cell class])];
    int row=(int)indexPath.row;
    cell.lblNumber.text=[NSString stringWithFormat:@"%d.",row+1];
    cell.lblMp3Name.text=[directoryContents objectAtIndex:row];
    cell.btnPlayOutlet.cellIndexPath=indexPath;
    cell.btnPauseOutlet.cellIndexPath=indexPath;
//    cell.btnStopOutlet.cellIndexPath=indexPath;
    cell.btnPlayOutlet.userInteractionEnabled=YES;
    if(row==cellIndexPath.row && cellIndexPath !=nil){
        cell.btnPauseOutlet.userInteractionEnabled=YES;
//        cell.btnStopOutlet.userInteractionEnabled=YES;
        cell.lblTotaTime.hidden=NO;
        cell.lblCurrentTime.hidden=NO;
        cell.progressBar.hidden=NO;
//        cell.btnStopOutlet.alpha=1.0f;
        cell.btnPauseOutlet.alpha=1.0f;
    }else{
        cell.btnPauseOutlet.userInteractionEnabled=NO;
//        cell.btnStopOutlet.userInteractionEnabled=NO;
        cell.lblTotaTime.hidden=YES;
        cell.lblCurrentTime.hidden=YES;
        cell.progressBar.hidden=YES;
//        cell.btnStopOutlet.alpha=0.3f;
        cell.btnPauseOutlet.alpha=0.3f;
    }
   
    
    [ cell.btnPlayOutlet addTarget:self action:@selector(btnPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [ cell.btnPauseOutlet addTarget:self action:@selector(btnPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [ cell.btnStopOutlet addTarget:self action:@selector(btnStopAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     Mp3Cell *cell = (Mp3Cell *)[_mp3TableView cellForRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        cellDeleteIndexPath=indexPath;
      UIAlertView *alert =  [[UIAlertView alloc ]initWithTitle:@"MY SONGS" message:[NSString stringWithFormat:@"Do you want to delete %@",cell.lblMp3Name.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        alert.tag=100;
        [alert show];
    }
}
- (void)removeMp3File:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MY SONGS" message:@"Successfully removed." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
- (void)btnPlayAction:(CustomButton *)button {
    
    if (player) {
        [self disableCurrentPlayMP3];
        player=nil;
    }
    Mp3Cell *cell = (Mp3Cell *)[_mp3TableView cellForRowAtIndexPath:button.cellIndexPath];
    cell.btnPauseOutlet.userInteractionEnabled=YES;
//    cell.btnStopOutlet.userInteractionEnabled=YES;
//    cell.btnStopOutlet.alpha=1.0f;
    cell.btnPauseOutlet.alpha=1.0f;
    cellIndexPath=button.cellIndexPath;
    cell.progressBar.hidden=NO;
   
    sliderTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(methodToUpdateProgress) userInfo:nil repeats:YES];
    player=[[AVAudioPlayer alloc]initWithContentsOfURL:[self getFilePathByName:cell.lblMp3Name.text] error:nil];
    player.delegate = self;
    [player play];
    cell.lblTotaTime.hidden=NO;
    cell.lblTotaTime.text=[self timeFormatConvertToSeconds:player.duration];
    cell.lblCurrentTime.hidden=NO;

}

-(void)methodToUpdateProgress{
   Mp3Cell *cell = (Mp3Cell *)[_mp3TableView cellForRowAtIndexPath:cellIndexPath];
   cell.progressBar.progress = ((100.0/player.duration)*player.currentTime)/100;
//    if (player.duration==player.currentTime) {
//        [sliderTimer invalidate];
//        sliderTimer=nil;
//        cell.progressBar.hidden=YES;
//    }
    cell.lblCurrentTime.text=[self timeFormatConvertToSeconds:player.currentTime];
}
- (void)btnPauseAction:(CustomButton *)button {
    if (player.isPlaying) {
        [player pause];
    }else{
        [player play];
    }
}
- (void)btnStopAction:(CustomButton *)button {
//    if (player) {
//        player=nil;
//       [self disableCurrentPlayMP3];
//    }
    
    
}
-(NSURL *)getFilePathByName :(NSString *)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return [NSURL URLWithString:[filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
//     return [NSURL URLWithString:filePath];
}

-(BOOL)findFileByName :(NSString *)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
   return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
#pragma mark - AV Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
   
    [self disableCurrentPlayMP3];
}
-(void)disableCurrentPlayMP3{
    
    Mp3Cell *cell = (Mp3Cell *)[_mp3TableView cellForRowAtIndexPath:cellIndexPath];
    cell.btnPauseOutlet.userInteractionEnabled=NO;
//    cell.btnStopOutlet.userInteractionEnabled=NO;
//    cell.btnStopOutlet.alpha=0.3f;
    cell.btnPauseOutlet.alpha=0.3f;
    cell.progressBar.hidden=YES;
    cell.lblTotaTime.hidden=YES;
    cell.lblCurrentTime.hidden=YES;
    cell.lblTotaTime.text=@"00:00";
    cell.lblCurrentTime.text=@"00:00";
    cell.progressBar.progress =0.0f;
    cellIndexPath=nil;
    if(sliderTimer){
        [sliderTimer invalidate];
        sliderTimer=nil;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    viewUP=NO;
    [self viewDown];
    [textField resignFirstResponder];
    return YES;
}
-(NSString *)timeFormatConvertToSeconds:(float )timeSecs
{
    int totalSeconds=timeSecs ;
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100){
        if(buttonIndex==0){
             Mp3Cell *cell = (Mp3Cell *)[_mp3TableView cellForRowAtIndexPath:cellDeleteIndexPath];
            [self removeMp3File:cell.lblMp3Name.text];
            [directoryContents removeObjectAtIndex:cellDeleteIndexPath.row];
            [_mp3TableView reloadData];
        }else{
           //nothing to do
        }
        cellDeleteIndexPath=nil;
    }
}
- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
