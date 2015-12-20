//
//  ViewController.m
//  VideoCover


#import "VideoViewController.h"
#import "AppViewController.h"
#import "NavigationView.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <POP/POP.h>
#import "Parse.h"
#import "Alert.h"
#import <Contacts/Contacts.h>


@interface VideoViewController ()

@property (nonatomic, strong) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation VideoViewController
{
    AppViewController *appview;
    UIButton *camera;
    UIButton *contacts;
    UIButton *notifications;
    NSInteger buttonIndicate;
    UIAlertController * alertController;
    POPSpringAnimation *spring;
    CGFloat center;
    BOOL didLogin;


}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _label2.hidden = YES;
    didLogin = NO;
    self.view.frame = [[UIScreen mainScreen] bounds];
    /*-----------------------------------------------------------------------------------------*/
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    

    
    /*-----------------------------------------------------------------------------------------*/
    spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    //spring.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    spring.springBounciness = 20.f;

    /*----------------------------------------------------------------------------------------*/

    
    
    center = self.view.center.x;

    
    
    camera =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    camera.backgroundColor = [UIColor purpleColor];
    camera.layer.cornerRadius = 10;
    camera.clipsToBounds = YES;
    [camera addTarget:self
                action:@selector(cameraPermission:)
      forControlEvents:UIControlEventTouchUpInside];
    [camera setTitle:@"Allow Camera" forState:UIControlStateNormal];
    camera.frame = CGRectMake(90, 300, 200, 40.0);
    [self.view addSubview:camera
     ];
    camera.hidden = YES;
 
    contacts =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    contacts.backgroundColor = [UIColor purpleColor];
    contacts.layer.cornerRadius = 10;
    contacts.clipsToBounds = YES;
    [contacts addTarget:self
                action:@selector(contactPermission:)
      forControlEvents:UIControlEventTouchUpInside];
    [contacts setTitle:@"Allow Contacts" forState:UIControlStateNormal];
    contacts.frame = CGRectMake(90, 350, 200, 40.0);
    [self.view addSubview:contacts];
    contacts.hidden = YES;
 
    notifications =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    notifications.backgroundColor = [UIColor purpleColor];
    notifications.layer.cornerRadius = 10;
    notifications.clipsToBounds = YES;
    [notifications addTarget:self
                action:@selector(notificationPermission:)
      forControlEvents:UIControlEventTouchUpInside];
    [notifications setTitle:@"Allow Notifications" forState:UIControlStateNormal];
    notifications.frame = CGRectMake(90, 400, 200, 40.0);
    notifications.hidden = YES;
    [self.view addSubview:notifications];
    

    NSError *sessionError = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    [self setUpVideo:@"xx" :@"mp4"];

    
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
 

    
    alertController =[ UIAlertController
                      alertControllerWithTitle:@"Camera access is required"
                      message:@" To continue, you must enable camera access in the Settings app."
                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       _label2.text = @" Sorry but we cannot continue";
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Launch Settings"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                   _label2.text = @" Ready to continue?";
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!didLogin)
    {
    self.pageControl.currentPage = 0;
    }
    else
    {
        self.pageControl.currentPage = 5;
    }
    [self.avplayer play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerStartPlaying
{
    [self.avplayer play];
}



-(void)cameraPermission
{
    
    //[camera pop_addAnimation:spring forKey:@"springAnimation"];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        // Will get here on both iOS 7 & 8 even though camera permissions weren't required
        // until iOS 8. So for iOS 7 permission will always be granted.
        if (granted) {
            // Permission has been granted. Use dispatch_async for any UI updating
            // code because this block may be executed in a thread.
            dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            // Permission has been denied.
            dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertController animated:YES completion:nil];
            });
        }
    }];
    
    
}

-(IBAction)contactPermission:(id)sender
{

    [contacts pop_addAnimation:spring forKey:@"springAnimation"];
    
    CNContactStore* addressBook = [[CNContactStore alloc]init];
    CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if(permissions == CNAuthorizationStatusNotDetermined) {
        
        [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable contactError) {
            
            if (granted)
            {
                contacts.backgroundColor = [UIColor greenColor];
                buttonIndicate++;
                if (buttonIndicate == 3)
                {

                }
            }
            else
            {}
        }];
    }

    
}

-(IBAction)notificationPermission:(id)sender
{
 
    [notifications pop_addAnimation:spring forKey:@"springAnimation"];
    if (!ParseCheckPermissionForRemoteNotifications())
    {

                  ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
                                                      {
                                                          notifications.backgroundColor = [UIColor greenColor];
                                                          buttonIndicate++;
                                                          if (buttonIndicate == 3)
                                                          {

                                                          }
                                                      });
            
    }

}

-(void)setUpVideo:(NSString*)fileName :(NSString*)extension
{
    if (self.movieView.window != nil)
    {
        [self.movieView.window removeFromSuperview];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:extension]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    [avPlayerLayer setFrame:self.view.frame];
    
    self.movieView.alpha = 0.4;
    [self.movieView.layer insertSublayer:avPlayerLayer atIndex:0]; // this sets up Video
        
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser
{
    POPBasicAnimation *disappear;
    disappear = [POPBasicAnimation animation];
    disappear.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    disappear.toValue = @(0);
    
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        if (!(self.pageControl.currentPage == 0))
        {
            
            [disappear setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                if (finished)
                {
                    POPSpringAnimation *appear = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
                    appear.toValue = @(0.4);
                    [self.movieView pop_addAnimation:appear forKey:@"appear"];
                }
            }];
            
            [self.movieView pop_addAnimation:disappear forKey:@"disappear"];
            
            
            
            
            
        }
    }
        else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight)
        {
            if (!(self.pageControl.currentPage == 4))
            {
                
                [disappear setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                    if (finished)
                    {
                        POPBasicAnimation *appear = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
                        appear.toValue = @(0.4);
                        [self.movieView pop_addAnimation:appear forKey:@"appear"];
                    }
                }];
                [self.movieView pop_addAnimation:disappear forKey:@"disappear"];
                
                
            }
            
        }
        

    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft)
    {

        self.pageControl.currentPage -=1;

    }
    else if  ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight)
    {

        self.pageControl.currentPage +=1;

    }
    

    
    NSLog(@" page Control : %lu", (long)self.pageControl.currentPage);
    NSInteger page = self.pageControl.currentPage;
    NSString *string;
    NSString *string2;
    switch (page)
    {
        case 0:
            _logo.hidden = NO;
            _firstLabel.hidden = NO;
            _label2.hidden = YES;
            break;
        case 1:
            _logo.hidden = YES;
            _firstLabel.hidden = YES;
            _label2.hidden = NO;
            _label2.text = @"Type something important then press face to attach a selfie";
            break;
        case 2:
            _label2.text = @"Press and hold the recipients' name to send the message";
            break;
        case 3:
            _label2.text = @"Press and hold the sender's name to read the message";
            break;
        case 4:
            string = @"This is how you practice safe text";
            string2 = @"Ready to typeface?";
            _label2.text = [NSString stringWithFormat:@"%@\r%@", string,string2];
           
            [self cameraPermission];
            
            break;
        default:
            break;
    }

    

    
        

    


    
    

}

-(void)waitUntilDone:(void(^)(void))waitBlock {
    //use your statement or call method here
    if(waitBlock){
        waitBlock();
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
