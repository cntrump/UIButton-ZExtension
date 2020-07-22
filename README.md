# UIButton+ZExtension

众所周知，`UIButton` 是不支持设置图像和文字间距的。

网上的文章大多数都是通过调节 `titleEdgeInsets` 和 `imageEdgeInsets` 达到把图像和文字分开的目的，但是这个方法并不能自动改变按钮的大小，所以带来的问题就是调整了间距之后还需要再计算按钮的大小，而且对于 AutoLayout 无法进行自动适应大小。

要解决这些痛点，比较合适的方式是对 `UIButton` 子类化，增加一个 `spacing` 属性，要设置间距就直接改变 `spacing` 的值就好了，定义如下：

```objc
@interface ZUIButton : UIButton

@property(nonatomic) CGFloat spacing;

@end
```

因为增加间距后就改变了按钮的大小，所以还需要同时调整 `intrinsicContentSize` 和 `sizeToFit` 的实现，这样就可以完美兼容 AutoLayout 和基于 frame 的手动布局：

```objc
- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];

    CGSize imageSize = self.currentImage.size;
    if ((self.currentTitle.length > 0 || self.currentAttributedTitle.length > 0) &&
        (imageSize.width > 0 && imageSize.height > 0)) {
        size.width += _spacing;
    }

    return size;
}
```

```objc
- (void)sizeToFit {
    [super sizeToFit];

    CGRect bounds = self.bounds;
    bounds.size = [self intrinsicContentSize];
    self.bounds = bounds;

    CGFloat offset = 0;
    CGSize imageSize = self.currentImage.size;
    if ((self.currentTitle.length > 0 || self.currentAttributedTitle.length > 0) &&
        (imageSize.width > 0 && imageSize.height > 0)) {
        offset = _spacing * 0.5;
    }

    CGPoint center = self.center;
    center.x += offset;
    self.center = center;
}
```

这样子类化后的 `ZUIButton` 就可以很方便通过 `spacing` 设置间距。

再进一步做扩展：支持设置图像和文字的位置。默认情况下按钮只能是图像左文字右的样式，有时候会遇到需要文字左图像右的场景，就无法满足了。

继续对 `ZUIButton` 扩展，支持文字左图像右的显示样式。

图像和文字的显示区域是由 `imageRectForContentRect` 和 `titleRectForContentRect` 决定的，只要继承这两个方法，在内部调换一下坐标就可以了，很简单。

增加一个枚举类型 `ZUIButtonDirection` 用于设置显示方向：

```objc
typedef NS_ENUM(NSInteger, ZUIButtonDirection) {
    ZUIButtonDirectionRow = 0,    // 默认样式：图像左，文字右
    ZUIButtonDirectionRowReverse  // 文字左，图像右
};
```

新增一个设置显示方向的属性：`direction`

```objc
@interface ZUIButton : UIButton

@property(nonatomic) CGFloat spacing;

@property(nonatomic) ZUIButtonDirection direction;

@end
```

根据 `direction` 的设置重新调整图像和文字的位置：

```objc
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super imageRectForContentRect:contentRect];

    if (_direction == ZUIButtonDirectionRowReverse) {
        CGRect titleRect = [super titleRectForContentRect:contentRect];
        titleRect.origin.x = rect.origin.x;
        rect.origin.x = CGRectGetMaxX(titleRect);
    }

    if (self.currentTitle.length > 0 || self.currentAttributedTitle.length > 0) {
        if (_direction == ZUIButtonDirectionRow) {
            rect.origin.x -= _spacing * 0.5;
        } else if (_direction == ZUIButtonDirectionRowReverse) {
            rect.origin.x += _spacing * 0.5;
        }
    }

    return rect;
}
```

```objc
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super titleRectForContentRect:contentRect];

    if (_direction == ZUIButtonDirectionRowReverse) {
        CGRect imageRect = [super imageRectForContentRect:contentRect];
        rect.origin.x = imageRect.origin.x;
    }

    CGSize imageSize = self.currentImage.size;
    if (imageSize.width > 0 && imageSize.height > 0) {
        if (_direction == ZUIButtonDirectionRow) {
            rect.origin.x += _spacing * 0.5;
        } else if (_direction == ZUIButtonDirectionRowReverse) {
            rect.origin.x -= _spacing * 0.5;
        }
    }

    return rect;
}
```

现在，`ZUIButton` 用起来就很方便了。

不想把现有项目里的 `UIButton` 改成 `ZUIButton` ？来试一下 Method Swizzling 实现的版本，把以上实现做成 `UIButton` 的分类：

https://github.com/cntrump/UIButton-ZExtension
