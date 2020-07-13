//
//  LCBannerView.m
//
//  Created by Leo on 15/11/30.
//  Copyright © 2015年 Leo. All rights reserved.
//
//

#import "LCBannerView.h"

static CGFloat LCPageDistance = 10.0f;  // distance to bottom of pageControl

@interface LCBannerView () <UIScrollViewDelegate>

@property (nonatomic, weak  ) id<LCBannerViewDelegate> delegate;

@property (nonatomic, assign) CGFloat       timeInterval;

@property (nonatomic, strong) NSTimer       *timer;
@property (nonatomic, weak  ) UIScrollView  *scrollView;
@property (nonatomic, weak  ) UIPageControl *pageControl;

@property (nonatomic, assign) NSInteger     oldURLCount;

@end

@implementation LCBannerView

+ (instancetype)bannerViewWithFrame:(CGRect)frame delegate:(id<LCBannerViewDelegate>)delegate imageName:(NSString *)imageName count:(NSInteger)count timeInterval:(NSInteger)timeInterval currentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor pageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {

    return [[self alloc] initWithFrame:frame
                              delegate:delegate
                             imageName:imageName
                                 count:count
                         timeInterval:timeInterval
         currentPageIndicatorTintColor:currentPageIndicatorTintColor
                pageIndicatorTintColor:pageIndicatorTintColor];
}

+ (instancetype)bannerViewWithFrame:(CGRect)frame delegate:(id<LCBannerViewDelegate>)delegate imageURLs:(NSArray *)imageURLs TitleArray:(NSArray *)TitleArray SubTitleArray:(NSArray *)SubTitleArray IDArray:(NSArray *)IDArray TypeArray:(NSArray *)TypeArray placeholderImageName:(NSString *)placeholderImageName timeInterval:(NSInteger)timeInterval currentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor pageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {

    return [[self alloc] initWithFrame:frame
                              delegate:delegate
                             imageURLs:imageURLs
                           TitleArray:TitleArray
                            SubTitleArray:SubTitleArray
                            IDArray:IDArray
                            TypeArray:TypeArray
                  placeholderImageName:placeholderImageName
                         timeInterval:timeInterval
         currentPageIndicatorTintColor:currentPageIndicatorTintColor
                pageIndicatorTintColor:pageIndicatorTintColor];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<LCBannerViewDelegate>)delegate imageName:(NSString *)imageName count:(NSInteger)count timeInterval:(NSInteger)timeInterval currentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor pageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {

    if (self = [super initWithFrame:frame]) {

        _delegate                      = delegate;
        _imageName                     = imageName;
        _count                         = count;
        _timeInterval                  = timeInterval;
        _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
        _pageIndicatorTintColor        = pageIndicatorTintColor;

        [self setupMainView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<LCBannerViewDelegate>)delegate imageURLs:(NSArray *)imageURLs TitleArray:(NSArray *)TitleArray SubTitleArray:(NSArray *)SubTitleArray IDArray:(NSArray *)IDArray TypeArray:(NSArray *)TypeArray placeholderImageName:(NSString *)placeholderImageName timeInterval:(NSInteger)timeInterval currentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor pageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
{
    if (self = [super initWithFrame:frame])
    {
        _delegate                      = delegate;
        _imageURLs                     = imageURLs;
        _TitleArray                    = TitleArray;
        _SubTitleArray                 = SubTitleArray;
        _IDArray                       = IDArray;
        _TypeArray                     = TypeArray;
        _count                         = imageURLs.count;
        _timeInterval                  = timeInterval;
        _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
        _pageIndicatorTintColor        = pageIndicatorTintColor;
        _placeholderImageName          = placeholderImageName;
        _oldURLCount                   = _count;
        [self setupMainView];
    }
    return self;
}

- (void)setupMainView {

    CGFloat scrollW = self.frame.size.width;
    CGFloat scrollH = self.frame.size.height;

    // set up scrollView
    [self addSubview:({

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollW, scrollH)];

        [self addSubviewToScrollView:scrollView];

        scrollView.delegate                       = self;
        scrollView.scrollsToTop                   = NO;
        scrollView.pagingEnabled                  = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentOffset                  = CGPointMake(scrollW, 0);
        scrollView.contentSize                    = CGSizeMake((self.count + 2) * scrollW, 0);

        self.scrollView = scrollView;
    })];

    [self addTimer];

    // set up pageControl
    [self addSubview:({
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(scrollW-220, scrollH - 10.0f - LCPageDistance, scrollW, 10.0f)];
        pageControl.numberOfPages                 = self.count;
        pageControl.userInteractionEnabled        = NO;
        pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor ?: [UIColor orangeColor];
        pageControl.pageIndicatorTintColor        = self.pageIndicatorTintColor ?: [UIColor lightGrayColor];
        self.pageControl = pageControl;
    })];
    
