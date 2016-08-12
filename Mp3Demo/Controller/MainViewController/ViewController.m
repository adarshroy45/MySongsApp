//
//  ViewController.m
//  Mp3Demo
//
//  Created by Adarsh Roy on 15/06/16.
//  Copyright © 2016 INT. All rights reserved.
//

#import "MP3ObjectsClass.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _btnPlayOutlet.userInteractionEnabled=NO;
//    _btnPauseOutlet.userInteractionEnabled=NO;
//    _btnStopOutlet.userInteractionEnabled=NO;
    _lblMp3Name.hidden=YES;
    _lblTotalTime.hidden=YES;
    _lblCurrentTime.hidden=YES;
    _slider.hidden=YES;
    _btnPlayOutlet.alpha=0.3f;
//    _btnPauseOutlet.alpha=0.3f;
//    _btnStopOutlet.alpha=0.3f;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePlayerSong:) name:MUSIC_CHANGE_NOTIFICATION object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    mp3Array=[[NSMutableArray alloc] init];
    [self loadDeviceMusic];
    [self getAllDocumentMediaFileName];
    NSLog(@"directoryContents ====== %@",directoryContents);
    for (int i=0; i<[directoryContents count]; i++) {
        NSURL *pathUrl=[self getFilePathByName:[directoryContents objectAtIndex:i]];
        //test
//        assetURL=pathUrl;
        //
        if(pathUrl){
            [mp3Array addObject:[self musicFileDetails:pathUrl :[directoryContents objectAtIndex:i]]];
        }
    }
    NSLog(@"MP3 ARRAY=%@",mp3Array);
   
    if(mp3Array.count==0){
//        [[[UIAlertView alloc]initWithTitle:nil message:@"No Music Found!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
    }else{
        NSSortDescriptor *descr=[[NSSortDescriptor alloc] initWithKey:@"mp3Name" ascending:YES];
        mp3Array=[[mp3Array sortedArrayUsingDescriptors:@[descr]] mutableCopy];
        if(player==nil){
            NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
            [self playMusicWithIndex:(int)[userDefaults integerForKey:MUSIC_FILE_INDEX]];
        }else{
            
        }
        
    }
}
-(void)changePlayerSong :(NSNotification *)notification{
    NSDictionary *userInfo=notification.userInfo;
    int index=[[userInfo valueForKey:MUSIC_FILE_INDEX] intValue];
    NSLog(@"%d",index);
    [self playMusicWithIndex:index];
    playStatus=NO;
    [self btnPlayAction:nil];
}
-(void)loadDeviceMusic{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    [everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
        AVAsset *asset = [AVAsset assetWithURL:assetURL];
        NSLog(@"SONGS URL=%@",assetURL);
        if ([asset hasProtectedContent] == NO) {
            MP3ObjectsClass *objMp3=[[MP3ObjectsClass alloc] init];
            objMp3.mp3Url=assetURL;
           
            objMp3.mp3Duration=[song valueForProperty: MPMediaItemPropertyPlaybackDuration];
            
            if([song valueForProperty: MPMediaItemPropertyTitle]){
                objMp3.mp3Name=[song valueForProperty: MPMediaItemPropertyTitle];
            }else{
                objMp3.mp3Name=@"Unknown";
            }
            if([song valueForProperty: MPMediaItemPropertyArtist]){
                objMp3.mp3ArtistName=[song valueForProperty: MPMediaItemPropertyArtist];
            }else{
                objMp3.mp3ArtistName=@"Unknown";
            }
            if([song valueForProperty: MPMediaItemPropertyAlbumTitle]){
                objMp3.mp3AlbumTitle=[song valueForProperty: MPMediaItemPropertyAlbumTitle];
            }else{
                objMp3.mp3AlbumTitle=@"Unknown";
            }
            UIImage *mp3Image=[self getAlbumnArtWorkImage:assetURL];
            if(mp3Image){
                objMp3.mp3Image=mp3Image;
            }else{
                objMp3.mp3Image=[UIImage imageNamed:@"DefaultImage"];
            }
            AVAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
            NSString *lysrics=[asset lyrics];
            if(lysrics){
                objMp3.mp3Lyrics=lysrics;
            }else{
                objMp3.mp3Lyrics=@"";
            }
//            if(songURL && [song valueForProperty: MPMediaItemPropertyPlaybackDuration]){
            [mp3Array addObject:objMp3];
//            }
        }
    }
}
-(void)playMusicWithIndex :(int)index{
    MP3ObjectsClass *objMp3=[mp3Array objectAtIndex:index];
    self.lblMp3Name.text = objMp3.mp3Name;
    self.mp3Image.image = objMp3.mp3Image;
    self.bigMp3Image.image = objMp3.mp3Image;
    //test
//    [self getAlbumnArtWork:assetURL];
    
    _btnPlayOutlet.userInteractionEnabled=YES;
//    _btnPauseOutlet.userInteractionEnabled=YES;
//    _btnStopOutlet.userInteractionEnabled=YES;
    _btnPlayOutlet.alpha=1.0f;
//    _btnPauseOutlet.alpha=1.0f;
//    _btnStopOutlet.alpha=1.0f;
    _lblMp3Name.hidden=NO;
    _lblTotalTime.hidden=NO;
    _lblCurrentTime.hidden=NO;
    _slider.hidden=NO;
    if (player) {
        player=nil;
    }
    player=[[AVAudioPlayer alloc]initWithContentsOfURL:objMp3.mp3Url error:nil];
    player.delegate = self;
    _lblTotalTime.text=[self timeFormatConvertToSeconds:player.duration];
    _lblCurrentTime.text=@"00:00";
    _slider.minimumValue=0.0f;
    _slider.maximumValue = player.duration;
}
-(void)getAllDocumentMediaFileName{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    directoryContents =[[[NSFileManager defaultManager]
                                             contentsOfDirectoryAtPath:documentsDirectory error:&error] mutableCopy];
}

