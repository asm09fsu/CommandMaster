/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AMCommandButton.h"

#define kDefaultButtonColor [UIColor whiteColor]
#define kDefaultSelectionColor [UIColor darkGrayColor]

@interface AMCommandButton () {
    UIImage *_image;
    UIColor *_selectedColor;
    UIColor *_mainColor;
}
@end

@implementation AMCommandButton

- (id)initWithImage:(UIImage *)image andTitle:(NSString *)title {
    AMCommandButton *temp = [[AMCommandButton alloc] initWithFrame:CGRectMake(0, 0, 60, 80)];
    temp.image = image;
    temp.title = title;
    return temp;
}

- (id)initWithImage:(UIImage *)image andTitle:(NSString *)title andMenuListItems:(NSArray *)items {
    AMCommandButton *temp = [[AMCommandButton alloc] initWithImage:image andTitle:title];
    temp.menuListData = items;
    return temp;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _menuListColor = kDefaultButtonColor;
        _selectedColor = kDefaultSelectionColor;
        _mainColor = kDefaultButtonColor;
        _containsMenuList = false;
        _showButtonTitle = false;
        _menuListData = [[NSArray alloc] init];
    }
    return self;
}

+ (AMCommandButton *)createButtonWithImage:(UIImage *)image andTitle:(NSString *)title {
    return [[self alloc] initWithImage:image andTitle:title];
}

+ (AMCommandButton *)createButtonWithImage:(UIImage *)image andTitle:(NSString *)title andMenuListItems:(NSArray *)items {
    return [[self alloc] initWithImage:image andTitle:title andMenuListItems:items];
}

- (void)setButtonColor:(UIColor *)color {
    _mainColor = color;
    [self setNeedsDisplay];
}

- (void)setSelectedButtonColor:(UIColor *)color {
    _selectedColor = color;
    [self setNeedsDisplay];
}

- (void)setMenuListColor:(UIColor *)color {
    _menuListColor = color;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Setup text matrix so that positions aren't in Postscript convention, but in iOS's convention
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    
    // Check to see if either the button is pressed or disabled
    if (self.highlighted || !self.enabled) {
        CGContextSetStrokeColorWithColor(context, _selectedColor.CGColor);
        CGContextSetFillColorWithColor(context, _selectedColor.CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, _mainColor.CGColor);
        CGContextSetFillColorWithColor(context, _mainColor.CGColor);
    }
    
    CGContextSaveGState(context);
    
    // Set up the circle
    CGContextSetLineWidth(context, 2.0);
    CGRect buttonCircle = CGRectInset(rect, 13, 23);
    buttonCircle = CGRectMake(buttonCircle.origin.x, buttonCircle.origin.y - 13, buttonCircle.size.width, buttonCircle.size.height);
    CGContextStrokeEllipseInRect(context, buttonCircle);
    
    // If the image isn't null, add it within the circle, otherwise it will just be empty
    if (_image != nil) {
        CGContextTranslateCTM(context, 0, (buttonCircle.size.height + 2) * 1.5);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGRect temp = CGRectInset(buttonCircle, 7.5, 7.5);
        CGRect imageCircle = CGRectMake(temp.origin.x, temp.origin.y, temp.size.width, temp.size.height);
        CGContextClipToMask(context, imageCircle, _image.CGImage);
        CGContextFillRect(context, imageCircle);
    }
        
    CGContextRestoreGState(context);
    
    // Check to see if the show button title flag is yes, and if there is actually a title
    if (_showButtonTitle && _title.length != 0) {
        [_title.lowercaseString drawInRect:CGRectMake(0, rect.size.height - 30, rect.size.width, 20) withFont:[UIFont fontWithName:@"Avenir-Medium" size:10] lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setShowButtonTitle:(bool)showButtonTitle {
    _showButtonTitle = showButtonTitle;
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)buttonTitle {
    _title = buttonTitle;
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)buttonImage {
    _image = buttonImage;
    [self setNeedsDisplay];
}

- (void)setMenuListData:(NSArray *)menuListData {
    // Check to make surethe menuListData exists and is > 0
    if ([menuListData count] > 0 || menuListData != nil) {
        _containsMenuList = YES;
        _menuListData = menuListData;
    }
}



@end