//    [self handleDidScroll];
}

- (void)addSubviewToScrollView:(UIScrollView *)scrollView
{
    CGFloat scrollW = self.frame.size.width;
    CGFloat scrollH = self.frame.size.height;
    
    for (int i = 0; i < self.count + 2; i++)
    {
        NSInteger tag = 0;
        NSString *currentImageName = nil;
        if (i == 0) {
            tag = self.count;
            currentImageName = [NSString stringWithFormat:@"%@_%02ld", self.imageName, (long)self.count];
        } else if (i == self.count + 1) {
            tag = 1;
            currentImageName = [NSString stringWithFormat:@"%@_01", self.imageName];
        } else {
            tag = i;
            currentImageName = [NSString stringWithFormat:@"%@_%02d", self.imageName, i];
        }
        
        //1.Banner ImageView
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = tag;
        if (self.imageName.length > 0) {    // from local
            UIImage *image = [UIImage imageNamed:currentImageName];
            if (!image) {
                NSLog(@"ERROR: No image named `%@`!", currentImageName);
            }
            imageView.image = image;
        } else {    // from internet
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURLs[tag - 1]]
                         placeholderImage:self.placeholderImageName.length > 0 ? [UIImage imageNamed:self.placeholderImageName] : nil];
        }
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.layer.cornerRadius = 5.0f;
        imageView.clipsToBounds          = YES;
        imageView.userInteractionEnabled = YES;
        imageView.contentMode            = UIViewContentModeScaleToFill;
        imageView.frame                  = CGRectMake(scrollW * i, 0, scrollW, scrollH);
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = imageView.bounds;
        gradient.startPoint = CGPointMake(1.0, 1.0); //Dark From bottom
        gradient.endPoint = CGPointMake(1.0, 0);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor blackColor] CGColor],
                           (id)[[UIColor clearColor] CGColor], nil];
        [imageView.layer insertSublayer:gradient atIndex:0];
        [scrollView addSubview:imageView];
        
        //2.Title Lable
        UILabel *lbltitle = [[UILabel alloc] initWithFrame:CGRectMake((scrollW * i)+10,scrollH-55,scrollW-20,30)];
        //[lbltitle setBackgroundColor:[UIColor redColor]];
        [lbltitle setFont:[UIFont fontWithName:@"Montserrat-Regular" size:18.0f]];
        [lbltitle setText:self.TitleArray[tag - 1]];
        lbltitle.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.7f];
        [lbltitle setTextAlignment:NSTextAlignmentLeft];
        [lbltitle setClipsToBounds:YES];
        [scrollView addSubview:lbltitle];
        
        //3.Sub Title Lable
        UILabel *lblsubtitle = [[UILabel alloc] initWithFrame:CGRectMake((scrollW * i)+10,scrollH-27,scrollW-100,20)];
        //[lblsubtitle setBackgroundColor:[UIColor redColor]];
        [lblsubtitle setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12.0f]];
        [lblsubtitle setText:self.SubTitleArray[tag - 1]];
        lblsubtitle.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.5f];
        [lblsubtitle setTextAlignment:NSTextAlignmentLeft];
        [lblsubtitle setClipsToBounds:YES];
        [scrollView addSubview:lblsubtitle];
        
        //4.Banner Image Click Event
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTaped:)];
        [imageView addGestureRecognizer:tap];
    }
}

- (void)imageViewTaped:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickedImageIndex:)]) {
        [self.delegate bannerView:self didClickedImageIndex:tap.view.tag - 1];
    }
    
    if (self.didClickedImageIndexBlock) {
        self.didClickedImageIndexBlock(self, tap.view.tag - 1);
    }
}

- (void)setPageDistance:(CGFloat)pageDistance {
    _pageDistance = pageDistance;

    if (pageDistance != LCPageDistance) {
        CGRect frame           = self.pageControl.frame;
        frame.origin.y         = self.frame.size.height - 10.0f - pageDistance;
        self.pageControl.frame = frame;
    }
}

