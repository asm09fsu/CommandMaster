/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CommandButton.h"

@interface CommandButton () {
    UIImage *_image;
}
@end

@implementation CommandButton

@synthesize containsMenuList = _containsMenuList,
            showButtonTitle = _showButtonTitle,
            image = _image,
            title = _title,
            menuListData = _menuListData;

- (id)initWithImage:(UIImage *)image andTitle:(NSString *)title {
    CommandButton *temp = [[CommandButton alloc] initWithFrame:CGRectMake(0, 0, 60, 80)];
    temp.image = image;
    temp.title = title;
    return temp;
}

- (id)initWithImage:(UIImage *)image andTitle:(NSString *)title andMenuListItems:(NSArray *)items {
    CommandButton *temp = [[CommandButton alloc] initWithImage:image andTitle:title];
    temp.menuListData = items;
    return temp;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _containsMenuList = false;
        _showButtonTitle = false;
        _menuListData = [[NSArray alloc] init];
    }
    return self;
}

+ (CommandButton *)createButtonWithImage:(UIImage *)image andTitle:(NSString *)title {
    return [[CommandButton alloc] initWithImage:image andTitle:title];
}

+ (CommandButton *)createButtonWithImage:(UIImage *)image andTitle:(NSString *)title andMenuListItems:(NSArray *)items {
    return [[CommandButton alloc] initWithImage:image andTitle:title andMenuListItems:items];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Setup text matrix so that positions aren't in Postscript convention, but in iOS's convention
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    
    // Check to see if either the button is pressed or disabled
    if (self.highlighted || !self.enabled) {
        CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
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