-(MP3ObjectsClass *)musicFileDetails:(NSURL *)pathUrl :(NSString *)mp3Name{

    AVAsset *asset = [AVURLAsset URLAssetWithURL:pathUrl options:nil];
    NSString *lysrics=[asset lyrics];
    NSArray *metadata = [asset commonMetadata];
    MP3ObjectsClass *mp3Obj=[[MP3ObjectsClass alloc] init];
    mp3Obj.mp3Url=pathUrl;
    NSString *duration=[ self audioFileDuration:pathUrl];
    mp3Obj.mp3Name=mp3Name;
    mp3Obj.mp3Duration=duration;
    if(lysrics){
        mp3Obj.mp3Lyrics=lysrics;
    }else{
        mp3Obj.mp3Lyrics=@"";
    }
    if(metadata.count==0){
        mp3Obj.mp3ArtistName=@"Unknown";
        mp3Obj.mp3AlbumTitle=@"Unknown";
        mp3Obj.mp3Image=[UIImage imageNamed:@"DefaultImage"];
    }else{
        for (AVMetadataItem *item in metadata) {
            if ([[item commonKey] isEqualToString:@"title"]) {
                mp3Obj.mp3Name = (NSString *)[item value];
            }else{
                mp3Obj.mp3Name=@"Unknown";
            }
            if ([[item commonKey] isEqualToString:@"artist"]) {
                mp3Obj.mp3ArtistName  = (NSString *)[item value];
            }else{
                mp3Obj.mp3ArtistName=@"Unknown";
            }
            if ([[item commonKey] isEqualToString:@"albumName"]) {
                mp3Obj.mp3AlbumTitle = (NSString *)[item value];
            }else{
                mp3Obj.mp3AlbumTitle=@"Unknown";
            }
            UIImage *img=nil;
            if ([[item commonKey] isEqualToString:@"artwork"]) {
                NSData *data = [(NSDictionary *)[item value] objectForKey:@"data"];
                img = [UIImage imageWithData:data] ;
                continue;
            }
            if(img){
                mp3Obj.mp3Image=img;
            }else{
                mp3Obj.mp3Image=[UIImage imageNamed:@"DefaultImage"];
            }
        }
    }
  
    return mp3Obj;
}