- (void)setNotScrolling:(BOOL)notScrolling {
    _notScrolling = notScrolling;

    if (notScrolling) {
        self.pageControl.hidden       = YES;
        self.scrollView.scrollEnabled = NO;

        if (self.timer) {
            [self removeTimer];
        }
    }
}

- (void)setHidePageControl:(BOOL)hidePageControl {
    _hidePageControl = hidePageControl;
    
    self.pageControl.hidden = hidePageControl;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = [imageName copy];
    
    [self refreshMainViewCountChanged:NO];
}

- (void)setImageURLs:(NSArray *)imageURLs {
    _imageURLs = imageURLs;
    
    [self refreshMainViewCountChanged:imageURLs.count != self.oldURLCount];
    
    self.oldURLCount = imageURLs.count;
}

- (void)setCount:(NSInteger)count {
    _count = count;
    
    [self refreshMainViewCountChanged:YES];
}

- (void)setPlaceholderImageName:(NSString *)placeholderImageName {
    _placeholderImageName = placeholderImageName;
    
    [self refreshMainViewCountChanged:NO];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor ?: [UIColor orangeColor];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor ?: [UIColor lightGrayColor];
}

- (void)refreshMainViewCountChanged:(BOOL)changed {
    if (changed) {
        
        for (UIView *childView in self.scrollView.subviews) {
            [childView removeFromSuperview];
        }
        
        if (self.imageName.length == 0) {
            _count = self.imageURLs.count;
        }
        
        [self addSubviewToScrollView:self.scrollView];
        
        self.pageControl.numberOfPages = self.count;
        
    } else {
        
        for (int i = 0; i < self.count + 2; i++) {
            
            NSInteger tag = 0;
            NSString *currentImageName = nil;
            
            if (i == 0) {
                
                tag = self.count;
                
                currentImageName = [NSString stringWithFormat:@"%@_%02ld", self.imageName, (long)self.count];
                
            } else if (i == self.count + 1) {
                
                tag = 1;
                
                currentImageName = [NSString stringWithFormat:@"%@_01", self.imageName];
                
            } else {
                
                tag = i;
                
                currentImageName = [NSString stringWithFormat:@"%@_%02d", self.imageName, i];
            }
            
            UIImageView *imageView = [self.scrollView viewWithTag:tag];
            
            if (self.imageName.length > 0) {    // from local
                
                UIImage *image = [UIImage imageNamed:currentImageName];
                if (!image) {
                    
                    NSLog(@"ERROR: No image named `%@`!", currentImageName);
                }
                
                imageView.image = image;
                
            } else {    // from internet
                
                [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURLs[tag - 1]]
                             placeholderImage:self.placeholderImageName.length > 0 ? [UIImage imageNamed:self.placeholderImageName] : nil];
            }
        }
    }
}

- (void)handleDidScroll
{
    if ([self.delegate respondsToSelector:@selector(bannerView:didScrollToIndex:)]) {
        [self.delegate bannerView:self didScrollToIndex:self.pageControl.currentPage];
    }
    
    if (self.didScrollToIndexBlock) {
        self.didScrollToIndexBlock(self, self.pageControl.currentPage);
    }
}

#pragma mark - Timer

- (void)addTimer {

    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {

    if (self.timer) {

        [self.timer invalidate];

        self.timer = nil;
    }
}

- (void)nextImage
{
    NSInteger currentPage = self.pageControl.currentPage;
    [self.scrollView setContentOffset:CGPointMake((currentPage + 2) * self.scrollView.frame.size.width, 0)
                             animated:YES];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat scrollW = self.scrollView.frame.size.width;
    NSInteger currentPage = self.scrollView.contentOffset.x / scrollW;

    if (currentPage == self.count + 1) {

        self.pageControl.currentPage = 0;

    } else if (currentPage == 0) {

        self.pageControl.currentPage = self.count;

    } else {

        self.pageControl.currentPage = currentPage - 1;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    CGFloat scrollW = self.scrollView.frame.size.width;
    NSInteger currentPage = self.scrollView.contentOffset.x / scrollW;

    if (currentPage == self.count + 1) {

        self.pageControl.currentPage = 0;

        [self.scrollView setContentOffset:CGPointMake(scrollW, 0) animated:NO];

    } else if (currentPage == 0) {

        self.pageControl.currentPage = self.count;

        [self.scrollView setContentOffset:CGPointMake(self.count * scrollW, 0) animated:NO];

    } else {

        self.pageControl.currentPage = currentPage - 1;
    }
    
    [self handleDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    [self addTimer];
}

@end
