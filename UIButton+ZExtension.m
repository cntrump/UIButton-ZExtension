//
//  UIButton+ZExtension.m
//  
//
//  Created by v on 2020/7/22.
//  Copyright © 2020 v. All rights reserved.
//

#import "UIButton+ZExtension.h"
#import <objc/runtime.h>


static void swizzling(Class cls, SEL originalSelector, SEL swizzledSelector) {
    if (!cls || !originalSelector || !swizzledSelector) {
        return;
    }

    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    if (!originalMethod || !swizzledMethod) {
        return;
    }

    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    if (class_addMethod(cls, originalSelector, swizzledIMP, method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@implementation UIButton (ZExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling(self, @selector(intrinsicContentSize), @selector(_zext_intrinsicContentSize));
        swizzling(self, @selector(sizeToFit), @selector(_zext_sizeToFit));
        swizzling(self, @selector(imageRectForContentRect:), @selector(_zext_imageRectForContentRect:));
        swizzling(self, @selector(titleRectForContentRect:), @selector(_zext_titleRectForContentRect:));
    });
}

- (void)setSpacing:(CGFloat)spacing {
    objc_setAssociatedObject(self, @selector(spacing), @(spacing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (CGFloat)spacing {
    NSNumber *value = objc_getAssociatedObject(self, @selector(spacing));

    return (CGFloat)value.doubleValue;
}

- (void)setDirection:(ZUIButtonDirection)direction {
    objc_setAssociatedObject(self, @selector(direction), @(direction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (ZUIButtonDirection)direction {
    NSNumber *value = objc_getAssociatedObject(self, @selector(direction));

    return (ZUIButtonDirection)value.integerValue;
}

- (CGSize)_zext_intrinsicContentSize {
    CGSize size = [self _zext_intrinsicContentSize];

    CGSize imageSize = self.currentImage.size;
    if ((self.currentTitle.length > 0 || self.currentAttributedTitle.length > 0) &&
        (imageSize.width > 0 && imageSize.height > 0)) {
        size.width += self.spacing;
    }

    return size;
}

- (void)_zext_sizeToFit {
    [self _zext_sizeToFit];

    CGRect bounds = self.bounds;
    bounds.size = [self intrinsicContentSize];
    self.bounds = bounds;

    CGFloat offset = 0;
    CGSize imageSize = self.currentImage.size;
    if ((self.currentTitle.length > 0 || self.currentAttributedTitle.length > 0) &&
        (imageSize.width > 0 && imageSize.height > 0)) {
        offset = self.spacing * 0.5;
    }

    CGPoint center = self.center;
    center.x += offset;
    self.center = center;
}

- (CGRect)_zext_imageRectForContentRect:(CGRect)contentRect {
    CGRect rect = [self _zext_imageRectForContentRect:contentRect];

    if (self.direction == ZUIButtonDirectionRowReverse) {
        CGRect titleRect = [self _zext_titleRectForContentRect:contentRect];
        titleRect.origin.x = rect.origin.x;
        rect.origin.x = CGRectGetMaxX(titleRect);
    }

    if (self.currentTitle.length > 0 || self.currentAttributedTitle.length > 0) {
        if (self.direction == ZUIButtonDirectionRow) {
            rect.origin.x -= self.spacing * 0.5;
        } else if (self.direction == ZUIButtonDirectionRowReverse) {
            rect.origin.x += self.spacing * 0.5;
        }
    }

    return rect;
}

- (CGRect)_zext_titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [self _zext_titleRectForContentRect:contentRect];

    if (self.direction == ZUIButtonDirectionRowReverse) {
        CGRect imageRect = [self _zext_imageRectForContentRect:contentRect];
        rect.origin.x = imageRect.origin.x;
    }

    CGSize imageSize = self.currentImage.size;
    if (imageSize.width > 0 && imageSize.height > 0) {
        if (self.direction == ZUIButtonDirectionRow) {
            rect.origin.x += self.spacing * 0.5;
        } else if (self.direction == ZUIButtonDirectionRowReverse) {
            rect.origin.x -= self.spacing * 0.5;
        }
    }

    return rect;
}

@end
