//
//  CTChatDetailViewController.m
//  Chat
//
//  Created by Kevin on 2016/11/9.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CTChatDetailViewController.h"
#import "CTChatDetailTableViewCell.h"
#import "CTChatModel.h"

@interface CTChatDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) CTChatModel *chatModel;

@end

@implementation CTChatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.chatModel = [[CTChatModel alloc] init];
    
    [self.chatModel getMessageHistoryWithJID:self.jid];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewsMessage:) name:@"DidReceiveNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewsMessage:) name:@"DidSendNewMessage" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return [self.chatModel.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTChatDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTChatDetailTableViewCell" forIndexPath:indexPath];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *messageDict = [self.chatModel getChatDictWithIndex:indexPath.row];
    BOOL fromOther = [[messageDict valueForKey:@"from"] boolValue];
    cell.leftLabel.hidden = !fromOther;
    cell.rightLabel.hidden = fromOther;
    
    if (fromOther) {
        cell.leftLabel.text = [messageDict valueForKey:@"strContent"];
    } else {
        cell.rightLabel.text = [messageDict valueForKey:@"strContent"];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - Private

- (IBAction)sendButtonPressed:(UIButton *)sender
{
    NSString *message = self.messageTextField.text;
    self.messageTextField.text = @"";
    [[CTXMPPManager sharedInstance] sendMessage:message toJID:self.jid];
}

- (void)handleNewsMessage:(NSNotification *)notification
{
    [self.chatModel getMessageHistoryWithJID:self.jid];
    [self.tableView reloadData];
}

@end
