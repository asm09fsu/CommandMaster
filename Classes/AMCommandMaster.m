/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AMCommandMaster.h"

#define kAppBarMinimalHeight 20
#define kAppBarFullHeight ((_showButtonTitles) ? 50 : 40)
#define kAppBarMenuListHeight ((_showButtonTitles) ? 150 : 140)
#define kAppBarTotalHeight kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight
#define kCircleSize 3
#define kAnimationDuration 0.3
#define kMenuListCellHeight 44
#define kDefaultBackgroundColor [UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0]
#define kDefaultAccentColor [UIColor whiteColor]

@interface CMAppearance ()
@end

@implementation CMAppearance

- (id)init {
    if (self = [super init]) {
        _backgroundColor = _menuListBackground = kDefaultBackgroundColor;
        _accentColor = _menuListColor = kDefaultAccentColor;
    }
    return self;
}

+ (CMAppearance *) createDefaultAppearance {
    return [[self alloc] init];
}

@end

// ----------------------------

@interface AMCommandMaster () {
    CGRect _rightCircle;
    CGRect _middleCircle;
    CGRect _leftCircle;
    UIView *_parentView;
    UITableView *_menuList;
    NSArray *_menuListDataSource;
    AMCommandButton *_selectedButton;
    NSMutableDictionary *_buttonContainer;
    NSMutableDictionary *_appearanceContainer;
}

@end

@implementation AMCommandMaster

static AMCommandMaster *_sharedInstance = nil;

#pragma mark Public Functions Start

+ (AMCommandMaster *)sharedInstance {
    if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[self alloc] init];
        });
    }
    return _sharedInstance;
}

+ (void)setDelegate:(id<CommandMasterDelegate>)delegate {
    [self sharedInstance];
    _sharedInstance.delegate = delegate;
}

+ (void)addToView:(UIView *)parent andLoadGroup:(NSString *)group {
    [self sharedInstance];
    [_sharedInstance addToView:parent andLoadGroup:group];
}

+ (void)addToView:(UIView *)parent {
    [self sharedInstance];
    [_sharedInstance addToView:parent];
}

+ (void)loadGroup:(NSString *)group {
    [self sharedInstance];
    [_sharedInstance loadGroup:group];
}

+ (void)addButton:(AMCommandButton *)button forGroup:(NSString *)group {
    [self sharedInstance];
    [_sharedInstance addButton:button forGroup:group];
}

+ (void)addButtons:(NSArray *)buttons forGroup:(NSString *)group {
    [self sharedInstance];
    [_sharedInstance addButtons:buttons forGroup:group];
}

+ (void)showMinimalAppBar {
    [self sharedInstance];
    [_sharedInstance showMinimalAppBar];
}

+ (void)showFullAppBar {
    [self sharedInstance];
    [_sharedInstance showFullAppBar];
}

+ (void)showMenuList {
    [self sharedInstance];
    [_sharedInstance showMenuList];
}

+ (void)hideAppBar {
    [self sharedInstance];
    [_sharedInstance hideAppBar];
}

+ (NSArray *)groups {
    [self sharedInstance];
    return [_sharedInstance groups];
}

+ (void)buttonForTitle:(NSString *)title setEnabled:(BOOL)enabled {
    [self sharedInstance];
    [_sharedInstance buttonForTitle:title setEnabled:enabled];
}

+ (void)setAccentColorForAllGroups:(UIColor *)accent includeMenuList:(BOOL)include {
    [self sharedInstance];
    [_sharedInstance setAccentColorForAllGroups:accent includeMenuList:include];
}

+ (void)setAccentColor:(UIColor *)accent forGroup:(NSString *)group includeMenuList:(BOOL)include {
    [self sharedInstance];
    [_sharedInstance setAccentColor:accent forGroup:group includeMenuList:include];
}

+ (void)setSelectedButtonColorForAllGroups:(UIColor *)color {
    [self sharedInstance];
    [_sharedInstance setSelectedButtonColorForAllGroups:color];
}

