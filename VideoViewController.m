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
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@end

@implementation VideoViewController
{
    AppViewController *appview;
    UIButton *camera;
    UIButton *contacts;
    UIButton *notifications;
    NSInteger buttonIndicate;
    POPSpringAnimation *spring;
    POPBasicAnimation *disappear;
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
    
    self.view.frame = [UIScreen mainScreen].bounds;
    /*-----------------------------------------------------------------------------------------*/
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    

    buttonIndicate = 0;
    /*-----------------------------------------------------------------------------------------*/
    spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    spring.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    spring.springBounciness = 20.f;

    /*----------------------------------------------------------------------------------------*/
    disappear = [POPBasicAnimation animation];
    disappear.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    disappear.toValue = @(0);



    /*-----------------------------------------------------------------------------------------*/
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
    /*-----------------------------------------------------------------------------------------*/
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
     /*-----------------------------------------------------------------------------------------*/
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
    /*-----------------------------------------------------------------------------------------*/

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
 /*
    //Config dark gradient view
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [[UIScreen mainScreen] bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x030303) CGColor], (id)[[UIColor clearColor] CGColor], (id)[UIColorFromRGB(0x030303) CGColor],nil];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];*/
    UIView* backgroundColor = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    backgroundColor.backgroundColor =[UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:.5];
    [self.view addSubview:backgroundColor];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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



-(IBAction)cameraPermission:(id)sender{

    [camera pop_addAnimation:spring forKey:@"springAnimation"];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        // Will get here on both iOS 7 & 8 even though camera permissions weren't required
        // until iOS 8. So for iOS 7 permission will always be granted.
        if (granted) {
            // Permission has been granted. Use dispatch_async for any UI updating
            // code because this block may be executed in a thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                camera.backgroundColor = [UIColor greenColor];
                buttonIndicate++;
                if (buttonIndicate == 3)
                {


                }
               
            });
        } else {
            // Permission has been denied.
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
    [avPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];

    //[self.movieView.layer addSublayer:avPlayerLayer]; // this sets up Video
        
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser
{
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        self.pageControl.currentPage -=1;
    }
    else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight)
    {
        self.pageControl.currentPage +=1;
    }
    NSLog(@" page Control : %lu", (long)self.pageControl.currentPage);
    NSInteger page = self.pageControl.currentPage;
    switch (page)
    {
        case 0:
            _logo.hidden = NO;
            _firstLabel.hidden = NO;
            break;
        case 1:
            _logo.hidden = YES;
            _firstLabel.hidden = YES;
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
