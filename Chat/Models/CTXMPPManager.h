//
//  CTXMPPManager.h
//  Chat
//
//  Created by Kevin on 2016/11/3.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPP.h>
#import <XMPPFramework/XMPPReconnect.h>
#import <XMPPFramework/XMPPStreamManagement.h>
#import <XMPPFramework/XMPPStreamManagementMemoryStorage.h>
#import <XMPPFramework/XMPPRosterMemoryStorage.h>
#import <XMPPFramework/XMPPMessageArchiving.h>
#import <XMPPFramework/XMPPMessageArchivingCoreDataStorage.h>
#import <XMPPFramework/XMPPIncomingFileTransfer.h>
#import <XMPPFramework/XMPPOutgoingFileTransfer.h>

extern NSString * const CTXMPPManagerLoginSuccessNotificationName;


@interface CTXMPPManager : NSObject

@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (copy, nonatomic) NSString *myPassword;
@property (strong, nonatomic) XMPPJID *myJID;

@property (strong, nonatomic) XMPPStreamManagementMemoryStorage *storage;
@property (strong, nonatomic) XMPPStreamManagement *xmppStreamManagement;

@property (strong, nonatomic) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;

@property (strong, nonatomic) XMPPRoster *xmppRoster;
@property (strong, nonatomic) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;

@property (strong, nonatomic) XMPPMessageArchiving *xmppMessageArchiving;
@property (strong, nonatomic) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

+ (instancetype)sharedInstance;

- (void)loginWithName:(NSString *)username password:(NSString *)password;
- (void)logout;
- (void)goOnline;
- (void)goOffline;
- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)xmppJID;
- (void)addFriendWithName:(NSString *)name;
- (void)removeBuddyWithName:(NSString *)name;

@end
