//
//  ViewController.h
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UIButton *whatSayBtn;
    IBOutlet UIButton *startBtn;
    IBOutlet UIButton *stopBtn;
    IBOutlet UIActivityIndicatorView *actView;
    IBOutlet UILabel *stateLbl;
    
    IBOutlet UILabel *recordLbl;
    
    NSString *recorderFilePath, *dateString;
    NSMutableArray *arrFiles;
    NSMutableArray *dateArray;
    NSMutableArray *timeArray;
    
    NSMutableDictionary *recordSetting;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer  *audioPlayer;
}

@end

