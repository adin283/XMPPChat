//
//  CTChatDetailTableViewCell.m
//  Chat
//
//  Created by Kevin on 2016/11/9.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CTChatDetailTableViewCell.h"

@implementation CTChatDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.leftLabel.layer.cornerRadius = 5.0;
    self.leftLabel.layer.masksToBounds = YES;
    self.rightLabel.layer.cornerRadius = 5.0;
    self.rightLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
