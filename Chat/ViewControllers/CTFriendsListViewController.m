//
//  CTFriendsListViewController.m
//  Chat
//
//  Created by Kevin on 2016/11/4.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CTFriendsListViewController.h"
#import "CTFriendsListTableViewCell.h"
#import "CTXMPPManager.h"

@interface CTFriendsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *friendsList;

@end

@implementation CTFriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.friendsList = [NSMutableArray array];
    
    [[[CTXMPPManager sharedInstance] xmppRoster] fetchRoster];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChanged) name:@"RosterChanged" object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTFriendsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFriendsListTableViewCell" forIndexPath:indexPath];
    XMPPUserMemoryStorageObject *user = self.friendsList[indexPath.row];
    cell.avatorImageView.image = [UIImage imageNamed:@"UserImage"];
    cell.usernameLabel.text = user.jid.user;
    cell.statusLabel.text = [user isOnline] ? @"在线" : @"离线";
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private

- (void)rosterChanged
{
    NSArray *unsortedUsers = [CTXMPPManager sharedInstance].xmppRosterMemoryStorage.unsortedUsers;
    self.friendsList = [NSMutableArray arrayWithArray:unsortedUsers];
    [self.tableView reloadData];
}
- (IBAction)addButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Friend" message:@"input friend name" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"input friend's name";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *alertTextField = [alertController.textFields firstObject];
        [[CTXMPPManager sharedInstance] addFriendWithName:alertTextField.text];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
