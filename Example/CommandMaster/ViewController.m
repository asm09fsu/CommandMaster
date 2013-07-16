/*
 Copyright © 2012, Alex Muller
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ViewController.h"

@implementation Color
@synthesize color = _color,
            name = _name;

+ (id)createColor:(UIColor *)color withName:(NSString *)name {
    Color *temp = [[Color alloc] init];
    temp.color = color;
    temp.name = name;
    return temp;
}

@end

@interface ViewController () {
    IBOutlet UILabel *_textLabel;
    IBOutlet UIButton *_background;
    IBOutlet UIButton *_accent;
    IBOutlet UIButton *_group;
    IBOutlet UIPickerView *_picker;
    NSArray *_bgColors;
    NSArray *_groups;
    NSString *_selectedBg;
    NSString *_selectedAccent;
    NSString *_selectedGroup;
}
@end

@implementation ViewController

/******
 
 Press button to show picker, press again to hide.
 
 ******/

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AMCommandMaster addToView:self.view andLoadGroup:@"TestGroup"];
    [AMCommandMaster setDelegate:self];
    _selectedBg = @"Default";
    _selectedAccent = @"Default";
    _selectedGroup = [AMCommandMaster currentGroup];
    _picker.alpha = 0.0;
    _bgColors = @[
                [Color createColor:[UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0] withName:@"Default"],
                [Color createColor:[UIColor blueColor] withName:@"Blue"],
                [Color createColor:[UIColor brownColor] withName:@"Brown"],
                [Color createColor:[UIColor orangeColor] withName:@"Orange"],
                [Color createColor:[UIColor purpleColor] withName:@"Purple"],
                [Color createColor:[UIColor redColor] withName:@"Red"],
                [Color createColor:[UIColor yellowColor] withName:@"Yellow"],
                [Color createColor:[UIColor whiteColor] withName:@"White"],
                ];
    _groups = [NSArray arrayWithArray:[AMCommandMaster groups]];
    [_group setTitle:_selectedGroup forState:UIControlStateNormal];
}

- (void)didSelectMenuListItemAtIndex:(NSInteger)index ForButton:(AMCommandButton *)selectedButton {
    _textLabel.text = [NSString stringWithFormat:@"index %i of button titled \"%@\"", index, selectedButton.title];
}

- (void)didSelectButton:(AMCommandButton *)selectedButton {
    _textLabel.text = [NSString stringWithFormat:@"button titled \"%@\" was selected", selectedButton.title];
}

- (IBAction)changeBackground:(id)sender {
    if ([_accent.titleLabel.text isEqualToString:@"Selected"]) {
        [_accent setTitle:_selectedAccent forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_bgColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Color *col = obj;
            if ([col.name isEqualToString:_selectedAccent]) {
                [AMCommandMaster setAccentColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                *stop = YES;
            }
        }];
    } else if ([_group.titleLabel.text isEqualToString:@"Selected"]) {
        [_group setTitle:_selectedGroup forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqualToString:_selectedGroup]) {
                [AMCommandMaster loadGroup:obj];
                *stop = YES;
            }
        }];
    }
    if (![_background.titleLabel.text isEqualToString:@"Selected"]) {
        [_background setTitle:@"Selected" forState:UIControlStateNormal];
        _picker.alpha = 1.0;
    } else {
        [_background setTitle:_selectedBg forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_bgColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Color *col = obj;
            if ([col.name isEqualToString:_selectedBg]) {
                [AMCommandMaster setBackgroundColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                *stop = YES;
            }
        }];
    }
    [_picker reloadAllComponents];
}

- (IBAction)changeAccent:(id)sender {
    if ([_background.titleLabel.text isEqualToString:@"Selected"]) {
        [_background setTitle:_selectedBg forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_bgColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Color *col = obj;
            if ([col.name isEqualToString:_selectedBg]) {
                [AMCommandMaster setBackgroundColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                *stop = YES;
            }
        }];
    } else if ([_group.titleLabel.text isEqualToString:@"Selected"]) {
        [_group setTitle:_selectedGroup forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqualToString:_selectedGroup]) {
                [AMCommandMaster loadGroup:obj];
                *stop = YES;
            }
        }];
    }
    if (![_accent.titleLabel.text isEqualToString:@"Selected"]) {
        [_accent setTitle:@"Selected" forState:UIControlStateNormal];
        _picker.alpha = 1.0;
    } else {
        [_accent setTitle:_selectedAccent forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_bgColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Color *col = obj;
            if ([col.name isEqualToString:_selectedAccent]) {
                if ([col.name isEqualToString:@"Default"]) {
                    [AMCommandMaster setAccentColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                    *stop = YES;
                }
                [AMCommandMaster setAccentColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                *stop = YES;
            }
        }];
    }
    [_picker reloadAllComponents];
}

- (IBAction)changeGroup:(id)sender {
    if ([_background.titleLabel.text isEqualToString:@"Selected"]) {
        [_background setTitle:_selectedBg forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_bgColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Color *col = obj;
            if ([col.name isEqualToString:_selectedBg]) {
                [AMCommandMaster setBackgroundColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                *stop = YES;
            }
        }];
    } else if ([_accent.titleLabel.text isEqualToString:@"Selected"]) {
        [_accent setTitle:_selectedAccent forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_bgColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Color *col = obj;
            if ([col.name isEqualToString:_selectedAccent]) {
                [AMCommandMaster setAccentColor:col.color forGroup:_selectedGroup includeMenuList:YES];
                *stop = YES;
            }
        }];
    }
    if (![_group.titleLabel.text isEqualToString:@"Selected"]) {
        [_group setTitle:@"Selected" forState:UIControlStateNormal];
        _picker.alpha = 1.0;
    } else {
        [_group setTitle:_selectedGroup forState:UIControlStateNormal];
        _picker.alpha = 0.0;
        [_groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqualToString:_selectedGroup]) {
                [AMCommandMaster loadGroup:obj];
                *stop = YES;
            }
        }];
    }
    [_picker reloadAllComponents];
}

- (IBAction)reset:(id)sender {
    [AMCommandMaster setBackgroundColorForAllGroups:[UIColor colorWithRed:0.129 green:0.125 blue:0.129 alpha:1.0] includeMenuList:YES];
    [AMCommandMaster setAccentColorForAllGroups:[UIColor whiteColor] includeMenuList:YES];
    _picker.alpha = 0.0;
    [_background setTitle:@"Default" forState:UIControlStateNormal];
    [_accent setTitle:@"Default" forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if ([_background.titleLabel.text isEqualToString:@"Selected"] || [_accent.titleLabel.text isEqualToString:@"Selected"]) {
        return [_bgColors count];
    }
    if ([_group.titleLabel.text isEqualToString:@"Selected"]) {
        return [_groups count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([_background.titleLabel.text isEqualToString:@"Selected"] || [_accent.titleLabel.text isEqualToString:@"Selected"]) {
        return [_bgColors[row] name];
    }
    
    if ([_group.titleLabel.text isEqualToString:@"Selected"]) {
        return _groups[row];
    }
    return @"Empty";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([_background.titleLabel.text isEqualToString:@"Selected"]) {
        _selectedBg = [_bgColors[row] name];
    }
    if ([_accent.titleLabel.text isEqualToString:@"Selected"]) {
        _selectedAccent = [_bgColors[row] name];
    }    
    if ([_group.titleLabel.text isEqualToString:@"Selected"]) {
        _selectedGroup = _groups[row];
    }

}

@end
