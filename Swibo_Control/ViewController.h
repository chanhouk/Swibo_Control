//
//  ViewController.h
//  Swibo_Control
//
//  Created by Hou Kwen Martin Chan on 26/06/14.
//  Copyright (c) 2014 Swibo_Limit. All rights reserved.
//

#import <UIKit/UIKit.h>

// Add Motion Framework
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController

// Add a motion manager property to this app delegate
@property (strong, nonatomic) CMMotionManager *motionManager;

// property for stream ip address label
@property (strong, nonatomic) IBOutlet UILabel *ipaddresslabel;

// property and action for Player 1 button
@property (strong, nonatomic) IBOutlet UIButton *player1button;
-(IBAction) player1action;

// property and action for Player 2 button
@property (strong, nonatomic) IBOutlet UIButton *player2button;
-(IBAction) player2action;

// property for stream state label
@property (strong, nonatomic) IBOutlet UILabel *streamstatelabel;

// property and action for switch
@property (strong, nonatomic) IBOutlet UISwitch *streamswitch;
-(IBAction) streaming;
-(IBAction) switchon;

// property and action for edit ip addres
@property (strong, nonatomic) IBOutlet UIButton *editipbutton;
-(IBAction) editip;

// property and action for edit player 1 port
@property (strong, nonatomic) IBOutlet UIButton *editplayer1portbutton;
-(IBAction) editplayer1port;

// property and action for edit player 2 port
@property (strong, nonatomic) IBOutlet UIButton *editplayer2portbutton;
-(IBAction) editplayer2port;

@property (strong, nonatomic) IBOutlet UILabel *testlabel;

@end
