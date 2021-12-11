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

#import <Foundation/Foundation.h>

@class RMBTHistoryResultItem, RMBTHistoryQoSSingleResult;

@interface RMBTHistoryQoSGroupResult : NSObject
@property (nonatomic, readonly) NSString *name, *about;
@property (nonatomic, readonly) NSArray<RMBTHistoryQoSSingleResult*> *tests;
@property (nonatomic, readonly) NSUInteger succeededCount;

+ (NSArray<RMBTHistoryQoSGroupResult*>*)resultsWithResponse:(NSDictionary*)response;
- (RMBTHistoryResultItem*)toResultItem;

+ (NSString*)summarize:(NSArray<RMBTHistoryQoSGroupResult*> *)results withPercentage:(BOOL)percentage;
+ (NSString*)summarizePercents:(NSArray<RMBTHistoryQoSGroupResult*> *)results;

@end
