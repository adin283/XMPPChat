//
//  CTLoginViewController.m
//  Chat
//
//  Created by Kevin on 2016/11/3.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CTLoginViewController.h"
#import "CTXMPPManager.h"

@interface CTLoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    #warning 提交的时候记得删除默认账号密码
    self.usernameTextField.text = @"zhuwenbo";
    self.passwordTextField.text = @"881211";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:CTXMPPManagerLoginSuccessNotificationName object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginButtonPressed:(UIButton *)sender {
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (username.length == 0 || password.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入用户名和密码"];
        return;
    }
    
    [[CTXMPPManager sharedInstance] loginWithName:username password:password];
    
}

- (void)loginSuccess
{
    [self performSegueWithIdentifier:@"LoginSuccess" sender:nil];
}

@end
