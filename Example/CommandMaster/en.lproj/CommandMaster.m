//
//  CommandMaster.m
//  CommandMaster
//
//  Created by Alex Muller on 4/2/13.
//  Copyright (c) 2013 Alex Muller. All rights reserved.
//

#import "CommandMaster.h"

#define kAppBarMinimalHeight 20
#define kAppBarFullHeight ((_showButtonTitles) ? 50 : 40)
#define kAppBarMenuListHeight ((_showButtonTitles) ? 150 : 140)
#define kAppBarTotalHeight kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight
#define kCircleSize 3
#define kAnimationDuration 0.3

@interface CommandMaster () {
    CGRect _rightCircle;
    CGRect _middleCircle;
    CGRect _leftCircle;
    UIView *_parentView;
    UITableView *_menuList;
    NSMutableArray *_buttonContainer;
    NSArray *_menuListDataSource;
    CommandButton *_selectedButton;
}

@end

@implementation CommandMaster

static CommandMaster *_sharedInstance = nil;

@synthesize showButtonTitles = _showButtonTitles,
            delegate = _delegate;

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
        _buttonContainer = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)addToView:(UIView *)parent {
    // When first added, the current state is always Minimal.
    _currentState = AppBarMinimal;
    _parentView = parent;
    
    // Calculate based on parentView's frame
    _sharedInstance.frame = CGRectMake(0, (_parentView.frame.size.height - kAppBarMinimalHeight), _parentView.frame.size.width, kAppBarTotalHeight);

    [_parentView addSubview:_sharedInstance];
    
    _menuList = [[UITableView alloc] initWithFrame:CGRectMake(0, (kAppBarMinimalHeight + kAppBarFullHeight + 10), _parentView.frame.size.width, kAppBarMenuListHeight)];
    _menuList.delegate = self;
    _menuList.dataSource = self;
    _menuList.backgroundColor = [UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0];
    _menuList.showsVerticalScrollIndicator = false;
    _menuList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuListDataSource = [[NSArray alloc] init];
    [self addSubview:_menuList];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addButton:(CommandButton *)button {
    button.showButtonTitle = _showButtonTitles;
    [_buttonContainer addObject:button];
    [self setButtonFrames];
}

- (void)setButtonFrames {
    float width, height;
    if (_buttonContainer > 0) {
        height = [(CommandButton *)_buttonContainer[0] frame].size.height;
        width = [(CommandButton *)_buttonContainer[0] frame].size.width;
    }
    switch ([_buttonContainer count]) {
        case 1: {
            [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 2: {
            [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 3: {
            [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)_buttonContainer[2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        } case 4: {
            [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2 - width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)_buttonContainer[2] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            [(CommandButton *)_buttonContainer[3] setFrame:CGRectMake(self.frame.size.width/2 + width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
            break;
        }
    }
    _menuList.frame = CGRectMake(0, (_showButtonTitles) ? (kAppBarMinimalHeight + kAppBarFullHeight + 5) :(kAppBarMinimalHeight + kAppBarFullHeight), _menuList.frame.size.width, (_showButtonTitles) ? kAppBarMenuListHeight : (kAppBarMenuListHeight - 10));
}

- (void)animateButtonFramesToState:(AppBarState)appBarState {
    float width, height;
    if (_buttonContainer > 0) {
        height = [(CommandButton *)_buttonContainer[0] frame].size.height;
        width = [(CommandButton *)_buttonContainer[0] frame].size.width;
    }
    if (appBarState == AppBarFull) {
        switch ([_buttonContainer count]) {
            case 1: {
                [(CommandButton *)_buttonContainer[0] setAlpha:1.0];
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), -2, width, height)];
                }];
                break;
            } case 2: {
                [(CommandButton *)_buttonContainer[0] setAlpha:1.0];
                [(CommandButton *)_buttonContainer[1] setAlpha:1.0];
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), -2, width, height)];
                    [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2, -2, width, height)];
                }];
                break;
            } case 3: {
                [(CommandButton *)_buttonContainer[0] setAlpha:1.0];
                [(CommandButton *)_buttonContainer[1] setAlpha:1.0];
                [(CommandButton *)_buttonContainer[2] setAlpha:1.0];
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), -2, width, height)];
                    [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), -2, width, height)];
                    [(CommandButton *)_buttonContainer[2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), -2, width, height)];
                }];
                break;
            } case 4: {
                [(CommandButton *)_buttonContainer[0] setAlpha:1.0];
                [(CommandButton *)_buttonContainer[1] setAlpha:1.0];
                [(CommandButton *)_buttonContainer[2] setAlpha:1.0];
                [(CommandButton *)_buttonContainer[3] setAlpha:1.0];
                [UIView animateWithDuration:0.3 animations:^{
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), -2, width, height)];
                    [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2 - width, -2, width, height)];
                    [(CommandButton *)_buttonContainer[2] setFrame:CGRectMake(self.frame.size.width/2, -2, width, height)];
                    [(CommandButton *)_buttonContainer[3] setFrame:CGRectMake(self.frame.size.width/2 + width, -2, width, height)];
                }];
                break;
            }
        
        }
    } else if (appBarState == AppBarMinimal) {
        switch ([_buttonContainer count]) {
            case 1: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)_buttonContainer[0] setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 2: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)_buttonContainer[0] setAlpha:0.0];
                    [(CommandButton *)_buttonContainer[1] setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 3: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)_buttonContainer[0] setAlpha:0.0];
                    [(CommandButton *)_buttonContainer[1] setAlpha:0.0];
                    [(CommandButton *)_buttonContainer[2] setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 1.5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2 - (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)_buttonContainer[2] setFrame:CGRectMake(self.frame.size.width/2 + (width * .5), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            } case 4: {
                [UIView animateWithDuration:0.1 animations:^{
                    [(CommandButton *)_buttonContainer[0] setAlpha:0.0];
                    [(CommandButton *)_buttonContainer[1] setAlpha:0.0];
                    [(CommandButton *)_buttonContainer[2] setAlpha:0.0];
                    [(CommandButton *)_buttonContainer[3] setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [(CommandButton *)_buttonContainer[0] setFrame:CGRectMake(self.frame.size.width/2 - (width * 2), (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)_buttonContainer[1] setFrame:CGRectMake(self.frame.size.width/2 - width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)_buttonContainer[2] setFrame:CGRectMake(self.frame.size.width/2, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                    [(CommandButton *)_buttonContainer[3] setFrame:CGRectMake(self.frame.size.width/2 + width, (kAppBarMinimalHeight + kAppBarFullHeight), width, height)];
                }];
                break;
            }
                
        }
    }
}

- (void)setShowButtonTitles:(bool)showButtonTitles {
    _showButtonTitles = showButtonTitles;
    for (CommandButton *button in _buttonContainer) {
        button.showButtonTitle = showButtonTitles;
    }
    if (_currentState != AppBarMinimal) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.frame = CGRectMake(0, (_parentView.frame.size.height - kAppBarMinimalHeight), self.frame.size.width, self.frame.size.height);
            [self animateButtonFramesToState:AppBarMinimal];
        } completion:^(BOOL finished) {
            switch (_currentState) {
                case AppBarFull: {
                    [self showFullAppBar];
                    break;
                } case AppBarMenuList: {
                    [self showMenuList];
                    break;
                }
                default:
                    break;
            }
        }];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
    
    for (CommandButton *button in _buttonContainer) {
        if (button.containsMenuList) {
            [button addTarget:self action:@selector(openMenuList:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:button];
    }
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
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = CGRectMake(0, (_showButtonTitles) ? (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight +kAppBarMenuListHeight) + 20) : (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight +kAppBarMenuListHeight)), self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        _currentState = AppBarMenuList;
    }];
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
                    self.frame = CGRectMake(0, (_showButtonTitles) ? (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight + kAppBarMenuListHeight) + 20) : (_parentView.frame.size.height - (kAppBarMinimalHeight + kAppBarFullHeight +kAppBarMenuListHeight)), self.frame.size.width, self.frame.size.height);
                    [self animateButtonFramesToState:AppBarFull];
                } completion:^(BOOL finished) {
                    _currentState = AppBarFull;
                    _menuListDataSource = _selectedButton.menuListData;
                    [_menuList reloadData];
                    [self showMenuList];
                }];
            } else if (previousSelected == _selectedButton) {
                [self showFullAppBar];
            }
            break;
        }
    }
}

- (void)buttonSelected:(CommandButton *)sender {
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    // Add some buffer around the circles so it isn't such a small touch point.
    // Open if minimal
    if (CGRectContainsPoint(CGRectMake((_leftCircle.origin.x - 10), 0, (self.frame.size.width - _leftCircle.origin.x), kAppBarMinimalHeight), point)) {
        switch (_currentState) {
            case AppBarMinimal: {
                [self showFullAppBar];
                break;
            } case AppBarFull: {
                [self showMinimalAppBar];
                break;
            } case AppBarMenuList: {
                [self showMinimalAppBar];
                break;
            }
        }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuListDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
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
    [_delegate didSelectMenuListItemAtIndex:indexPath.row ForButton:_selectedButton];
}

@end
