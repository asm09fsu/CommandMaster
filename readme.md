# CommandMaster #
CommandMaster is designed as an iOS port of Windows Phone 8's [App Bar](http://msdn.microsoft.com/en-us/library/windowsphone/develop/ff431813\(v=vs.105\).aspx), with some added functionality.

![](https://dl.dropboxusercontent.com/u/19779645/inAction.png)

### iOS CommandMaster v. WP8 App Bar 

![](http://i38.tinypic.com/110bryt.png)

## Storage 
A collection of 4 Buttons is stored in association with a Group name. CommandMaster uses an [NSDictionary](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDictionary_Class/Reference/Reference.html) to store the collection as a value and the group name as it's key. If CommandMaster is instantiated within the AppDelegate, this allows you to cache all button collections after creation.

## Implementation 
CommandMaster is a [singleton](https://developer.apple.com/library/mac/#documentation/General/Conceptual/DevPedia-CocoaCore/Singleton.html) instance, meaning there is only one instance of the bar throughout the entire application's lifecycle. Because of this, it is ideal to add the CommandMaster.h into <ProjectName>-Prefix.pch file, that way you do not need to import it into all Classes, as it is added on compile time and used everywhere.

```objc
	#import <Availability.h>
	#ifdef __OBJC__
    	#import <UIKit/UIKit.h>
    	#import <Foundation/Foundation.h>
    	#import "CommandMaster.h"
	#endif
```

And the best way to implement CommandMaster is from within the AppDelegate.

```objc
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [[CommandMaster sharedInstance] addButtons:@[
            [CommandButton createButtonWithImage:[UIImage imageNamed:@"saveIcon"] andTitle:@"save" andMenuListItems:@[@"menu item 1", @"menu item 2", @"menu item 3"]],
            [CommandButton createButtonWithImage:[UIImage imageNamed:@"deleteIcon"] andTitle:@"delete"],
            [CommandButton createButtonWithImage:[UIImage imageNamed:@"help"] andTitle:@"help"],
            [CommandButton createButtonWithImage:[UIImage imageNamed:@"settings"] andTitle:@"settings"]]
        forGroup:@"TestGroup"];
    	return YES;
	}
```	

Now to actually use this class within a ViewController, UITableViewController, or any other class that has a UIView, add this line to viewDidAppear

```objc	
	- (void)viewDidAppear:(BOOL)animated {
		// Add to the view
    	[[CommandMaster sharedInstance] addToView:self.view];
	}
```

## Groups 
If you noticed will creating buttons for the bar, you noticed you were adding them to a specific "group". These groups have a maximum size of 4, and you are permitted (and encouraged) to create all groups you will need from within the Application Delegate, so they are cached and ready to be used.

If you have more than one group, a function must be added from within the viewDidAppear, after addToView is done.

```objc
	- (void)viewDidAppear:(BOOL)animated {
		[[CommandMaster sharedInstance] addToView:self.view andLoadGroup:@"TestGroup"];
	}
```

However, if you are only using one group, this group will be the default group, and will always be loaded.
		
## Function Breakdown 

```objc
    - (void)addButtons:(NSArray *)buttons forGroup:(NSString *)group;
    - (void)addButton:(CommandButton *)button forGroup:(NSString *)group;
```

The above allows for either creating an entire array of buttons and adding them to either an already existing 

```objc
    - (void)addToView:(UIView *)parent;
```

This function must be called in order to add CommandMaster to the UIView. 

```objc
    - (void)loadGroup:(NSString *)group;
```

Load group of name **group**. This should be used when there are multiple groups within CommandMaster

```objc
    - (void)addToView:(UIView *)parent andLoadGroup:(NSString *)group;
```

Combination of the above two functions to allow for smaller code footprint.

```objc
    - (void)buttonForTitle:(NSString *)title setEnabled:(BOOL)enabled;
```

Allows user to set the button of a current loaded group's enabled state.

## Public Properties 

```objc
    bool showButtonTitles;
```

Lets you know if your Button's titles are set to show.    

```objc
    AppBarState currentState; (readonly)
```

Allows you to know the CommandMaster's current state.    

```objc
    bool autoHide;
```

Will set CommandMaster's autohide on scroll property (Useful with UITableViews).

## Delegate Functions 

```objc
    - (void)didSelectMenuListItemAtIndex:(NSInteger)index ForButton:(CommandButton *)selectedButton;
```

This function is only called when an item that **does contain** a menuList is selected. The button is returned in the case where there are multiple buttons with menuLists, selected.

```objc
    - (void)didSelectButton:(CommandButton *)selectedButton;
```

This function is only called when an item that **does not contain** a menuList is selected.

## CommandButton Class
The CommandButton is a subclass of [UIButton](https://developer.apple.com/library/ios/#DOCUMENTATION/UIKit/Reference/UIButton_Class/UIButton/UIButton.html) was created in order to implement the custom, circle buttons for the bar. 

### Creation of a CommandButton
There are two ways to create a CommandButton: either using the standard instantiation/allocation of an object, or use CommandButton's class functions to do the allocation for you.

#### Standard

```objc
	- (id)initWithImage:(UIImage *)image andTitle:(NSString *)title;
	- (id)initWithImage:(UIImage *)image andTitle:(NSString *)title andMenuListItems:(NSArray *)items;
```

#### Class Functions

```objc
	+ (CommandButton *)createButtonWithImage:(UIImage *)image andTitle:(NSString *)title;
	+ (CommandButton *)createButtonWithImage:(UIImage *)image andTitle:(NSString *)title andMenuListItems:(NSArray *)items;
```

### CommandButton Properties To Know

```objc
    UIImage *image;
```

This is the button image that will show up within the bar. This is not necessary, however if the image is NULL, it will just appear as an empty circle.

#### Images
CommandButton was made to be able to use any image that would be used for UITabBar or UINavigationBar. Great icons are ones provided by [Glyphish](http://www.glyphish.com/), [iconSweets2](http://www.iconsweets2.com/), [Font Awesome](http://fortawesome.github.io/Font-Awesome/) or others.

```objc
    NSString *title;
```

This is the button title that will show up within the bar. This is not necessary. 

```objc
    NSArray *menuListData;
```

If you wish for the button to display as list of choices, you may add an array of choices. These choices **must be NSStrings**.

## Future Plans
* Further optimizations of functions such as setButtonFrames & animateButtonFramesToState
* ~~Ability to customize colors of the bar and buttons.~~ Completed but not all bugs fixed.


## Copyright
Copyright © 2013, Alex Muller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
