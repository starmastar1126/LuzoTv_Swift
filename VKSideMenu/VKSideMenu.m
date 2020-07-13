//
//  VKSideMenu.m
//  Version: 1.1
//
//  Created by Vladislav Kovalyov on 2/7/16.
//  Copyright © 2016 WOOPSS.com (http://woopss.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VKSideMenu.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define ROOTVC [[[[UIApplication sharedApplication] delegate] window] rootViewController]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation VKSideMenuItem

@synthesize icon;
@synthesize title;
@synthesize tag;

@end

@interface VKSideMenu() <UITableViewDelegate, UITableViewDataSource>
{
    UITapGestureRecognizer *tapGesture;
}

@property (nonatomic, strong) UIView *overlay;

@end

@implementation VKSideMenu

#pragma mark - Initialization

-(instancetype)init
{
    if (self = [super init])
    {
        [self baseInit];
    }
    
    return self;
}

-(instancetype)initWithDirection:(VKSideMenuDirection)direction
{
    if (self = [super init])
    {
        [self baseInit];
        
        self.direction  = direction;
    }
    
    return self;
}

-(instancetype)initWithSize:(CGFloat)size andDirection:(VKSideMenuDirection)direction
{
    if (self = [super init])
    {
        [self baseInit];
        
        self.size       = size;
        self.direction  = direction;
    }
    
    return self;
}

-(void)baseInit
{
    self.size                       = 220.0f;
    self.direction                  = VKSideMenuDirectionFromLeft;
    self.rowHeight                  = 46.0f;
    self.enableOverlay              = YES;
    self.automaticallyDeselectRow   = YES;
    self.hideOnSelection            = YES;
    self.enableGestures             = YES;
    
    self.sectionTitleFont   = [UIFont fontWithName:@"Roboto-Regular" size:17.0f];
    self.selectionColor     = [UIColor colorWithHexString:@"#000000" alpha:0.2];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //self.backgroundColor    = [UIColor colorWithWhite:1. alpha:.8];
#pragma clang diagnostic pop
    self.textColor          = UIColorFromRGB(0x252525);
    self.iconsColor         = [UIColor blackColor];
    self.sectionTitleColor  = [UIColor darkGrayColor];
    
    if(!SYSTEM_VERSION_LESS_THAN(@"8.0"))
        self.blurEffectStyle = UIBlurEffectStyleExtraLight;
}

-(void)initViews
{
    // Setup overlay
    self.overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlay.alpha = 0;
    self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (self.enableOverlay)
        self.overlay.backgroundColor = [UIColor colorWithWhite:0. alpha:.4];
    
    // Setup gestures
    if (self.enableGestures)
    {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self.overlay addGestureRecognizer:tapGesture];
    }
    
    CGRect frame = [self frameHidden];
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        self.view = [[UIView alloc] initWithFrame:frame];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.view.backgroundColor = self.backgroundColor;
#pragma clang diagnostic pop
    }
    else
    {
        if (@available(iOS 10.0, *)) {
            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
            self.view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        } else {
            // Fallback on earlier versions
        }
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    //1.Top Header Image
    UIImageView *background =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,180)];
    background.image = [UIImage imageNamed:@"header_sidebar_bg"];
    background.layer.shadowColor = [UIColor purpleColor].CGColor;
    background.layer.shadowOffset = CGSizeMake(0,0);
    background.layer.shadowOpacity = 0.5;
    background.layer.shadowRadius = 0.5;
    background.clipsToBounds = NO;
    [[(UIVisualEffectView *)self.view contentView] addSubview:background];
    
    //2.Menu Logo
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(15,85,70,70)];
    logo.image = [UIImage imageNamed:@"logo_icon"];
    //logo.layer.cornerRadius = 5.0f;
    //logo.clipsToBounds = YES;
    //logo.layer.borderWidth = 1.0f;
    //logo.layer.borderColor = [UIColor whiteColor].CGColor;
    [[(UIVisualEffectView *)self.view contentView] addSubview:logo];
    
    //3.App Name
    UILabel *lblname;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        lblname = [[UILabel alloc] initWithFrame:CGRectMake(100,92,280,30)];
    } else {
        lblname = [[UILabel alloc] initWithFrame:CGRectMake(100,92,170,30)];
    }
    lblname.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    lblname.textAlignment = NSTextAlignmentLeft;
    lblname.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:23.0f];
    lblname.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.9f];
    //lblname.backgroundColor = [UIColor redColor];
    [[(UIVisualEffectView *)self.view contentView] addSubview:lblname];
    
    //4.App Tagline
    UILabel *lbltagline;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        lbltagline = [[UILabel alloc] initWithFrame:CGRectMake(100,120,280,30)];
    } else {
        lbltagline = [[UILabel alloc] initWithFrame:CGRectMake(100,120,170,30)];
    }
    lbltagline.text = @"Watch Live TV";
    lbltagline.textAlignment = NSTextAlignmentLeft;
    lbltagline.font = [UIFont fontWithName:@"Montserrat-Medium" size:14.0f];
    lbltagline.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.7f];
    //lbltagline.backgroundColor = [UIColor redColor];
    [[(UIVisualEffectView *)self.view contentView] addSubview:lbltagline];
    
    //5.Setup Tableview Position
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 190, self.view.frame.size.width, self.view.frame.size.height-230) style:UITableViewStylePlain];
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.separatorColor   = [UIColor clearColor];
    self.tableView.backgroundColor  = [UIColor clearColor];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight == 568) {
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [[(UIVisualEffectView *)self.view contentView] addSubview:self.tableView];
}

