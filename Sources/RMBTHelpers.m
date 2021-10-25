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

#import <mach/mach_time.h>
#import "RMBTHelpers.h"

NSString *RMBTPreferredLanguage() {
    NSString *mostPreferredLanguage = [[NSLocale preferredLanguages] firstObject];
    return [[[mostPreferredLanguage componentsSeparatedByString:@"-"] firstObject] lowercaseString];
}

NSUInteger RMBTPercent(NSInteger count, NSInteger totalCount) {
    double percent = (totalCount == 0) ? 0 : (double)count * 100 / (double)totalCount;
    if (percent < 0) percent = 0;
    return (NSUInteger)round(percent);
}

NSString *RMBTChomp(NSString* string) {
    NSInteger l = [string length];
    while (l>0) {
        NSString *c = [string substringWithRange:NSMakeRange(l-1, 1)];
        if (!([c isEqualToString:@"\r"] || [c isEqualToString:@"\n"])) {
            break;
        }
        l--;
    }
    NSString* result = [string substringToIndex:l];
    return result;
}

NSString *RMBTFormatNumber(NSNumber *number) {
    static NSNumberFormatter *formatter;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.decimalSeparator = @".";
        formatter.usesSignificantDigits = YES;
        formatter.minimumSignificantDigits = 2;
        formatter.maximumSignificantDigits = 2;
    });
    return [formatter stringFromNumber:number];
}

BOOL RMBTIsRunningGermanLocale() {
    return [RMBTPreferredLanguage() isEqualToString:@"de"];
}

RMBTFormFactor RMBTGetFormFactor() {
    CGFloat h = MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    if (h >= 736.0f) {
        return RMBTFormFactoriPhone6Plus;
    } else if (h>= 667.0f) {
        return RMBTFormFactoriPhone6;
    } else if (h >= 568.0f) {
        return RMBTFormFactoriPhone5;
    } else {
        return RMBTFormFactoriPhone4;
    }
}

NSString* RMBTReformatHexIdentifier(NSString* identifier) {
    if (!identifier) return nil;
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSString *c in [identifier componentsSeparatedByString:@":"]) {
        if (c.length == 0) {
            [tmp addObject:@"00"];
        } else if (c.length == 1) {
            [tmp addObject:[NSString stringWithFormat:@"0%@", c]];
        } else {
            [tmp addObject:c];
        }
    }
    return [tmp componentsJoinedByString:@":"];
}

NSString* RMBTAppTitle() {
    static NSString* appName = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id infoDictionary = [[NSBundle mainBundle] localizedInfoDictionary];
        appName = infoDictionary[@"CFBundleDisplayName"];
    });
    return appName;
}

NSString* RMBTMillisecondsStringWithNanos(uint64_t nanos, BOOL withMS) {
    NSNumber *ms = [NSNumber numberWithDouble:((double)nanos * 1.0e-6)];
    if (withMS) {
        return [NSString stringWithFormat:@"%@ ms", RMBTFormatNumber(ms)];
    } else {
        return [NSString stringWithFormat:@"%@", RMBTFormatNumber(ms)];
    }
}

NSString* RMBTSecondsStringWithNanos(uint64_t nanos) {
    return [NSString stringWithFormat:@"%f s", (double)nanos * 1.0e-9];
}

NSNumber* RMBTTimestampWithNSDate(NSDate* date) {
    return [NSNumber numberWithUnsignedLongLong:(unsigned long long)([date timeIntervalSince1970] * 1000ull)];
}

uint64_t RMBTCurrentNanos() {
    static dispatch_once_t onceToken;
    static mach_timebase_info_data_t info;
    dispatch_once(&onceToken, ^{
        mach_timebase_info(&info);
    });

	uint64_t now = mach_absolute_time();
	now *= info.numer;
	now /= info.denom;

    return now;
}

NSString* RMBTBuildInfoString() {
    static NSString *buildInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        buildInfo = [NSString stringWithFormat:@"%@-%@-%@", info[@"GitBranch"], info[@"GitCommitCount"], info[@"GitCommit"]];
    });
    return buildInfo;
}

NSString* RMBTBuildDateString() {
    static NSString *buildDate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        buildDate = info[@"BuildDate"];
    });
    return buildDate;
}

NSString* RMBTLocalizeURLString(NSString* urlString) {
    NSRange r = [urlString rangeOfString:@"$lang"];
    if (r.location != NSNotFound) {
        NSString *lang = RMBTPreferredLanguage();
        if (!(lang && ([lang isEqualToString:@"de"] || [lang isEqualToString:@"en"]))) {
            lang = @"en";
        }
        return [urlString stringByReplacingOccurrencesOfString:@"$lang" withString:lang];
    } else {
        return [NSString stringWithString:urlString];
    }
}

NSString* RMBTMMSSStringWithInterval(NSTimeInterval interval) {
    NSInteger ti = (NSInteger)interval;
    NSInteger minutes = ti / 60;
    NSInteger seconds = ti - (minutes * 60);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

NSString *RMBTMegabytesString(uint64_t bytes) {
    return [NSString stringWithFormat:@"%.2f MB", (double)bytes/(1000*1000)];
}

NSNumber* RMBTMedian(NSArray<NSNumber*>* values) {
    NSArray *sorted = [values sortedArrayUsingSelector:@selector(compare:)];
    NSUInteger count = [sorted count];
    if (count == 0) {
        return nil;
    } else if (count % 2 == 0) {
        // even
        NSUInteger m = (count/2);
        return @(([[sorted objectAtIndex:m] longLongValue] + [[sorted objectAtIndex:m-1] longLongValue])/2);
    } else {
        // odd, take the middle
        NSUInteger m = ((count + 1) / 2) - 1; // 9 -> 10/2 - 1 = 5 - 1 = 4 (index); 1 -> 2/2 - 1 = 0 (index)
        return [sorted objectAtIndex:m];
    }
}
