//
//  CTChatModel.m
//  Chat
//
//  Created by Kevin on 2016/11/9.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CTChatModel.h"

@implementation CTChatModel

- (void)getMessageHistoryWithJID:(XMPPJID *)jid
{
    self.dataSource = [NSMutableArray array];
    XMPPMessageArchivingCoreDataStorage *storage = [CTXMPPManager sharedInstance].xmppMessageArchivingCoreDataStorage;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", jid.bare];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        for (NSInteger i = 0; i < [fetchedObjects count]; i++) {
            XMPPMessageArchiving_Message_CoreDataObject *recordMessage = fetchedObjects[i];
            BOOL fromOthers = recordMessage.message.from ? YES : NO;
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
            dataDict[@"from"] = @(fromOthers);
            dataDict[@"strTime"] = [recordMessage.timestamp description];
            dataDict[@"strName"] = fromOthers ? recordMessage.bareJidStr : [CTXMPPManager sharedInstance].myJID.user;
            dataDict[@"strContent"] = recordMessage.body;
            [self.dataSource addObject:dataDict];
        }
    }
}

- (NSDictionary *)getChatDictWithIndex:(NSInteger)index
{
    if ([self.dataSource count] > index) {
        return self.dataSource[index];
    }
    return nil;
}

@end
