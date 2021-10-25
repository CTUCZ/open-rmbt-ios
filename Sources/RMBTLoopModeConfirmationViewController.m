/*
 * Copyright 2017 appscape gmbh
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "RMBTLoopModeConfirmationViewController.h"
#import "WKWebView+RMBTConfiguration.h"

@interface RMBTLoopModeConfirmationViewController () {
    BOOL _step2;
}

@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@end

@implementation RMBTLoopModeConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.acceptButton setTitle:NSLocalizedString(@"text_button_accept", @"") forState:UIControlStateNormal];
    [self.declineButton setTitle:NSLocalizedString(@"text_button_decline", @"") forState:UIControlStateNormal];
    self.acceptButton.layer.cornerRadius = 8;
    self.declineButton.layer.cornerRadius = 8;
    [self createWebView];
    [self show];
}

- (void)createWebView {
    WKWebView *webView = [WKWebView wideWebViewWithFrame:self.view.bounds];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:webView];
    self.webView = webView;
    
    [NSLayoutConstraint activateConstraints:@[
        [webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [webView.bottomAnchor constraintEqualToAnchor:self.toolbar.topAnchor]
    ]];
}

- (void)show {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.prompt = nil;
    self.navigationItem.title = NSLocalizedString(@"title_loop_instruction_1", @"Confirmation dialog title 1/2");
    NSString *html = @"loop_mode_info";

    if (_step2) {
        self.navigationItem.title = NSLocalizedString(@"title_loop_instruction_2", @"Confirmation dialog title 1/2");
        html = @"loop_mode_info2";
    }

    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:html ofType:@"html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)accept:(id)sender {
    if (!_step2) {
        _step2 = YES;
        [self show];
    } else {
        [self performSegueWithIdentifier:@"accept" sender:self];
    }
}

@end
