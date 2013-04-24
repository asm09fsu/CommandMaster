/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CommandMaster.h"

#define kAppBarMinimalHeight 20
#define kAppBarFullHeight ((_showButtonTitles) ? 50 : 40)
#define kAppBarMenuListHeight ((_showButtonTitles) ? 150 : 140)
#define kAppBarTotalHeight kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight
#define kCircleSize 3
#define kAnimationDuration 0.3
#define kMenuListCellHeight 44

@interface CommandMaster () {
    CGRect _rightCircle;
    CGRect _middleCircle;
    CGRect _leftCircle;
    UIView *_parentView;
    UITableView *_menuList;
    NSString *_currentGroup;
    NSArray *_menuListDataSource;
    CommandButton *_selectedButton;
    NSMutableDictionary *_buttonContainer;
}

- (void)setButtonFrames;
- (void)animateButtonFramesToState:(AppBarState)appBarState;

@end

@implementation CommandMaster

static CommandMaster *_sharedInstance = nil;

@synthesize showButtonTitles = _showButtonTitles,
            delegate = _delegate,
            autoHide = _autoHide;

#pragma mark Public Functions Start

+ (CommandMaster *)sharedInstance {
    if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[CommandMaster alloc] init];
        });
    }
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0];
        _buttonContainer = [[NSMutableDictionary alloc] init];
        _autoHide = YES;
        _showButtonTitles = YES;
    }
    return self;
}

// Adds the bar to the view
- (void)addToView:(UIView *)parent {
    // When first added, the current state is always Minimal.
    _currentState = AppBarMinimal;
    _parentView = parent;
    
    // Calculate based on parentView's frame
    _sharedInstance.frame = CGRectMake(0, (_parentView.frame.size.height - kAppBarMinimalHeight), _parentView.frame.size.width, kAppBarTotalHeight);
    [_parentView addSubview:_sharedInstance];
    
    // Add one UITableView, so that it can just be refreshed with different data.
    _menuList = [[UITableView alloc] initWithFrame:CGRectMake(0, (kAppBarMinimalHeight + kAppBarFullHeight), _parentView.frame.size.width, kAppBarMenuListHeight)];
    _menuList.delegate = self;
    _menuList.dataSource = self;
    _menuList.backgroundColor = [UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0];
    _menuList.showsVerticalScrollIndicator = NO;
    _menuList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuListDataSource = [[NSArray alloc] init];
    [self addSubview:_menuList];
}

// Loads up the group's icons
- (void)loadGroup:(NSString *)group {
    _currentGroup = group;
    [self showMinimalAppBar];
    [self setNeedsDisplay];
    [self setButtonFrames];
}

// Minimize code footprint, combine above 2 functions
- (void)addToView:(UIView *)parent andLoadGroup:(NSString *)group {
    [self addToView:parent];
    [self loadGroup:group];
}

// Used for insertion of single button with error checking for group size
// greater than 4.
- (void)addButton:(CommandButton *)button forGroup:(NSString *)group {
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
    if (_currentGroup == nil) {
        [self loadGroup:group];
    }
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
            if (![obj isKindOfClass:[CommandButton class]]) {
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
        CommandButton *button = obj;
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

- (void)showMinimalAppBar {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, (_parentView.frame.size.height - kAppBarMinimalHeight), self.frame.size.width, self.frame.size.height);
        [self animateButtonFramesToState:AppBarMinimal];
    } completion:^(BOOL finished) {
        _currentState = AppBarMinimal;
    }];
}

- (void)showFullAppBar {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight)), self.frame.size.width, self.frame.size.height);
        [self animateButtonFramesToState:AppBarFull];
    } completion:^(BOOL finished) {
        _currentState = AppBarFull;
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
        _currentState = AppBarMenuList;
    }];
}
#pragma mark Public Functions End