+ (void)setSelectedButtonColor:(UIColor *)color forGroup:(NSString *)group {
    [self sharedInstance];
    [_sharedInstance setSelectedButtonColor:color forGroup:group];
}

+ (void)setBackgroundColorForAllGroups:(UIColor *)color includeMenuList:(BOOL)include {
    [self sharedInstance];
    [_sharedInstance setBackgroundColorForAllGroups:color includeMenuList:include];
}

+ (void)setBackgroundColor:(UIColor *)color forGroup:(NSString *)group includeMenuList:(BOOL)include {
    [self sharedInstance];
    [_sharedInstance setBackgroundColor:color forGroup:group includeMenuList:include];
}

+ (CMAppBarState) currentState {
    [self sharedInstance];
    return _sharedInstance.currentState;
}

+ (NSString *) currentGroup {
    [self sharedInstance];
    return _sharedInstance.currentGroup;
}

+ (void)setAutoHide:(BOOL)autoHide {
    [self sharedInstance];
    _sharedInstance.autoHide = autoHide;
}

+ (void)setShowButtonTitles:(BOOL)showButtonTitles {
    [self sharedInstance];
    _sharedInstance.showButtonTitles = showButtonTitles;
}

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = kDefaultBackgroundColor;
        _buttonContainer = [[NSMutableDictionary alloc] init];
        _appearanceContainer = [[NSMutableDictionary alloc] init];
        _autoHide = YES;
        _showButtonTitles = YES;
    }
    return self;
}

// Adds the bar to the view
- (void)addToView:(UIView *)parent {
    // When first added, the current state is always Minimal.
    _currentState = CMAppBarMinimal;
    _parentView = parent;
    
    // Calculate based on parentView's frame
    _sharedInstance.frame = CGRectMake(0, _parentView.frame.size.height, _parentView.frame.size.width, kAppBarTotalHeight);
    [_parentView addSubview:_sharedInstance];
    
    // Add one UITableView, so that it can just be refreshed with different data.
    _menuList = [[UITableView alloc] initWithFrame:CGRectMake(0, (kAppBarMinimalHeight + kAppBarFullHeight), _parentView.frame.size.width, kAppBarMenuListHeight)];
    _menuList.delegate = self;
    _menuList.dataSource = self;
    _menuList.backgroundColor = self.backgroundColor;
    _menuList.showsVerticalScrollIndicator = NO;
    _menuList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuListDataSource = [[NSArray alloc] init];
    [self addSubview:_menuList];
}

// Loads up the group's icons
- (void)loadGroup:(NSString *)group {
    // If the groups the same, no need to reload.
    if ([_currentGroup isEqualToString:group]) {
        return;
    }
    _currentGroup = group;
    [self hideAppBar];
    self.backgroundColor = [_appearanceContainer[_currentGroup] backgroundColor];
    _menuList.backgroundColor = [_appearanceContainer[_currentGroup] menuListColor];
    [self showMinimalAppBar];
    [self setButtonFrames];
    [self setNeedsDisplay];
}

// Minimize code footprint, combine above 2 functions
- (void)addToView:(UIView *)parent andLoadGroup:(NSString *)group {
    [self addToView:parent];
    [self loadGroup:group];
}

// Used for insertion of single button with error checking for group size
// greater than 4.
- (void)addButton:(AMCommandButton *)button forGroup:(NSString *)group {
    // Set the current group as soon as possible.
    // If encased in an if to test if null, for some reason CM will not appear on screen.
    _currentGroup = group;
    if (![_appearanceContainer objectForKey:group]) {
        [_appearanceContainer setObject:[CMAppearance createDefaultAppearance] forKey:group];
    }
    NSMutableArray *tempButtons = [[NSMutableArray alloc] init];
    if ([_buttonContainer objectForKey:group]) {
        tempButtons = [_buttonContainer objectForKey:group];
        @try {
            if ([tempButtons count] == 4) {
                @throw [NSException exceptionWithName:@"CMSizeException" reason:@"The array of buttons you are trying to pass must be less than 5." userInfo:nil];
            }
            button.showButtonTitle = _showButtonTitles;
            [tempButtons addObject:button];
        } @catch (NSException *exception) {
            NSLog(@"%@: %@", exception.name, exception.reason);
            return;
        }
    } else {
        button.showButtonTitle = _showButtonTitles;
        [tempButtons addObject:button];
    }
    [_buttonContainer setObject:tempButtons forKey:group];
    [self setButtonFrames];
    
}

