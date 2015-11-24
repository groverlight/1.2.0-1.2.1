
//! \file   SendToFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "SendToFriendSelectionView.h"
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
#import "FriendSelectionView.h"
#import "VideoViewController.h"
#import "BDKCollectionIndexView.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.

@implementation SendToFriendSelectionView

{
    NSInteger SelectedFriend;
    UITableView *tableView;
    NSMutableArray *sectionTitles;
    NSMutableArray *sectionPeople;
    NSMutableArray *person;
    BDKCollectionIndexView *indexView;
}

//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
    [super Initialize];

  GlobalParameters* parameters  = GetGlobalParameters();
  ListName.text                 = parameters.friendsSendToLabelTitle;
  self.showSectionHeaders       = YES;
  self.useBlankState            = NO;
  self.ignoreUnreadMessages     = YES;
  self.maxNumRecentFriends      = GetGlobalParameters().friendsMaxRecentFriends;

}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}


//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)updateFriendsLists
{
    NSArray * indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    self->indexView = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(self.window.width-28,self.window.height,28,self.window.height) indexTitles: indexTitles];
    NSLog(@"INDEX VIEW FRAME2: %@", NSStringFromCGRect(self->indexView.frame));
    
    [self addSubview:self->indexView];

  self.recentFriends  = GetTimeSortedFriendRecords();
   // NSLog(@"contacts: %@", contactsNotUsers);
    self.allFriends     = contactsNotUsers;
  self->FriendsList.contentOffset = CGPointMake(0, 0- FriendsList.contentInset.top);
    
  [self->FriendsList ReloadTableData];



}
//__________________________________________________________________________________________________

@end