-(UIImage *)getAlbumnArtWorkImage :(NSURL *)mp3Url{
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:mp3Url options:nil];
    UIImage *img = nil;
    for (NSString *format in [asset availableMetadataFormats]) {
        for (AVMetadataItem *item in [asset metadataForFormat:format]) {
            if ([[item commonKey] isEqualToString:@"artwork"]) {
                img = [UIImage imageWithData:[item.value copyWithZone:nil]];
            }
        }
    }
    return img;
}

-(NSString *)audioFileDuration :(NSURL *)pathUrl{
    NSError *error = nil;
    AVAudioPlayer* avAudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:pathUrl error:&error];
    NSString *duration=[NSString stringWithFormat:@"%f",avAudioPlayer.duration];
    avAudioPlayer=nil;
    return duration;
}

-(NSURL *)getFilePathByName :(NSString *)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return [NSURL URLWithString:[filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
{
    if (theEvent.type == UIEventTypeRemoteControl)
    {
        switch(theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"Play/Pause");
//                if(sliderTimer){
//                    if (player.isPlaying) {
//                        [player pause];
//                    }else{
//                        [player play];
//                    }
//                }else{
//                    [self btnPlayAction:nil];
//                }
                
//                playStatus=NO;
                [self btnPlayAction:nil];
                break;
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"Play");
                playStatus=NO;
                [self btnPlayAction:nil];
//                playStatus=
//                [player play];
//                sliderTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(methodToUpdateProgress) userInfo:nil repeats:YES];
                break;
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"Pause");
                playStatus=YES;
                [self btnPlayAction:nil];
//                if (player.isPlaying) {
//                    [player pause];
//                }
                break;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"Stop");
//                [self btnStopAction:nil];
                break;
            default:
                return;
        }
        
        
//        if(!playStatus){
//            self.btnPlayOutlet.selected=YES;
//        }else{
//            self.btnPlayOutlet.selected=NO;
//        }
//        playStatus = !playStatus;
    }
}

//- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    MPMediaItem *item = [mediaItemCollection representativeItem];
//    assetURL=[item valueForProperty:MPMediaItemPropertyAssetURL];
//
//    [self getAlbumnArtWork:assetURL];
//    _btnPlayOutlet.userInteractionEnabled=YES;
//    _btnPauseOutlet.userInteractionEnabled=YES;
//    _btnStopOutlet.userInteractionEnabled=YES;
//    _btnPlayOutlet.alpha=1.0f;
//    _btnPauseOutlet.alpha=1.0f;
//    _btnStopOutlet.alpha=1.0f;
//    _lblMp3Name.hidden=NO;
//    _lblTotalTime.hidden=NO;
//    _lblCurrentTime.hidden=NO;
//     _slider.hidden=NO;
//    if (player) {
//        player=nil;
//    }
//     player=[[AVAudioPlayer alloc]initWithContentsOfURL:assetURL error:nil];
//     player.delegate = self;
//    _lblTotalTime.text=[self timeFormatConvertToSeconds:player.duration];
//    _lblCurrentTime.text=@"00:00";
//    _slider.minimumValue=0.0f;
//    _slider.maximumValue = player.duration;
//
//}
//
//- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

-(void)methodToUpdateProgress{
    [_slider setValue:player.currentTime animated:YES];
    _lblCurrentTime.text=[self timeFormatConvertToSeconds:player.currentTime];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    player.currentTime = sender.value;
    [_slider setValue:player.currentTime animated:YES];
}

- (IBAction)btnPlayAction:(id)sender {
    if(!playStatus){
        self.btnPlayOutlet.selected=YES;
        [player play];
        sliderTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(methodToUpdateProgress) userInfo:nil repeats:YES];
    }else{
         self.btnPlayOutlet.selected=NO;
        [player pause];
    }
    playStatus = !playStatus;
    
//    [self.btnPlayOutlet setImage:[UIImage imageNamed:playStatus ? @"pauseBig" :@"playBig"] forState:UIControlStateNormal];
}