// This is used so user can add an entire array of buttons (so long as <= 4),
// and associate it to a name. That way, we can store multiple "pages"
// of icons, and not have to re-init them when we navigate between pages
- (void)addButtons:(NSArray *)buttons forGroup:(NSString *)group {
    @try {
        if ([buttons count] > 4) {
            @throw [NSException exceptionWithName:@"CMSizeException" reason:@"The array of buttons you are trying to pass must be less than 5." userInfo:nil];
        }
        if (group.length == 0 || group == nil) {
            @throw [NSException exceptionWithName:@"CMGroupNameException" reason:@"The Group Name must not be nil." userInfo:nil];
        }
        if (([[_buttonContainer objectForKey:group] count] + buttons.count) > 4) {
            @throw [NSException exceptionWithName:@"CMSizeException" reason:@"The array of buttons you are trying to add to the already exsiting group must be a total of less than 5" userInfo:nil];
        }
        [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[AMCommandButton class]]) {
                @throw [NSException exceptionWithName:@"CMButtonArrayException" reason:@"The array can only contain CommandButton objects" userInfo:nil];
            }
            [self addButton:obj forGroup:group];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@: %@", exception.name, exception.reason);
        return;
    }
}

// Set a button within the current group to be enabled/disabled
- (void)buttonForTitle:(NSString *)title setEnabled:(BOOL)enabled {
    [[_buttonContainer objectForKey:_currentGroup] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AMCommandButton *button = obj;
        if ([button.title isEqualToString:title]) {
            [button setEnabled:enabled];
            *stop = YES;
        }
    }];
}


- (void)setShowButtonTitles:(bool)showButtonTitles {
    if (showButtonTitles == _showButtonTitles) {
        return;
    }
    _showButtonTitles = showButtonTitles;
    
    // Set all buttons within the container to showButtonTitles
    [[_buttonContainer objectForKey:_currentGroup] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setShowButtonTitle:_showButtonTitles];
    }];
}

- (void)hideAppBar {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, _parentView.frame.size.height, self.frame.size.width, self.frame.size.height);
        [self animateButtonFramesToState:CMAppBarMinimal];
    } completion:^(BOOL finished) {
        _currentState = CMAppBarHidden;
    }];
}

- (void)showMinimalAppBar {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, (_parentView.frame.size.height - kAppBarMinimalHeight), self.frame.size.width, self.frame.size.height);
        [self animateButtonFramesToState:CMAppBarMinimal];
    } completion:^(BOOL finished) {
        _currentState = CMAppBarMinimal;
    }];
}

- (void)showFullAppBar {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight)), self.frame.size.width, self.frame.size.height);
        [self animateButtonFramesToState:CMAppBarFull];
    } completion:^(BOOL finished) {
        _currentState = CMAppBarFull;
    }];
}

- (void)showMenuList {
    if (_selectedButton.menuListData == nil) {
        return;
    }
    // No need to scroll if the list is less than 4
    if ([_selectedButton.menuListData count] >= 4) {
        _menuList.scrollEnabled = YES;
    } else {
        _menuList.scrollEnabled = NO;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, (([_selectedButton.menuListData count] >= 4) ? (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight) + 10) : (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + ([_selectedButton.menuListData count] * kMenuListCellHeight)))), self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        _currentState = CMAppBarMenuList;
    }];
}

- (void)setAccentColorForAllGroups:(UIColor *)accent includeMenuList:(BOOL)include {
    [_appearanceContainer enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setAccentColor:accent forGroup:key includeMenuList:include];
    }];
    [self setNeedsDisplay];
}


