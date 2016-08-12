//
//  MP3ObjectsClass.h
//  Mp3Demo
//
//  Created by Adarsh Roy on 08/07/16.
//  Copyright © 2016 INT. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface MP3ObjectsClass : NSObject
@property(nonatomic,retain)NSString *mp3Name;
@property(nonatomic,retain)NSString *mp3Lyrics;
@property(nonatomic,retain)NSURL *mp3Url;
@property(nonatomic,retain)NSString *mp3Duration;
@property(nonatomic,retain)NSString *mp3ArtistName;
@property(nonatomic,retain)NSString *mp3AlbumTitle;
@property(nonatomic,retain)UIImage *mp3Image;
@end
