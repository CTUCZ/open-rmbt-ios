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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RMBTMapOptionsMapViewType) {
    RMBTMapOptionsMapViewTypeStandard = 0,
    RMBTMapOptionsMapViewTypeSatellite,
    RMBTMapOptionsMapViewTypeHybrid
};

@class RMBTMapOptionsOverlay;
@class RMBTMapOptionsFilter;

extern RMBTMapOptionsOverlay* RMBTMapOptionsOverlayAuto;
extern RMBTMapOptionsOverlay* RMBTMapOptionsOverlayHeatmap;
extern RMBTMapOptionsOverlay* RMBTMapOptionsOverlayPoints;
extern RMBTMapOptionsOverlay* RMBTMapOptionsOverlayShapes;

// Type = mobile|cell|browser
@class RMBTMapOptionsSubtype;

@interface RMBTMapOptionsType : NSObject
@property (nonatomic, readonly) NSString *title; // localized
@property (nonatomic, readonly) NSString *identifier; // mobile|cell|browser
@property (nonatomic, readonly) NSArray<RMBTMapOptionsFilter *> *filters;
@property (nonatomic, readonly) NSArray<RMBTMapOptionsSubtype *> *subtypes;
- (instancetype)initWithResponse:(id)response;
- (void)addFilter:(RMBTMapOptionsFilter*)filter;
@end

// Subtype = type + up|down|signal etc. (depending on type)
@interface RMBTMapOptionsSubtype : NSObject
@property (nonatomic, weak) RMBTMapOptionsType* type;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title, *summary, *mapOptions, *overlayType;
- (instancetype)initWithResponse:(id)response;

// TODO: move to map server it's responsibility of the api interface to build this params
- (NSDictionary*)paramsDictionary;
- (NSDictionary*)markerParamsDictionary;

@end

@interface RMBTMapOptions : NSObject

@property (nonatomic, assign) RMBTMapOptionsMapViewType mapViewType;

@property (nonatomic, readonly) NSArray<RMBTMapOptionsType *> *types;
@property (nonatomic, readonly) NSArray<RMBTMapOptionsOverlay *> *overlays;

@property (nonatomic, strong) RMBTMapOptionsSubtype *activeSubtype;
@property (nonatomic, assign) RMBTMapOptionsOverlay *activeOverlay;

- (instancetype)initWithResponse:(NSDictionary*)response;

// Returns dictionary with following keys set, representing information to be shown in the toast
- (NSDictionary*)toastInfo;

- (void)saveSelection;
@end

extern NSString * const RMBTMapOptionsToastInfoTitle;
extern NSString * const RMBTMapOptionsToastInfoKeys;
extern NSString * const RMBTMapOptionsToastInfoValues;