- (void)setAccentColor:(UIColor *)accent forGroup:(NSString *)group includeMenuList:(BOOL)include {
    if(![self checkForExistenceOfKey:group]) {
        return;
    }
    [_appearanceContainer[group] setAccentColor:accent];
    if (include) {
        [_appearanceContainer[group] setMenuListColor:accent];
    }
    [_buttonContainer[group] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setButtonColor:accent];
        if (include) {
            [obj setMenuListColor:accent];
        }
    }];
//    if (include) {
//        [_menuList setNeedsDisplay];
//    }
    [self setNeedsDisplay];
}

- (void)setSelectedButtonColorForAllGroups:(UIColor *)color {
    [_appearanceContainer enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setSelectedButtonColor:color forGroup:key];
    }];
}

- (void)setSelectedButtonColor:(UIColor *)color forGroup:(NSString *)group {
    if(![self checkForExistenceOfKey:group]) {
        return;
    }
    [_appearanceContainer[group] setSelectedColor:color];
    [_buttonContainer[group] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setSelectedButtonColor:color];
    }];
}

- (void)setBackgroundColorForAllGroups:(UIColor *)color includeMenuList:(BOOL)include  {
    [_appearanceContainer enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setBackgroundColor:color forGroup:key includeMenuList:include];
    }];
    [self setNeedsDisplay];
}


- (void)setBackgroundColor:(UIColor *)color forGroup:(NSString *)group includeMenuList:(BOOL)include {
    if(![self checkForExistenceOfKey:group]) {
        return;
    }
    [_appearanceContainer[group] setBackgroundColor:color];
    [self setNeedsDisplay];
}

- (NSArray *)groups {
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    [_buttonContainer enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [groups addObject:key];
    }];
    return groups;
}

#pragma mark Public Functions End

#pragma mark Private Functions Start

//- (void)deviceOrientationDidChange:(NSNotification *)notification {
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//}

- (BOOL)checkForExistenceOfKey:(NSString *)key {
    @try {
        if (![_buttonContainer objectForKey:key]) {
            @throw [NSException exceptionWithName:@"CMGroupException" reason:[NSString stringWithFormat:@"CommandMaster does not have a group named \"%@\".", key] userInfo:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@: %@", exception.name, exception.reason);
        return NO;
    }
    return YES;
}

- (void)setButtonFrames {
    float width, height;
    if ([[_buttonContainer objectForKey:_currentGroup] count] > 0) {
        height = [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.height;
        width = [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.width;
    }
    switch ([[_buttonContainer objectForKey:_currentGroup] count]) {
        case 1: {
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 2: {
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 3: {
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 4: {
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][3] setFrame:CGRectMake(self.frame.size.width/2 + width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        }
    }
}

- (void)animateButtonFramesToState:(CMAppBarState)appBarState {
    float width, height;
    if ([[_buttonContainer objectForKey:_currentGroup] count] > 0) {
        height = [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.height;
        width = [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.width;
    }
    if (appBarState == CMAppBarFull) {
        switch ([[_buttonContainer objectForKey:_currentGroup] count]) {
            case 1: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), -2, width, height)];
                }];
                break;
            } case 2: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), -2, width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2, -2, width, height)];
                }];
                break;
            } case 3: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), -2, width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), -2, width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), -2, width, height)];
                }];
                break;
            } case 4: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), -2, width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - width, -2, width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2, -2, width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][3] setFrame:CGRectMake(self.frame.size.width/2 + width, -2, width, height)];
                }];
                break;
            }
                
        }
    } else if (appBarState == CMAppBarMinimal) {
        switch ([[_buttonContainer objectForKey:_currentGroup] count]) {
            case 1: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 2: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 3: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 4: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(AMCommandButton *)[_buttonContainer objectForKey:_currentGroup][3] setFrame:CGRectMake(self.frame.size.width/2 + width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            }
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (_currentGroup == nil) {
        CGContextSetFillColorWithColor(context, kDefaultAccentColor.CGColor);
        CGContextSetStrokeColorWithColor(context, kDefaultAccentColor.CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [_appearanceContainer[_currentGroup] backgroundColor].CGColor);
        CGContextFillRect(context, self.bounds);
        CGContextSetFillColorWithColor(context, [_appearanceContainer[_currentGroup] accentColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [_appearanceContainer[_currentGroup] accentColor].CGColor);
    }
    
    // Create the circles for "See more"
    _rightCircle = CGRectMake((rect.size.width - 20), (kAppBarMinimalHeight/2 - kCircleSize/2), kCircleSize, kCircleSize);
    _middleCircle = CGRectMake((_rightCircle.origin.x - 6), _rightCircle.origin.y, _rightCircle.size.width, _rightCircle.size.height);
    _leftCircle = CGRectMake((_middleCircle.origin.x - 6), _middleCircle.origin.y, _middleCircle.size.width, _middleCircle.size.height);
    CGContextFillEllipseInRect(context, _rightCircle);
    CGContextFillEllipseInRect(context, _middleCircle);
    CGContextFillEllipseInRect(context, _leftCircle);
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AMCommandButton class]]) {
            [obj removeFromSuperview];
        }
    }];
    for (AMCommandButton *button in [_buttonContainer objectForKey:_currentGroup]) {
        if (button.containsMenuList) {
            [button addTarget:self action:@selector(openMenuList:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(buttonWasSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:button];
    }
}

- (void)openMenuList:(AMCommandButton *)sender {
    AMCommandButton *previousSelected = _selectedButton;
    _selectedButton = sender;
    switch (_currentState) {
        case CMAppBarMinimal:
        case CMAppBarFull: {
            _menuListDataSource = _selectedButton.menuListData;
            [_menuList reloadData];
            [self showMenuList];
            break;
        } case CMAppBarMenuList: {
            if (previousSelected != _selectedButton && previousSelected.containsMenuList) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    _menuListDataSource = _selectedButton.menuListData;
                    [_menuList reloadData];
                    self.frame = CGRectMake(0, (([_selectedButton.menuListData count] >= 4) ? (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight) + 10) : (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + ([_selectedButton.menuListData count] * kMenuListCellHeight)))), self.frame.size.width, self.frame.size.height);
                    [self animateButtonFramesToState:CMAppBarFull];
                } completion:^(BOOL finished) {
                    [self showMenuList];
                }];
            } else if (previousSelected == _selectedButton) {
                [self showFullAppBar];
            }
            break;
        }
    default:
        break;
    }
}