#pragma mark Private Functions Start
- (void)setButtonFrames {
    float width, height;
    if ([[_buttonContainer objectForKey:_currentGroup] count] > 0) {
        height = [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.height;
        width = [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.width;
    }
    switch ([[_buttonContainer objectForKey:_currentGroup] count]) {
        case 1: {
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 2: {
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 3: {
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 4: {
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][3] setFrame:CGRectMake(self.frame.size.width/2 + width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        }
    }
}

- (void)animateButtonFramesToState:(AppBarState)appBarState {
    float width, height;
    if ([[_buttonContainer objectForKey:_currentGroup] count] > 0) {
        height = [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.height;
        width = [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] frame].size.width;
    }
    if (appBarState == AppBarFull) {
        switch ([[_buttonContainer objectForKey:_currentGroup] count]) {
            case 1: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), -2, width, height)];
                }];
                break;
            } case 2: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), -2, width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2, -2, width, height)];
                }];
                break;
            } case 3: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), -2, width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), -2, width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), -2, width, height)];
                }];
                break;
            } case 4: {
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), -2, width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - width, -2, width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2, -2, width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][3] setFrame:CGRectMake(self.frame.size.width/2 + width, -2, width, height)];
                }];
                break;
            }
                
        }
    } else if (appBarState == AppBarMinimal) {
        switch ([[_buttonContainer objectForKey:_currentGroup] count]) {
            case 1: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 2: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 3: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 4: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][1] setFrame:CGRectMake(self.frame.size.width/2 - width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][2] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)[_buttonContainer objectForKey:_currentGroup][3] setFrame:CGRectMake(self.frame.size.width/2 + width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            }
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Create the circles for "See more"
    _rightCircle = CGRectMake((rect.size.width - 20), (kAppBarMinimalHeight/2 - kCircleSize/2), kCircleSize, kCircleSize);
    _middleCircle = CGRectMake((_rightCircle.origin.x - 6), _rightCircle.origin.y, _rightCircle.size.width, _rightCircle.size.height);
    _leftCircle = CGRectMake((_middleCircle.origin.x - 6), _middleCircle.origin.y, _middleCircle.size.width, _middleCircle.size.height);
    CGContextFillEllipseInRect(context, _rightCircle);
    CGContextFillEllipseInRect(context, _middleCircle);
    CGContextFillEllipseInRect(context, _leftCircle);
    
    // Add function calls for buttons.
    for (CommandButton *button in [_buttonContainer objectForKey:_currentGroup]) {
        if (button.containsMenuList) {
            [button addTarget:self action:@selector(openMenuList:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(buttonWasSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:button];
    }
}

- (void)openMenuList:(CommandButton *)sender {
    CommandButton *previousSelected = _selectedButton;
    _selectedButton = sender;
    switch (_currentState) {
        case AppBarMinimal:
        case AppBarFull: {
            _menuListDataSource = _selectedButton.menuListData;
            [_menuList reloadData];
            [self showMenuList];
            break;
        } case AppBarMenuList: {
            if (previousSelected != _selectedButton && previousSelected.containsMenuList) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    _menuListDataSource = _selectedButton.menuListData;
                    [_menuList reloadData];
                    self.frame = CGRectMake(0, (([_selectedButton.menuListData count] >= 4) ? (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight) + 10) : (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + ([_selectedButton.menuListData count] * kMenuListCellHeight)))), self.frame.size.width, self.frame.size.height);
                    [self animateButtonFramesToState:AppBarFull];
                } completion:^(BOOL finished) {
                    [self showMenuList];
                }];
            } else if (previousSelected == _selectedButton) {
                [self showFullAppBar];
            }
            break;
        }
    }
}

- (void)buttonWasSelected:(CommandButton *)sender {
    _selectedButton = sender;
    switch (_currentState) {
        case AppBarMinimal:
        case AppBarFull:
        case AppBarMenuList: {
            [self showMinimalAppBar];
            [_delegate didSelectButton:_selectedButton];
            break;
        }
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
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
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
    if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, kAppBarMinimalHeight), point) && _currentState == AppBarMinimal) {
        [self showFullAppBar];
    } else {
        switch (_currentState) {
            case AppBarFull: {
                [self showMinimalAppBar];
                break;
            } case AppBarMenuList: {
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
        if (_currentState != AppBarMinimal && _autoHide) {
            [self showMinimalAppBar];
        }
        return NO;
    }
    return YES;
}

@end
