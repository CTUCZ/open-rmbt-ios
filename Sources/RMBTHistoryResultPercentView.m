//
//  RMBTHistoryResultPercentView.m
//  RMBT
//
//  Created by Sergey Glushchenko on 03.09.2020.
//  Copyright © 2020 appscape gmbh. All rights reserved.
//

#import "RMBTHistoryResultPercentView.h"

@implementation RMBTHistoryResultPercentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"traffic_lights_template"];

    CGFloat pointSize = 7;
    NSInteger countPointsHorizontal = self.bounds.size.width / pointSize;
    NSInteger countPointsVertical = 2;
    
    NSInteger countFillPointsHorizontal = (self.bounds.size.width * self.percents) / pointSize;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //Draw mask
    for (NSInteger i = 0; i < countPointsHorizontal; i++) {
        for (NSInteger j = 0; j < countPointsVertical; j++) {
            CGFloat x = i * pointSize;
            CGFloat y = j * pointSize;
            
            CGRect imageRect = CGRectMake(x, y, pointSize, pointSize);
            CGContextDrawImage(context, imageRect, [image CGImage]);
        }
    }
    
    //Create mask
    CGImageRef alphaMask = CGBitmapContextCreateImage(context);
    
    //Append mask
    CGContextClipToMask(context, self.bounds, alphaMask);
    [self.filledColor setFill];
    
    //Draw filled area
    CGRect fillRect = CGRectMake(0, 0, countFillPointsHorizontal * pointSize, self.bounds.size.height);
    CGContextFillRect(context, fillRect);
    
    //Draw unfilled area
    [self.unfilledColor setFill];
    CGRect unfillRect = CGRectMake(countFillPointsHorizontal * pointSize, 0, self.bounds.size.width, self.bounds.size.height);
    CGContextFillRect(context, unfillRect);
}

@end
