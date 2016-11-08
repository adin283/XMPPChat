//
//  CTFriendsListTableViewCell.h
//  Chat
//
//  Created by Kevin on 2016/11/4.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTFriendsListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
