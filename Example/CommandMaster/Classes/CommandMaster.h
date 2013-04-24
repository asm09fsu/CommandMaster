/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "CommandButton.h"

@protocol CommandMasterDelegate
@optional
- (void)didSelectMenuListItemAtIndex:(NSInteger)index ForButton:(CommandButton *)selectedButton;
- (void)didSelectButton:(CommandButton *)selectedButton;

@end

typedef NS_ENUM(NSUInteger, AppBarState) {
    AppBarMinimal,
    AppBarFull,
    AppBarMenuList
};

@interface CommandMaster : UIView <UITableViewDelegate, UITableViewDataSource>

+ (CommandMaster *)sharedInstance;

- (void)addToView:(UIView *)parent;
- (void)loadGroup:(NSString *)group;

- (void)addToView:(UIView *)parent andLoadGroup:(NSString *)group;

- (void)addButton:(CommandButton *)button forGroup:(NSString *)group;
- (void)addButtons:(NSArray *)buttons forGroup:(NSString *)group;

- (void)showMinimalAppBar;
- (void)showFullAppBar;
- (void)showMenuList;

- (void)buttonForTitle:(NSString *)title setEnabled:(BOOL)enabled;

@property (nonatomic) bool showButtonTitles;
@property (nonatomic, readonly) AppBarState currentState;
@property (nonatomic) bool autoHide;
@property (nonatomic, strong) id<CommandMasterDelegate> delegate;

@end
