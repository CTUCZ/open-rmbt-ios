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

#import <TUSafariActivity/TUSafariActivity.h>

#import "RMBTHistoryResultViewController.h"
#import "RMBTHistoryResultDetailsViewController.h"
#import "RMBTHistoryQoSGroupResult.h"
#import "RMBTHistoryQoSGroupViewController.h"
#import "RMBTMapViewController.h"
#import "RMBTSettings.h"
#import "RMBTHistoryResultItemCell.h"
#import "RMBTHistorySpeedGraphCell.h"
#import "RMBTHistoryQOEResultItemCell.h"

#import "UIViewController+ModalBrowser.h"
#import <Blockskit/NSArray+BlocksKit.h>

// cellatindex -> item | download graph | upload graph

@interface RMBTHistoryResultViewController() {
    NSArray *_measurementItems;
    NSArray *_qosItems;

    // These are added to the above _measurementItems array if we find measurement item with
    // title "Download" or "Upload" to mimic the physical layout of the table. The value they contain
    // is the index of the measurement item they show the graph for in the above array:
    NSNumber  * _Nullable _downloadItemIndex, *_uploadItemIndex, *_qosItemIndex;
}
@property (nonatomic, assign) BOOL downloadSpeedGraphExpanded, uploadSpeedGraphExpanded, qosExpanded;
@end

@implementation RMBTHistoryResultViewController

- (void)viewDidLoad {
    NSParameterAssert(_historyResult);

    self.footerView.hidden = YES;

    
    [_historyResult ensureBasicDetails:^{
        NSAssert(_historyResult.dataState != RMBTHistoryResultDataStateIndex, @"Result not filled with basic data");

        NSMutableArray *items = [NSMutableArray array];
        __block NSUInteger shift = 0;
        [_historyResult.measurementItems enumerateObjectsUsingBlock:^(RMBTHistoryResultItem*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            [items addObject:item];
            if (!_downloadItemIndex && [item.title isEqualToString:@"Download"]) {
                _downloadItemIndex = @(idx+shift);
                shift++;
                [items addObject:_downloadItemIndex];
            } else if (!_uploadItemIndex && [item.title isEqualToString:@"Upload"]) {
                _uploadItemIndex = @(idx+shift);
                shift++;
                [items addObject:_uploadItemIndex];
            }
        }];

        // Add a summary "Quality tests 100% (90/90)" row
        if (_historyResult.qosResults) {
            _qosItems = _historyResult.qoeClassificationItems;
        }

        _measurementItems = items;

        [_historyResult ensureSpeedGraph:^{
            NSMutableArray *idxs = [NSMutableArray array];
            if (_downloadItemIndex) {
                [idxs addObject:[NSIndexPath indexPathForRow:[_downloadItemIndex integerValue] + 1 inSection:0]];
            }
            if (_uploadItemIndex) {
                [idxs addObject:[NSIndexPath indexPathForRow:[_uploadItemIndex integerValue] + 1 inSection:0]];
            }
            [self.tableView reloadRowsAtIndexPaths:idxs withRowAnimation:UITableViewRowAnimationNone];
        }];

        if (CLLocationCoordinate2DIsValid(_historyResult.coordinate)) {
            self.mapButton.enabled = YES;
        }

        [self.loadingIndicatorView stopAnimating];
        self.shareButton.enabled = YES;
        self.footerView.hidden = NO;
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_historyResult.dataState == RMBTHistoryResultDataStateIndex) {
        return 0;
    } else if (_historyResult.qosResults) {
        return 4;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellIdentifierResult = @"history_result_cell";
    static NSString * const cellIdentifierGraph = @"speed_graph_cell";

    RMBTHistoryResultItem *item = [[self itemsForSection:indexPath.section] objectAtIndex:indexPath.row];

    if (item == (RMBTHistoryResultItem *)_uploadItemIndex || item == (RMBTHistoryResultItem *)_downloadItemIndex) { // note: this a pointer comparison
        RMBTHistorySpeedGraphCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierGraph forIndexPath:indexPath];
        RMBTHistorySpeedGraph *graph = (item == (RMBTHistoryResultItem *)_downloadItemIndex) ? _historyResult.downloadGraph : _historyResult.uploadGraph;
        [cell drawSpeedGraph:graph];
        return cell;
    } else if ([item isKindOfClass:[RMBTHistoryQOEResultItem class]]) {
        RMBTHistoryResultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierResult];
        [cell setQOEItem:(RMBTHistoryQOEResultItem *)item];
        return cell;
    } else {
        RMBTHistoryResultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierResult];
        if (!cell) {
            cell = [[RMBTHistoryResultItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierResult];
        }
        [cell setItem:item];
        [cell setTrafficLightInteractionEnabled:NO];
        if (indexPath.section == 0) {
            if ((_downloadItemIndex && indexPath.row == [_downloadItemIndex integerValue]) ||
                (_uploadItemIndex && indexPath.row == [_uploadItemIndex integerValue]) ||
                (_qosItemIndex && indexPath.row == [_qosItemIndex integerValue])) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                // For measurements that we don't have a graph for, just show an empty placeholder to keep alignment:
                cell.accessoryView = [[UIView alloc] init];
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BOOL toggled = NO;
        NSInteger row = indexPath.row;
        if (_downloadItemIndex && indexPath.row == [_downloadItemIndex integerValue]) {
            self.downloadSpeedGraphExpanded = !self.downloadSpeedGraphExpanded;
            [(RMBTHistoryResultItemCell *)[tableView cellForRowAtIndexPath:indexPath] setAccessoryRotated:self.downloadSpeedGraphExpanded];
            toggled = YES;
            row = indexPath.row+1;
        } else if (_uploadItemIndex && indexPath.row == [_uploadItemIndex integerValue]) {
            self.uploadSpeedGraphExpanded = !self.uploadSpeedGraphExpanded;
            [(RMBTHistoryResultItemCell *)[tableView cellForRowAtIndexPath:indexPath] setAccessoryRotated:self.uploadSpeedGraphExpanded];
            toggled = YES;
            row = indexPath.row+1;
        }
        if (toggled) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:indexPath.section]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if ((indexPath.section == 3) && (indexPath.row > 0)) {
        [self performSegueWithIdentifier:@"show_qos_group" sender:[_historyResult.qosResults objectAtIndex:indexPath.row - 1]];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && _downloadItemIndex && indexPath.row == [_downloadItemIndex integerValue]+1) {
        return self.downloadSpeedGraphExpanded ? 120.0f : 0.0;
    } else if (indexPath.section == 0 && _uploadItemIndex && indexPath.row == [_uploadItemIndex integerValue]+1) {
        return self.uploadSpeedGraphExpanded ? 120.0f : 0.0;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self itemsForSection:section].count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return NSLocalizedString(@"Measurement", @"History result section title");
        case 1: return NSLocalizedString(@"Network", @"History result section title");
        case 2: return NSLocalizedString(@"Quality", @"History result section title");
        case 3: return NSLocalizedString(@"QoS", @"History result section title");
        default:
            NSAssert(false, @"Invalid section");
            return @"";
    }
}

