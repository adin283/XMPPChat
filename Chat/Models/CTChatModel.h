//
//  CTChatModel.h
//  Chat
//
//  Created by Kevin on 2016/11/9.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTXMPPManager.h"

@interface CTChatModel : NSObject

@property (strong, nonatomic) NSMutableArray *dataSource;

//- (void)populateRandomDataSource;
- (void)getMessageHistoryWithJID:(XMPPJID*)jid;
//- (void)addSpecifiedItem:(NSDictionary *)dic;
- (NSDictionary *)getChatDictWithIndex:(NSInteger)index;

@end