- (void)buttonWasSelected:(AMCommandButton *)sender {
    _selectedButton = sender;
    switch (_currentState) {
        case CMAppBarMinimal:
        case CMAppBarFull:
        case CMAppBarMenuList: {
            [self showMinimalAppBar];
            [_delegate didSelectButton:_selectedButton];
            break;
        }
        default:
            break;
    }
}

#pragma mark MenuList UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuListDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"menuListReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
#warning See if we want to do custom uitableview color, for now it will inherit background color
    cell.contentView.backgroundColor = [_appearanceContainer[_currentGroup] backgroundColor];
    cell.textLabel.textColor = [_selectedButton menuListColor];
    cell.textLabel.text = [[_menuListDataSource objectAtIndex:indexPath.row] lowercaseString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showMinimalAppBar];
    [_menuList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [_delegate didSelectMenuListItemAtIndex:indexPath.row ForButton:_selectedButton];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMenuListCellHeight;
}

#pragma mark Touch Event Delegates
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    // Add some buffer around the circles so it isn't such a small touch point.
    // Open if minimal
    if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, kAppBarMinimalHeight), point) && _currentState == CMAppBarMinimal) {
        [self showFullAppBar];
    } else {
        switch (_currentState) {
            case CMAppBarFull: {
                [self showMinimalAppBar];
                break;
            } case CMAppBarMenuList: {
                [self showFullAppBar];
                break;
            } default:
                break;
        }
    }
}

// Handles bug that wouldn't let us touch the bottom 20px-ish of the menuList
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(_menuList.frame, point)) {
        return YES;
    }
    if (point.y < 0) {
        if ((_currentState != CMAppBarMinimal) && _autoHide) {
            [self showMinimalAppBar];
        }
        return NO;
    }
    return YES;
}

@end