#pragma mark - Appearance
-(void)show
{
    [self initViews];
    
    [ROOTVC.view addSubview:self.overlay];
    [ROOTVC.view addSubview:self.view];
    
    CGRect frame = [self frameShowed];
    
    [UIView animateWithDuration:0.275 animations:^
     {
         self.view.frame = frame;
         self.overlay.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         if (self->_delegate && [self->_delegate respondsToSelector:@selector(sideMenuDidShow:)])
             [self->_delegate sideMenuDidShow:self];
     }];
}

-(void)showWithSize:(CGFloat)size
{
    self.size = size;
    [self show];
}

-(void)hide
{
    [UIView animateWithDuration:0.275 animations:^
     {
         self.view.frame = [self frameHidden];
         self.overlay.alpha = 0.;
     }
                     completion:^(BOOL finished)
     {
         if (self->_delegate && [self->_delegate respondsToSelector:@selector(sideMenuDidHide:)])
             [self->_delegate sideMenuDidHide:self];
         
         [self.view removeFromSuperview];
         [self.overlay removeFromSuperview];
         [self.overlay removeGestureRecognizer:self->tapGesture];
         
         self.overlay = nil;
         self.tableView = nil;
         self.view = nil;
     }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource numberOfSectionsInSideMenu:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource sideMenu:self numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *imageViewIcon;
    UILabel *title;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:self.selectionColor];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    VKSideMenuItem *item = [self.dataSource sideMenu:self itemForRowAtIndexPath:indexPath];
    
    CGFloat contentHeight = cell.frame.size.height * .8;
    CGFloat contentTopBottomPadding = cell.frame.size.height * .1;
    
    if (item.icon)
    {
        imageViewIcon = [cell.contentView viewWithTag:100];
        
        if (!imageViewIcon)
        {
            imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, contentTopBottomPadding+5, contentHeight-10, contentHeight-10)];
            imageViewIcon.tag = 100;
            [cell.contentView addSubview:imageViewIcon];
        }
        
        imageViewIcon.image = item.icon;
        
        if (self.iconsColor)
        {
            imageViewIcon.image = [imageViewIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            imageViewIcon.tintColor = [UIColor darkGrayColor];
        }
    }
    
    title = [cell.contentView viewWithTag:200];
    
    if (!title)
    {
        title = [[UILabel alloc] initWithFrame:CGRectMake(50, contentTopBottomPadding,  230, contentHeight)];
        title.tag  = 200;
        title.font = [UIFont fontWithName:@"Montserrat-Medium" size:16.0f];
        title.textColor = [UIColor darkGrayColor];
        title.textAlignment = NSTextAlignmentLeft;
        //title.adjustsFontSizeToFitWidth = YES;
        //title.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:title];
    }
    
    title.text      = item.title;
    //title.textColor = self.textColor;
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(sideMenu:didSelectRowAtIndexPath:)])
        [_delegate sideMenu:self didSelectRowAtIndexPath:indexPath];
    
    if (self.automaticallyDeselectRow)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.hideOnSelection)
        [self hide];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sideMenu:titleForHeaderInSection:)])
        return [self.delegate sideMenu:self titleForHeaderInSection:section].uppercaseString;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)sideMenu heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 44.0f;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:self.sectionTitleColor];
    [header.textLabel setFont:self.sectionTitleFont];
}

#pragma mark - GestureRecognition

-(void)addSwipeGestureRecognition:(UIView *)view
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwap:)];
    
    switch (self.direction)
    {
        case VKSideMenuDirectionFromTop:
            swipe.direction = UISwipeGestureRecognizerDirectionDown;
            break;
            
        case VKSideMenuDirectionFromLeft:
            swipe.direction = UISwipeGestureRecognizerDirectionRight;
            break;

            
        case VKSideMenuDirectionFromBottom:
            swipe.direction = UISwipeGestureRecognizerDirectionUp;
            break;

            
        case VKSideMenuDirectionFromRight:
            swipe.direction = UISwipeGestureRecognizerDirectionLeft;
            break;
    }
    
    [view addGestureRecognizer:swipe];
}

-(void)didTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
        [self hide];
}

-(void)didSwap:(UISwipeGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded && self.enableGestures)
        [self showWithSize:self.size];
}

#pragma mark - Helpers

-(CGRect)frameHidden
{
    CGRect frame = CGRectZero;
    
    switch (self.direction)
    {
        case VKSideMenuDirectionFromTop:
            frame = CGRectMake(0, -self.size, [UIScreen mainScreen].bounds.size.width, self.size);
            break;
            
        case VKSideMenuDirectionFromLeft:
            frame = CGRectMake(-self.size, 0, self.size, [UIScreen mainScreen].bounds.size.height);
            break;
            
        case VKSideMenuDirectionFromBottom:
            frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.size);
            break;
            
        case VKSideMenuDirectionFromRight:
            frame = CGRectMake([UIScreen mainScreen].bounds.size.width + self.size, 0, self.size, [UIScreen mainScreen].bounds.size.height);
            break;
    }
    
    return frame;
}

-(CGRect)frameShowed
{
    CGRect frame = self.view.frame;
    
    switch (self.direction)
    {
        case VKSideMenuDirectionFromTop:
            frame.origin.y = 0;
            break;
            
        case VKSideMenuDirectionFromLeft:
            frame.origin.x = 0;
            break;
            
        case VKSideMenuDirectionFromBottom:
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.size;
            break;
            
        case VKSideMenuDirectionFromRight:
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - self.size;
            break;
    }
    
    return frame;
}

@end
