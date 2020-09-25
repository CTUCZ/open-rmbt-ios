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

#import "RMBTHistoryQOEResultItemCell.h"
#import "RMBTHistoryResult.h"
#import "UIView+RMBTSubviews.h"
#import "RMBTHistoryResultItemCell.h"

@interface RMBTHistoryQOEResultItemCell()<UITableViewDataSource, UITableViewDelegate> {
    NSArray *_qoeItems;
    BOOL _isTrafficLightInteractionEnabled;
}

@property (nonatomic, readwrite) IBOutlet UITableView *tableView;

@end

@implementation RMBTHistoryQOEResultItemCell

- (void)setQOEResultItems:(NSArray *)qoeItems {
    _qoeItems = qoeItems;
    
    [self.tableView reloadData];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    [self setNeedsLayout];
}


- (void)setTrafficLightInteractionEnabled:(BOOL)state {
    _isTrafficLightInteractionEnabled = state;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _qoeItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellIdentifierResult = @"history_result_cell";
    
    RMBTHistoryQOEResultItem *item = _qoeItems[indexPath.row];
    
    RMBTHistoryResultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierResult];
    if (!cell) {
        cell = [[RMBTHistoryResultItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierResult];
    }
    [cell setQOEItem:item];
    [cell setTrafficLightInteractionEnabled:NO];
    cell.accessoryView = [[UIView alloc] init];
    return cell;
}
@end
