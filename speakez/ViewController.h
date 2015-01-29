//
//  ViewController.h
//  speakez
//
//  Created by Edward Gheorghita on 1/18/15.
//  Copyright (c) 2015 Nick Gheorghita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <RejectoDemo/OELanguageModelGenerator+Rejecto.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <RapidEarsDemo/OEPocketsphinxController+RapidEars.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>
#import <RapidEarsDemo/OEEventsObserver+RapidEars.h>
#import <AudioToolbox/AudioServices.h>
#import "CorePlot-CocoaTouch.h"





@interface ViewController : UIViewController <OEEventsObserverDelegate, CPTPlotDataSource> {
    
    NSInteger counter;
    NSInteger sessionId;
    NSInteger graphLength;
    NSMutableArray *sessions;
    NSMutableArray *sessionIds;
    CPTScatterPlot *plot;

    IBOutlet UITextField *heardTextView;
    IBOutlet UITextField *countTextView;
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *stopButton;
    IBOutlet UISwitch *onSwitch;
    
    IBOutlet CPTGraphHostingView *hostView;
    
}

- (IBAction)stopButtonAction;
- (IBAction)startButtonAction;



@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) IBOutlet UITextField *heardTextView;
@property (strong, nonatomic) IBOutlet UITextField *countTextView;
@property (strong, nonatomic) IBOutlet UIButton * startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UISwitch *onSwitch;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, assign) NSInteger sessionId;
@property (nonatomic, assign) NSInteger graphLength;
@property (strong, nonatomic) NSMutableArray *sessions;
@property (strong, nonatomic) NSMutableArray *sessionIds;
@property (strong, nonatomic) CPTGraphHostingView *hostView;
@property (strong, nonatomic) CPTScatterPlot *plot;


@end




