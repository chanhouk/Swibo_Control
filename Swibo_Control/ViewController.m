//
//  ViewController.m
//  Swibo_Control
//
//  Created by Hou Kwen Martin Chan on 26/06/14.
//  Copyright (c) 2014 Swibo_Limit. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define kAlertViewOne 1
#define kAlertViewTwo 2
#define kAlertViewThree 3

float aX;
float aY;
float aZ;

int tag;

NSTimer *timer;
//NSString *ipaddress;
NSInteger player1;
NSInteger player2;
NSInteger activePort;

BOOL player1active;
BOOL player2active;

UITextField *alertTextField1;
UITextField *alertTextField2;
UITextField *alertTextField3;

@interface ViewController ()
{
    GCDAsyncUdpSocket *udpSocket;
}
@end

@implementation ViewController

- (void)setupSocket
{
	// Setup our socket.
	// The socket will invoke our delegate methods using the usual delegate paradigm.
	// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
	//
	// Now we can configure the delegate dispatch queues however we want.
	// We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
	// Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
	//
	// The best approach for your application will depend upon convenience, requirements and performance.
	//
	// For this simple example, we're just going to use the main thread.
	
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	if (![udpSocket bindToPort:0 error:&error])
	{
//		[self logError:FORMAT(@"Error binding: %@", error)];
		return;
	}
	if (![udpSocket beginReceiving:&error])
	{
//		[self logError:FORMAT(@"Error receiving: %@", error)];
		return;
	}
	
//	[self logInfo:@"Ready"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *ipaddress = [defaults objectForKey:@"ipaddress"];
    
    player1 = [defaults integerForKey:@"player1"];
    player2 = [defaults integerForKey:@"player2"];
    
    activePort = player1;
    // Update the UI elements with the saved data
    _ipaddresslabel.text = ipaddress;
    
	if (udpSocket == nil)
	{
		[self setupSocket];
	}

    // Motion Manager
    self.motionManager = [[CMMotionManager alloc] init];
    
//    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
//    CMAttitude *attitude = deviceMotion.attitude;
//    referenceAttitude   = attitude;
    
    [self.motionManager startDeviceMotionUpdates];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchon{
    if(_streamswitch.on){
        timer = [NSTimer scheduledTimerWithTimeInterval:0.03f
                                                 target:self
                                               selector:@selector(streaming)
                                               userInfo:nil
                                                repeats:YES];
    }else{
        [timer invalidate];
    }
}

- (IBAction)streaming
{
    NSString *host = _ipaddresslabel.text;
	if ([host length] == 0)
	{
        	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Need correct ip address"
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
//        alertView.tag = kAlertViewThree;
//        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        alertTextField3 = [alertView textFieldAtIndex:0];
//        alertTextField3.keyboardType = UIKeyboardTypeNumberPad;
//        alertTextField3.placeholder = @"5556";
        [alertView show];
		return;
	}
	
	NSInteger port = activePort;
    // temp port
//    int port = 5555;
	if (port <= 0 || port > 65535)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Need correct ip address"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
		return;
	}
    
    // Both value times -1 to match Android pitch and roll
    aY = (self.motionManager.deviceMotion.attitude.pitch*180/M_PI)*-1;
    aZ = (self.motionManager.deviceMotion.attitude.roll*180/M_PI)*-1;
    
    
    NSString *Mdata = [NSString stringWithFormat:@"%+.3f,%+.3f",aY,aZ];
    
	NSData *data = [Mdata dataUsingEncoding:NSUTF8StringEncoding];
    
        [udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
    
//	[self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, test)];
	
	tag++;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
//		[self logMessage:FORMAT(@"RECV: %@", msg)];
	}
	else
	{
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
		
//		[self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
	}
}

- (IBAction)player1action
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    activePort = [defaults integerForKey:@"player1"];
    [_testlabel setText:[NSString stringWithFormat:@"%ld", (long)activePort]];
}

- (IBAction)player2action
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    activePort = [defaults integerForKey:@"player2"];
    [_testlabel setText:[NSString stringWithFormat:@"%ld", (long)activePort]];
}

- (IBAction)editip
{
    // Need to create a popup box to input the address
    // Temp test
//    NSString *ipaddress = @"192.168.2.10";
//    
//    // Store the data
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    [defaults setObject:ipaddress forKey:@"ipaddress"];
//    
//    [defaults synchronize];
//    
//    _ipaddresslabel.text = [defaults objectForKey:@"ipaddress"];
//    
//    NSLog(@"ip address saved");
    
    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"IP Address"
                                                         message:@"Enter target IP:"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    [alertView1 addButtonWithTitle:@"OK"];
    alertView1.tag = kAlertViewOne;
    alertView1.alertViewStyle = UIAlertViewStylePlainTextInput;
//    alertTextField1.placeholder = @"192.168.0.1";
    alertTextField1.text = @"192.168.";
    alertTextField1 = [alertView1 textFieldAtIndex:8];
    alertTextField1.keyboardType = UIKeyboardTypeDecimalPad;
    [alertView1 show];
}

-(IBAction)editplayer1port{
    
    // Store the data
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    [defaults setInteger:player1 forKey:@"player1"];
//    
//    [defaults synchronize];
//    
//    NSLog(@"player 1 port saved");
    
    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Player 1"
                                                         message:@"Enter player 1 port:"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    [alertView2 addButtonWithTitle:@"OK"];
    alertView2.tag = kAlertViewTwo;
    alertView2.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertTextField2 = [alertView2 textFieldAtIndex:0];
    alertTextField2.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField2.placeholder = @"5555";
    [alertView2 show];
    
}

-(IBAction)editplayer2port{
    UIAlertView *alertView3 = [[UIAlertView alloc] initWithTitle:@"Player 2"
                                                         message:@"Enter player 2 port:"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    [alertView3 addButtonWithTitle:@"OK"];
    alertView3.tag = kAlertViewThree;
    alertView3.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertTextField3 = [alertView3 textFieldAtIndex:0];
    alertTextField3.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField3.placeholder = @"5556";
    [alertView3 show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kAlertViewOne) {
        if (buttonIndex == 1){
            NSString *ipaddress = alertTextField1.text;
            // Store the data
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:ipaddress forKey:@"ipaddress"];
            [defaults synchronize];
            _ipaddresslabel.text = [defaults objectForKey:@"ipaddress"];
        }
    } else if(alertView.tag == kAlertViewTwo) {
        if (buttonIndex ==1){
            int player1 = [alertTextField2.text intValue];
            // Store the data
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:player1 forKey:@"player1"];
            [defaults synchronize];
            
        }
    } else if(alertView.tag == kAlertViewThree) {
        if (buttonIndex ==1){
            int player2 = [alertTextField3.text intValue];
            // Store the data
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:player2 forKey:@"player2"];
            [defaults synchronize];
        }
    }
}

@end
