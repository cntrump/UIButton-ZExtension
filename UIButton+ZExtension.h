//
//  UIButton+ZExtension.h
//  
//
//  Created by v on 2020/7/22.
//  Copyright © 2020 v. All rights reserved.
//

#ifndef _UIButton_ZExtension_H
#define _UIButton_ZExtension_H

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZUIButtonDirection) {
    ZUIButtonDirectionRow = 0,    // 默认样式：图像左，文字右
    ZUIButtonDirectionRowReverse  // 文字左，图像右
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ZExtension)

@property(nonatomic) CGFloat spacing;

@property(nonatomic) ZUIButtonDirection direction;

@end

NS_ASSUME_NONNULL_END

#endif // _UIButton_ZExtension_H