//- (IBAction)btnPauseAction:(id)sender {
//    if (player.isPlaying) {
//        
//    }else{
//        [player play];
//    }
//}

- (IBAction)btnStopAction:(id)sender {
//    if (player) {
//        player=nil;
//        if(sliderTimer){
//            [sliderTimer invalidate];
//            sliderTimer=nil;
//        }
//    }
}
#pragma mark - AV Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)players successfully:(BOOL)flag {
    if(sliderTimer){
        [sliderTimer invalidate];
        sliderTimer=nil;
        _lblTotalTime.text=[self timeFormatConvertToSeconds:players.duration];
        _lblCurrentTime.text=@"00:00";
        [_slider setValue:player.currentTime animated:YES];
    }
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    int musicIndex=(int)[userDefaults integerForKey:MUSIC_FILE_INDEX];
    
    if(musicIndex>=0 && musicIndex< mp3Array.count-1){
        [userDefaults setInteger:musicIndex+1 forKey:MUSIC_FILE_INDEX];
        [self playMusicWithIndex:musicIndex+1];
    }else{
        [userDefaults setInteger:0 forKey:MUSIC_FILE_INDEX];
        [self playMusicWithIndex:0];
    }
    playStatus=NO;
    [self btnPlayAction:nil];
    
    
}

- (IBAction)btnShowListAction:(id)sender {
    
    Mp3ListController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"Mp3ListController"];
    vc.mp3Array=mp3Array;
    [self presentViewController:vc animated:YES completion:nil];
//    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
//    mediaPicker.delegate = self;
//    mediaPicker.allowsPickingMultipleItems = YES;
//    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (IBAction)btnDownloadAction:(id)sender {
//    if (player) {
//        player=nil;
//    }
    DownloadViewController *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"DownloadViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

//-(void)getAlbumnArtWork :(NSURL *)mp3Url{
//
//    AVAsset *asset = [AVURLAsset URLAssetWithURL:mp3Url options:nil];
//   
//    NSArray *metadata=[asset availableMetadataFormats];
//    for (NSString *format in metadata) {
//        for (AVMetadataItem *item in [asset metadataForFormat:format]) {
//            if ([[item commonKey] isEqualToString:@"title"]) {
//                self.lblMp3Name.text= (NSString *)[item value];
//            }
//            if ([[item commonKey] isEqualToString:@"artist"]) {
//                NSLog(@"Artist =%@",(NSString *)[item value]);
//            }
//            if ([[item commonKey] isEqualToString:@"albumName"]) {
//                NSLog(@"Album Name =%@",(NSString *)[item value]);
//            }
//            if ([[item commonKey] isEqualToString:@"artwork"]) {
//                UIImage *img = nil;
////                if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
//                    img = [UIImage imageWithData:[item.value copyWithZone:nil]];
////                }
////                else { // if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
////                    NSData *data = [item value] objectForKey:@"data"];
////                    img = [UIImage imageWithData:data]  ;
////                }
//                self.mp3Image.image = img;
//                self.bigMp3Image.image = img;
//                
//            }
//        }
//    }
//}


-(NSString *)timeFormatConvertToSeconds:(float )timeSecs
{
    int totalSeconds=timeSecs ;
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}
- (IBAction)btnPreviousAction:(id)sender {
   
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    int musicIndex=(int)[userDefaults integerForKey:MUSIC_FILE_INDEX];
    
    if(musicIndex>0 && musicIndex< mp3Array.count){
        [userDefaults setInteger:musicIndex-1 forKey:MUSIC_FILE_INDEX];
        [self playMusicWithIndex:musicIndex-1];
        playStatus=NO;
        [self btnPlayAction:nil];
    }
   
}
- (IBAction)btnNextAction:(id)sender {
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    int musicIndex=(int)[userDefaults integerForKey:MUSIC_FILE_INDEX];
    if(musicIndex>=0 && musicIndex< (int)mp3Array.count-1){
        [userDefaults setInteger:musicIndex+1 forKey:MUSIC_FILE_INDEX];
        [self playMusicWithIndex:musicIndex+1];
        playStatus=NO;
        [self btnPlayAction:nil];
    }
}

@end
