//
//  RMBTHistoryResultPercentView.h
//  RMBT
//
//  Created by Sergey Glushchenko on 03.09.2020.
//  Copyright © 2020 appscape gmbh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMBTHistoryResultPercentView : UIView

@property (nonatomic, assign) CGFloat percents;
@property (nonatomic, strong) UIColor *filledColor;
@property (nonatomic, strong) UIColor *unfilledColor;

@end

NS_ASSUME_NONNULL_END
