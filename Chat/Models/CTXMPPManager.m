//
//  CTXMPPManager.m
//  Chat
//
//  Created by Kevin on 2016/11/3.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CTXMPPManager.h"

NSString * const XMPPHost = @"kevinrmbp15.local";
NSString * const XMPDomain = @"kevinrmbp15.local";
NSInteger const XMPPPort = 5222;
NSInteger const XMPPKeepAliveInterval = 30;
NSString * const CTXMPPManagerLoginSuccessNotificationName = @"CTXMPPManagerLoginSuccessNotificationName";

@interface CTXMPPManager () <XMPPStreamDelegate, XMPPRosterMemoryStorageDelegate, XMPPIncomingFileTransferDelegate, XMPPRosterDelegate>

@end

@implementation CTXMPPManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setupStream];
    });
    
    return sharedInstance;
}

- (void)setupStream
{
    if (!_xmppStream) {
        self.xmppStream = [[XMPPStream alloc] init];
        
        [self.xmppStream setHostName:XMPPHost];
        [self.xmppStream setHostPort:XMPPPort];
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppStream setKeepAliveInterval:XMPPKeepAliveInterval];
        self.xmppStream.enableBackgroundingOnSocket = YES;
        
        self.xmppReconnect = [[XMPPReconnect alloc] init];
        [self.xmppReconnect setAutoReconnect:YES];
        [self.xmppReconnect activate:self.xmppStream];
        
        self.storage = [[XMPPStreamManagementMemoryStorage alloc] init];
        self.xmppStreamManagement = [[XMPPStreamManagement alloc] initWithStorage:self.storage];
        self.xmppStreamManagement.autoResume = YES;
        [self.xmppStreamManagement addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppStreamManagement activate:self.xmppStream];
        
        self.xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterMemoryStorage];
        [self.xmppRoster activate:self.xmppStream];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        self.xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        [self.xmppMessageArchiving activate:self.xmppStream];
    }
}

- (void)loginWithName:(NSString *)username password:(NSString *)password
{
    self.myJID = [XMPPJID jidWithUser:username domain:XMPDomain resource:@"iOS"];
    self.myPassword = password;
    [self.xmppStream setMyJID:self.myJID];
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } else {
        NSLog(@"连接成功");
    }
}

- (void)logout
{
    [self goOffline];
    [self.xmppStream disconnectAfterSending];
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)xmppJID
{
    XMPPMessage *xmppMessage = [[XMPPMessage alloc] initWithType:@"chat" to:xmppJID];
    [xmppMessage addBody:message];
    [self.xmppStream sendElement:xmppMessage];
}

- (void)addFriendWithName:(NSString *)name
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", name, XMPPHost]];
    [self.xmppRoster subscribePresenceToUser:jid];
}

- (void)removeBuddyWithName:(NSString *)name
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", name, XMPPHost]];
    [self.xmppRoster removeUser:jid];
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"%s - %@", __func__, @"1. socket连接成功");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"2. 已连接 xmppStreamDidConnect");
    NSError *error = nil;
    // 验证密码
    if (![self.xmppStream authenticateWithPassword:self.myPassword error:&error]) {
        NSLog(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"%s - %@", __func__, error);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"%s, %@", __func__, @"3. 密码校验成功");
    [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
    NSLog(@"did auth presence:%@", presence);
    [[NSNotificationCenter defaultCenter] postNotificationName:CTXMPPManagerLoginSuccessNotificationName object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"%s, %@", __func__, @"3. 密码校验失败");
    [SVProgressHUD showErrorWithStatus:@"验证失败"];
    // 下线 & 断开连接
    [self logout];
}

#pragma mark -- XMPPMessage Delegate

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"%s - %@", __func__, message);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveNewMessage"
                                                        object:self
                                                      userInfo:nil];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"%s - %@", __FUNCTION__, message);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSendNewMessage"
                                                        object:self
                                                      userInfo:nil];
    
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"%s - %@", __FUNCTION__, message);
}

#pragma mark -- Roster Delegate

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"好友状态：%@", presence);
    NSString *presenceType = [presence type];
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"%@ is %@", presenceFromUser, presenceType);
    if (![presenceFromUser isEqualToString:[[sender myJID] user]]) {
        if ([presenceType isEqualToString:@"available"]) {
            
        } else if ([presenceType isEqualToString:@"away"]) {
            
        } else if ([presenceType isEqualToString:@"do not disturb"]) {
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            
        }
    }
}

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RosterChanged" object:nil];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer
{
    NSLog(@"%s", __FUNCTION__);
    [self.xmppIncomingFileTransfer acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name
{
    #warning jid 获取
    XMPPJID *jid = self.myJID;
    NSString *subject;
    NSString *extension = [name pathExtension];
    if ([@"amr" isEqualToString:extension]) {
        subject = @"voice";
    } else if ([@"jpg" isEqualToString:extension]) {
        subject = @"picture";
    }
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addAttributeWithName:@"from" stringValue:jid.bare];
    [message addSubject:subject];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    path = [path stringByAppendingPathExtension:extension];
    [data writeToFile:path atomically:YES];
    
    [message addBody:path.lastPathComponent];
    
    [self.xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:self.xmppStream];
}

#pragma mark - XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type];
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"didReceivePresenceSubscriptionRequest:%@ - %@", presenceType, presenceFromUser);
    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

#pragma mark - Private


- (void)applicationWillTerminate
{
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskId;
    
    taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:taskId];
    }];
    
    if (taskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    [self.xmppStream disconnectAfterSending];
}

@end
