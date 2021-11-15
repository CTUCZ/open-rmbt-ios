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

#import "RMBTQoSProgressViewController.h"
#import "RMBT-Swift.h"

@interface RMBTQoSProgressCell ()

@end

@implementation RMBTQoSProgressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.percentView = [[RMBTHistoryResultPercentView alloc] initWithFrame:CGRectZero];
    
    self.percentView.templateImage = [[UIImage imageNamed:@"traffic_lights_small_template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.percentView setHidden:NO];
    [self.percentView setUnfilledColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4]];
    [self.percentView setFilledColor:[UIColor.whiteColor colorWithAlphaComponent:1.0]];
    [self.contentView addSubview:self.percentView];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.percentView.percents = 0.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_percentView.isHidden == NO) {
        CGFloat padding = 20.0f;
        CGFloat width = 95.0f;
        CGFloat height = 11.0f;
        
        _percentView.frame = CGRectMake(self.bounds.size.width - width - padding, (self.bounds.size.height - height) / 2, width, height);
        
        CGFloat widthWithPadding = _percentView.frameWidth + 20.0f;
        self.detailTextLabel.frameRight -= (widthWithPadding - 10.0f);
    }
}

@end

@interface RMBTQoSProgressViewController () {
    NSMutableDictionary *_progressForGroupKey;
}
@end

@implementation RMBTQoSProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = UIColor.clearColor;
}

- (void)updateProgress:(float)progress forGroup:(RMBTQoSTestGroup*)group {
    NSParameterAssert(_progressForGroupKey);
    NSParameterAssert(self.testGroups);

    NSInteger index = [self.testGroups indexOfObject:group];
    if (index != NSNotFound) {
        [_progressForGroupKey setObject:[NSNumber numberWithFloat:progress] forKey:group.key];
        RMBTQoSProgressCell *cell = (RMBTQoSProgressCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.percentView.percents = progress;
        });
    } else {
        NSParameterAssert(false);
    }
}

- (void)setTestGroups:(NSArray<RMBTQoSTestGroup *> *)testGroups {
    _testGroups = testGroups;
    _progressForGroupKey = [NSMutableDictionary dictionary];
    for (RMBTQoSTestGroup *g in testGroups) {
        [_progressForGroupKey setObject:[NSNumber numberWithFloat:0.0f] forKey:g.key];
    }
    [self.tableView reloadData];
}

- (NSString *)progressString {
    NSInteger total = self.testGroups.count;
    NSInteger finished = 0;
    for (RMBTQoSTestGroup *g in self.testGroups) {
        if ([_progressForGroupKey[g.key] floatValue] == 1.0) {
            finished += 1;
        }
    }
    
    return [NSString stringWithFormat:@"%ld/%ld", (long)finished, (long)total];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.testGroups) { return 0; }
    return self.testGroups.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RMBTQoSTestGroup *g = [_testGroups objectAtIndex:indexPath.row];

    RMBTQoSProgressCell *cell = (RMBTQoSProgressCell *)[tableView dequeueReusableCellWithIdentifier:@"qos_progress_cell" forIndexPath:indexPath];
    cell.percentView.percents = [_progressForGroupKey[g.key] floatValue];
    NSString *localizedKey = [NSString stringWithFormat:@"measurement_qos_%@", g.localizedDescription];
    NSString *localized = g.localizedDescription;
    if (![NSLocalizedString(localizedKey, @"") isEqualToString:localizedKey]) {
        localized = NSLocalizedString(localizedKey, @"");
    }
    
    cell.descriptionLabel.text = localized;
    return cell;
}
@end
