//
//  ViewController.m
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#import "ViewController.h"
#import "CustomTableViewCell.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *recordedArray;
    NSIndexPath    *clickIndex;
    
    NSMutableArray *playingStateArray;
    
    NSTimer        *playTimer;
    int             count;
    NSIndexPath    *selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *recordTableView;

@end

@implementation ViewController
@synthesize recordTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 0;
    // Do any additional setup after loading the view, typically from a nib.
    recordTableView.delegate = self;
    recordTableView.dataSource = self;
    
    recordTableView.hidden = FALSE;
    recordTableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    stopBtn.enabled = FALSE;
    whatSayBtn.enabled = FALSE;
    
    arrFiles = [[NSMutableArray alloc] init];
    dateArray = [[NSMutableArray alloc] init];
    timeArray = [[NSMutableArray alloc] init];
    playingStateArray = [[NSMutableArray alloc] init];
    
    audioPlayer = [[AVAudioPlayer alloc] init];
    
    actView.hidden = TRUE;
    [actView stopAnimating];
    
    UINib *countryNib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
    [self.recordTableView registerNib:countryNib
         forCellReuseIdentifier:@"customCell"];
}

- (void) viewWillAppear:(BOOL)animated
{
    //Loading the stored files into array.
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"StoredFiles"])
    {
        arrFiles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"StoredFiles"]];
        NSLog(@"Files %@", arrFiles);
        if (arrFiles.count == 0) {
            recordTableView.hidden = YES;
            stateLbl.hidden = NO;
        }
        else{
            recordTableView.hidden = NO;
            stateLbl.hidden = YES;
            
            for (int i = 0; i < arrFiles.count; i++) {
                [playingStateArray addObject:@"No"];
            }
        }
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DateArray"])
    {
        dateArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DateArray"]];
        NSLog(@"DateArray %@", dateArray);
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"TimeArray"])
    {
        timeArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimeArray"]];
        NSLog(@"DateArray %@", timeArray);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (arrFiles.count > 0) {
            [arrFiles removeObjectAtIndex:indexPath.row];
            [dateArray removeObjectAtIndex:indexPath.row];
            [timeArray removeObjectAtIndex:indexPath.row];
            
            [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
            [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
            [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [recordTableView reloadData];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BOOL isPlay;
    isPlay = FALSE;
    
    NSLog(@"Playing %@", playingStateArray);
    if(arrFiles.count > 0)
    {
        for (int i = 0; i < indexPath.row; i++) {
            if ([[playingStateArray objectAtIndex:i] isEqualToString:@"Yes"]) {
                isPlay = TRUE;
                break;
            }
        }
        
        for (NSInteger j = indexPath.row + 1; j < playingStateArray.count; j++) {
            if ([[playingStateArray objectAtIndex:j] isEqualToString:@"Yes"]) {
                isPlay = TRUE;
                break;
            }
        }
        
        if (isPlay == TRUE) {
            
        }
        else{
            if ([[playingStateArray objectAtIndex:indexPath.row] isEqualToString:@"Yes"]) {
                [playingStateArray replaceObjectAtIndex:indexPath.row withObject:@"No"];
                [recordTableView reloadData];
                [audioPlayer stop];
            }
            else{
                [playingStateArray replaceObjectAtIndex:indexPath.row withObject:@"Yes"];
                [recordTableView reloadData];
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil]; // To play audio from speaker
                NSString *strURL = [NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, [arrFiles objectAtIndex:indexPath.row]] ;
                NSURL *url = [NSURL URLWithString:strURL];
                
                audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                audioPlayer.numberOfLoops = 0;
                [audioPlayer setDelegate:self];
                [audioPlayer prepareToPlay];
                [audioPlayer play];
            }
        }
    }
}

- (void)playTimerAction{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrFiles.count == 0) {
        recordTableView.hidden = YES;
        stateLbl.hidden = NO;
    }
    else{
        recordTableView.hidden = NO;
        stateLbl.hidden = YES;
    }
    
    return arrFiles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"customCell";
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    cell.numberLbl.text = [NSString stringWithFormat:@"Record %ld", (long)indexPath.row + 1];
    cell.dateLbl.text = [NSString stringWithFormat:@"%@", [dateArray objectAtIndex:indexPath.row]];
    cell.timeLineLbl.text = [NSString stringWithFormat:@"00:%@", [timeArray objectAtIndex:indexPath.row]];
    
    if ([[playingStateArray objectAtIndex:indexPath.row] isEqualToString:@"No"]) {
        cell.stateImg.image = [UIImage imageNamed:@"playBtn.png"];
    }
    else{
        cell.stateImg.image = [UIImage imageNamed:@"pauseBtn.png"];
    }
    
    return cell;
}

- (IBAction)startBtnClicked:(id)sender {
    recordLbl.text = @"Start to record";
    
    //Start button method. Hiding animations.
    actView.hidden = TRUE;
    [actView stopAnimating];
    
    startBtn.enabled = FALSE;
    stopBtn.enabled = TRUE;
    whatSayBtn.enabled = TRUE;
    
    //Taking current date and time.
    int timestamp = [[NSDate date] timeIntervalSince1970];
    dateString = [NSString stringWithFormat:@"%d", timestamp];
    
    [self startRecording];
}

- (IBAction)recBtnClicked:(id)sender {
    
    actView.hidden = FALSE;
    [actView startAnimating];
    [recorder stop];
    [self fnStopRecordingAndSave];
}

// This is the function for Store Recording button which will store the recording and save it in the file.
- (void) fnStopRecordingAndSave
{
    @try {
        
        NSString *strURL = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, dateString] ;
        NSURL *url = [NSURL URLWithString:strURL];
        
        //Calculating the duration of the current recording.
        audioPlayer =   [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
        [audioPlayer setDelegate:self];
        
        float duration = audioPlayer.duration;
        NSLog(@" fnStopRecordingAndSave Duration here::: %f", audioPlayer.duration);
        
        if(duration < 10.0)
        {
            recordLbl.text = @"Storing...";
            //Creating its Asset.
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                [actView stopAnimating];
                actView.hidden = TRUE;
                
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"Export Failed: %@", [exportSession error] );
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"Export Canceled");
                        
                        break;
                    case AVAssetExportSessionStatusCompleted:
                        NSLog(@"Export COMPLETED...");
                        
                        
                        //Making sure that file has been created
                        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, dateString]];
                        
                        if(fileExists)
                        {
                            if(arrFiles.count > 0)
                            {
                                
                            }
                            else{
                                [arrFiles addObject:dateString];
                                
                                NSDate *currentTime = [NSDate date];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                NSString *date = [dateFormatter stringFromDate:currentTime];
                                
                                [dateArray addObject:date];
                                [playingStateArray addObject:@"No"];
                                
                                NSString *timeline = [NSString stringWithFormat:@"0%d", (int)audioPlayer.duration];
                                [timeArray addObject:timeline];
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoredFiles"];
                        [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DateArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [recordTableView reloadData];
                        
                        recordLbl.text = @"Saved";
                        break;
                    default:
                        NSLog(@"Export Failed");
                        break;
                }
            }];
        }
        else{
            recordLbl.text = @"Storing...";
            //Creating its Asset.
            AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:strURL] options:nil];
            AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
            
            Float64 startTimeInSeconds = audioPlayer.duration-10;
            Float64 durationInSeconds = 10;
            
            //Reducing the duration by 10 seconds
                       
            //Starting the recording again.
            [self performSelector:@selector(fnStartRecordingAgain) withObject:nil afterDelay:3.0];
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                [actView stopAnimating];
                actView.hidden = TRUE;
                
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"Export Failed: %@", [exportSession error] );
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"Export Canceled");
                        
                        break;
                    case AVAssetExportSessionStatusCompleted:
                        NSLog(@"Export COMPLETED...");
                        
                        
                        //Making sure that file has been created
                        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, dateString]];
                        
                        if(fileExists)
                        {
                            if(arrFiles.count > 0)
                            {
                                for(int i = 0; i<arrFiles.count;i++)
                                {
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", arrFiles];
                                    BOOL result = [predicate evaluateWithObject:dateString];
                                    
                                    if(result == FALSE){
                                        [arrFiles addObject:dateString];
                                        
                                        NSDate *currentTime = [NSDate date];
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                        NSString *date = [dateFormatter stringFromDate:currentTime];
                                        
                                        [dateArray addObject:date];
                                        [playingStateArray addObject:@"No"];
                                        [timeArray addObject:@"10"];
                                    }
                                }
                            }
                            else{
                                [arrFiles addObject:dateString];
                                
                                NSDate *currentTime = [NSDate date];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                NSString *date = [dateFormatter stringFromDate:currentTime];
                                
                                [dateArray addObject:date];
                                [playingStateArray addObject:@"No"];
                                [timeArray addObject:@"10"];
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoredFiles"];
                        [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DateArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [recordTableView reloadData];
                        
                        recordLbl.text = @"Saved";
                        break;
                    default:
                        NSLog(@"Export Failed");
                        break;
                }
            }];
        }
    
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
}

- (void) fnStartRecordingAgain
{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    dateString = [NSString stringWithFormat:@"%d", timestamp];
    [self startRecording];
}

- (IBAction)stopBtnClicked:(id)sender {
    recordLbl.text = @"Stop to record";
    
    startBtn.enabled = TRUE;
    stopBtn.enabled = FALSE;
    whatSayBtn.enabled = FALSE;
    
    [self stopRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        NSLog(@"Successful!");
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

// This is called when user click on Start Recording button or when called from Store Recording button's second process.
- (void) startRecording
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@  %@", [err domain], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@  %@", [err domain], [[err userInfo] description]);
        return;
    }
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    
    recorderFilePath = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, dateString] ;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
    
    
    if(!recorder){
        NSLog(@"recorder: %@ %@", [err domain], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable =  audioSession.inputAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    [recorder record];
}

- (void) stopRecording{
    [recorder stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
