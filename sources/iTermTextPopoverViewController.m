//
//  iTermTextPopoverViewController.m
//  iTerm2
//
//  Created by George Nachman on 1/21/19.
//

#import "iTermTextPopoverViewController.h"

#import "SolidColorView.h"

const CGFloat iTermTextPopoverViewControllerHorizontalMarginWidth = 4;

@interface iTermTextPopoverViewController ()

@end

@implementation iTermTextPopoverViewController

- (void)appendString:(NSString *)string {
    if (!string.length) {
        return;
    }
    NSDictionary *attributes = @{ NSFontAttributeName: self.textView.font,
                                  NSForegroundColorAttributeName: self.textView.textColor ?: [NSColor textColor] };
    [_textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attributes]];
}

- (NSSize)marginSize {
    NSScrollView *scrollView = _textView.enclosingScrollView;
    NSSize size;
    size.width = NSMinX(scrollView.frame) + (NSWidth(self.view.bounds) - NSMaxX(scrollView.frame));
    size.height = NSMinY(scrollView.frame) + (NSHeight(self.view.bounds) - NSMaxY(scrollView.frame));

    NSSize contentSize = [NSScrollView contentSizeForFrameSize:scrollView.frame.size
                                       horizontalScrollerClass:scrollView.horizontalScroller.class
                                         verticalScrollerClass:scrollView.verticalScroller.class
                                                    borderType:scrollView.borderType
                                                   controlSize:NSControlSizeRegular
                                                 scrollerStyle:scrollView.scrollerStyle];
    size.width += scrollView.bounds.size.width - contentSize.width;
    size.height += scrollView.bounds.size.height - contentSize.height;
    return size;
}

- (void)sizeToFit {
    [_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];

    // I wish I could get the size with -[NSLayoutManager usedRectForTextContainer:] but it seems to
    // be buggy and gives giant widths that I never see when looking at each line fragment.

    NSUInteger glyphIndex = 0;
    NSRange effectiveRange = NSMakeRange(0, 0);
    CGFloat width = 0;
    CGFloat height = 0;
    while (glyphIndex < _textView.layoutManager.numberOfGlyphs) {
        NSRect lineRect = [_textView.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex effectiveRange:&effectiveRange withoutAdditionalLayout:NO];
        width = MAX(width, NSMaxX(lineRect));
        height = MAX(height, NSMaxY(lineRect));
        glyphIndex = NSMaxRange(effectiveRange);
    }

    NSSize size = {
        .width = width,
        .height = height
    };
    NSSize margins = [self marginSize];
    size.width += margins.width;
    size.height += margins.height;
    NSRect frame = self.view.frame;
    frame.size = size;
    self.view.frame = frame;
}

@end
