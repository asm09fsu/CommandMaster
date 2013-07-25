/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "AMCommandButton.h"

@interface CMAppearance : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) UIColor *menuListColor;
@property (nonatomic, strong) UIColor *menuListBackground;
@property (nonatomic, strong) UIColor *selectedColor;


//- (void)setBackgroundColor:(UIColor *)color;
//- (void)setAccentDColor:(UIColor *)color;

@end

@protocol CommandMasterDelegate
@optional
- (void)didSelectMenuListItemAtIndex:(NSInteger)index ForButton:(AMCommandButton *)selectedButton;
- (void)didSelectButton:(AMCommandButton *)selectedButton;

@end

typedef NS_ENUM(NSUInteger, CMAppBarState) {
    CMAppBarMinimal,
    CMAppBarFull,
    CMAppBarMenuList,
    CMAppBarHidden
};

@interface AMCommandMaster : UIView <UITableViewDelegate, UITableViewDataSource>

+ (void)addToView:(UIView *)parent;
+ (void)loadGroup:(NSString *)group;
+ (void)addToView:(UIView *)parent andLoadGroup:(NSString *)group;

+ (void)addButton:(AMCommandButton *)button forGroup:(NSString *)group;
+ (void)addButtons:(NSArray *)buttons forGroup:(NSString *)group;

+ (void)showMinimalAppBar;
+ (void)showFullAppBar;
+ (void)showMenuList;
+ (void)hideAppBar;

+ (NSArray *)groups;

+ (void)buttonForTitle:(NSString *)title setEnabled:(BOOL)enabled;

+ (void)setAccentColorForAllGroups:(UIColor *)accent includeMenuList:(BOOL)include;
+ (void)setAccentColor:(UIColor *)accent forGroup:(NSString *)group includeMenuList:(BOOL)include;

+ (void)setSelectedButtonColorForAllGroups:(UIColor *)color;
+ (void)setSelectedButtonColor:(UIColor *)color forGroup:(NSString *)group;

+ (void)setBackgroundColorForAllGroups:(UIColor *)color includeMenuList:(BOOL)include;
+ (void)setBackgroundColor:(UIColor *)color forGroup:(NSString *)group includeMenuList:(BOOL)include;

// Accessor Functions
+ (CMAppBarState) currentState;
+ (NSString *) currentGroup;

// Setter Functions
+ (void)setDelegate:(id<CommandMasterDelegate>)delegate;
+ (void)setAutoHide:(BOOL)autoHide;
+ (void)setShowButtonTitles:(BOOL)showButtonTitles;

@property (nonatomic) bool showButtonTitles;
@property (nonatomic, readonly) CMAppBarState currentState;
@property (nonatomic, readonly) NSString *currentGroup;
@property (nonatomic) bool autoHide;
@property (nonatomic, strong) id<CommandMasterDelegate> delegate;

@end
