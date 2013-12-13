/*
 * Copyright 2013 appscape gmbh
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

#import "RMBTStatsViewController.h"

@implementation RMBTStatsViewController

- (void)awakeFromNib {
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_stats_selected"]];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // Call SVWebViewController constructor
    id parent = [super initWithAddress:RMBTLocalizeURLString(RMBT_STATS_URL)];
#pragma unused(parent)
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setOpaque:NO];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {;
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

@end
