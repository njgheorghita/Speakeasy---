//
//  ViewController.m
//  speakez
//
//  Created by Edward Gheorghita on 1/18/15.
//  Copyright (c) 2015 Nick Gheorghita. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize heardTextView;
@synthesize countTextView;
@synthesize counter;
@synthesize startButton;
@synthesize stopButton;
@synthesize sessionId;
@synthesize sessions;
@synthesize sessionIds;
@synthesize hostView;
@synthesize plot;
@synthesize graphLength;
@synthesize onSwitch;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"LIKE", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    
    
    
    NSError *err = [lmGenerator generateRejectingLanguageModelFromArray:words
                                                         withFilesNamed:name
                                                 withOptionalExclusions:nil
                                                        usingVowelsOnly:FALSE
                                                             withWeight:nil
                                                 forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
        // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish Rejecto model.
    

    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
    
    if(err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];


    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    
  
        
    
    [[OEPocketsphinxController sharedInstance] startRealtimeListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Starts the rapid recognition loop. Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to perform Spanish language recognition.
    
    //[[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    
    sessions = [[NSMutableArray alloc]initWithObjects:@"0", nil];
    sessionIds = [[NSMutableArray alloc]initWithCapacity:4];
    
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    [self.view addSubview: hostView];
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 16 )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( -4 ) length:CPTDecimalFromFloat( 8 )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
    
    //adding labels to x/y axis & other styling

    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(7)]];
    [plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(10)]];
    
    graphLength = 1;
    
    onSwitch = [[UISwitch alloc]init];
    [onSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return graphLength; // Our sample graph contains 9 'points'
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // We need to provide an X or Y (this method will be called for each) value for every index
    int x = index;
    int y = [[sessions objectAtIndex:x]integerValue];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return [NSNumber numberWithInt:x];
            break;
        case CPTScatterPlotFieldY:
            return [NSNumber numberWithInt:y];
            break;
        default:
            break;
    }
    return nil;
}
/*
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value, which will, depending on index, be between -4 to 4
        return [NSNumber numberWithInt:x];
    } else {
        // Return y value, for this example we'll be plotting y = x * x
        return [NSNumber numberWithInt:x];
    }
}*/




- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (void) rapidEarsDidReceiveLiveSpeechHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore {
    
    NSInteger recognitionScoreInt = [recognitionScore intValue];
    
   if ([hypothesis isEqualToString:@"LIKE"] && (recognitionScoreInt > -10000))
    {
        counter ++;
        self.heardTextView.text = [NSString stringWithFormat:@"%@", hypothesis];
        self.countTextView.text = [NSString stringWithFormat:@"%li", (long) counter];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        NSLog(@"hypothesis: %@", hypothesis);
        [self pocketsphinxDidSuspendRecognition];
    } else {
        [self pocketsphinxDidStopListening];
    }
}

- (void) rapidEarsDidReceiveFinishedSpeechHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore {
    NSLog(@"rapidEarsDidReceiveFinishedSpeechHypothesis: %@",hypothesis);
    /*if ([hypothesis isEqualToString:@"LIKE"]){
        counter ++;
        self.heardTextView.text = [NSString stringWithFormat:@"%@", hypothesis];
        self.countTextView.text = [NSString stringWithFormat:@"%li", (long) counter];

        NSLog(@"2hypothesis: %@", hypothesis);
    }*/
}

- (IBAction)changeSwitch:(id)sender{
    if([sender isOn]){
        [self pocketsphinxDidStartListening];
        
        counter = 0;
        self.startButton.hidden = TRUE;
        self.stopButton.hidden = FALSE;
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        self.startButton.hidden = FALSE;
        self.stopButton.hidden = TRUE;
        
        self.countTextView.text = [NSString stringWithFormat:@"%li", (long) counter];
        
        
        
        if(counter != 0)
        {
            [sessions addObject:[NSNumber numberWithInt:counter]];
            [sessionIds addObject:[NSNumber numberWithInt:sessionId]];
            NSLog(@"array:%@, sessionId:%@", sessions, sessionIds);
            counter = 0;
            sessionId++;
            graphLength++;
            [self pocketsphinxDidStopListening];
            [plot reloadData];
        }

    }
}


/*
- (IBAction) startButtonAction {
    [self pocketsphinxDidStartListening];

    counter = 0;
    self.startButton.hidden = TRUE;
    self.stopButton.hidden = FALSE;
}

- (IBAction) stopButtonAction {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.startButton.hidden = FALSE;
    self.stopButton.hidden = TRUE;
    
    self.countTextView.text = [NSString stringWithFormat:@"%li", (long) counter];


  
    if(counter != 0)
    {
        [sessions addObject:[NSNumber numberWithInt:counter]];
        [sessionIds addObject:[NSNumber numberWithInt:sessionId]];
    NSLog(@"array:%@, sessionId:%@", sessions, sessionIds);
        counter = 0;
        sessionId++;
        graphLength++;
    [self pocketsphinxDidStopListening];
    [plot reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}*/

@end