- (NSArray*)itemsForSection:(NSUInteger)sectionIndex {
    switch (sectionIndex) {
        case 0:
            return _measurementItems;
        case 1:
            return _historyResult.netItems;
        case 2: {
            return _historyResult.qoeClassificationItems;
        }
        case 3: {
            NSArray *qosResults = [_historyResult.qosResults bk_map:^id(RMBTHistoryQoSGroupResult* qr) {
                return [qr toResultItem];
            }];
            
            if (qosResults.count > 0) {
                NSString *summary = [RMBTHistoryQoSGroupResult summarize:_historyResult.qosResults withPercentage:YES];
                NSString *percents = [RMBTHistoryQoSGroupResult summarizePercents:_historyResult.qosResults];
                NSInteger classification = [RMBTHistoryResultItem classification:percents.doubleValue];
                RMBTHistoryResultItem *item = [[RMBTHistoryResultItem alloc]
                                               initWithTitle:NSLocalizedString(@"qos", @"qos")
                                               value:summary
                                               classification:classification
                                               hasDetails:YES];
                
                return [@[item] arrayByAddingObjectsFromArray:qosResults];
            }
            return qosResults;
        }
        default:
            NSParameterAssert(false);
            return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show_result_details"]) {
        RMBTHistoryResultDetailsViewController *rdvc = segue.destinationViewController;
        rdvc.historyResult = self.historyResult;
    } else if ([segue.identifier isEqualToString:@"show_qos_group"]) {
        RMBTHistoryQoSGroupViewController *vc = segue.destinationViewController;
        vc.result = (RMBTHistoryQoSGroupResult*)sender;
    } else if ([segue.identifier isEqualToString:@"show_map"]) {
        NSAssert(CLLocationCoordinate2DIsValid(_historyResult.coordinate), @"Invalid coordinate but map button was enabled");
        if(CLLocationCoordinate2DIsValid(_historyResult.coordinate)) {
            // Set map options
            RMBTMapOptionsSelection* selection = [RMBTSettings sharedSettings].mapOptionsSelection;
            selection.activeFilters = nil;
            selection.overlayIdentifier = nil;
            selection.subtypeIdentifier = RMBTNetworkTypeIdentifier(_historyResult.networkType);

            RMBTMapViewController *mvc = segue.destinationViewController;
            mvc.hidesBottomBarWhenPushed = YES;
            mvc.initialLocation = [[CLLocation alloc] initWithLatitude:_historyResult.coordinate.latitude longitude:_historyResult.coordinate.longitude];
        }
    }
}

- (IBAction)share:(id)sender {
    NSMutableArray *activities = [NSMutableArray array];
    NSMutableArray *items = [NSMutableArray array];
    if (self.historyResult.shareText) [items addObject:self.historyResult.shareText];
    if (self.historyResult.shareURL) {
        [items addObject:self.historyResult.shareURL];
        [activities addObject:[[TUSafariActivity alloc] init]];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activities];
    [activityViewController setValue:RMBTAppTitle() forKey:@"subject"];

    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
