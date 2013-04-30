//
//  PhotoGallery_iPad.m
//  AMPhotoGallery
//
//  Created by Alexey Golovenkov on 30.04.13.
//  Copyright (c) 2013 Alexey Golovenkov. All rights reserved.
//

#import "AMPhotoGallery.h"

@interface AMPhotoGallery () {
    CGSize imageSize;
    CGSize pageSize;
	CGSize littleSizedPageSize;
	CGRect littleSizedFrame;
    __strong UITapGestureRecognizer* gestureRecognizer;
    __strong NSMutableArray* imageViews;
	NSInteger pageIndex;
	BOOL blocked;
}

@property (nonatomic, strong) UIScrollView* scroll;

- (void)baseInit;
- (void)reloadPhotos;
- (void)changeMode;

@end

const CGFloat littlePictureRatio = 0.6;

@implementation AMPhotoGallery

@synthesize photos;
@synthesize scroll;
@synthesize fullScreenMode;

- (void) dealloc {
	for (UIView* photo in imageViews) {
		[photo removeFromSuperview];
	}
	imageViews = nil;
}

- (void)baseInit {
    scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scroll.pagingEnabled = YES;
    scroll.clipsToBounds = NO;
    scroll.delegate = self;
    [self addSubview:scroll];
    imageViews = [NSMutableArray new];
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMode)];
    gestureRecognizer.delegate = self;
    [self addGestureRecognizer:gestureRecognizer];
	fullScreenMode = NO;
	blocked = NO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

- (CGSize)imageSize {
    if ([photos count] == 0) {
        return CGSizeZero;
    }
    UIImage* image = [photos objectAtIndex:0];
    return image.size;
}

- (void)reloadPhotos {
    imageSize = [self imageSize];
    CGFloat ratio = self.bounds.size.height / imageSize.height;
    pageSize = CGSizeMake(imageSize.width * ratio, self.bounds.size.height);
    scroll.frame = CGRectMake((NSInteger)((self.bounds.size.width - pageSize.width) / 2), 0, pageSize.width, pageSize.height);
    NSInteger imagesCount = [photos count];
    for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [[UIImageView alloc] initWithImage:[photos objectAtIndex:i]];
        image.frame = CGRectMake(i * pageSize.width, 0, pageSize.width, pageSize.height);
        image.userInteractionEnabled = NO;
        [scroll addSubview:image];
        [imageViews addObject:image];
    }
    scroll.contentSize = CGSizeMake(pageSize.width * imagesCount, pageSize.height);
    [self scrollViewDidScroll:scroll];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.scroll.delegate = self;
	self.scroll.pagingEnabled = YES;
	scroll.contentSize = CGSizeMake(pageSize.width * [photos count], pageSize.height);
	blocked = NO;
}

- (void)collapseAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	NSInteger imagesCount = [imageViews count];
	
	pageSize = littleSizedPageSize;
	scroll.frame = CGRectMake((self.bounds.size.width - pageSize.width) / 2, 0, pageSize.width, pageSize.height);
	scroll.contentSize = CGSizeMake(pageSize.width * imagesCount, pageSize.height);	
	scroll.contentOffset = CGPointMake(pageIndex * pageSize.width, 0);
	
	CGSize size = CGSizeMake(pageSize.width * littlePictureRatio, pageSize.height * littlePictureRatio);
	for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [imageViews objectAtIndex:i];
		if (i == pageIndex) {
        	image.frame = CGRectMake(i * pageSize.width, 0, pageSize.width, pageSize.height);
		} else {			
			image.frame = CGRectMake(i * pageSize.width + (pageSize.width - size.width) / 2, (pageSize.height - size.height) / 2, size.width, size.height);
		}
    }
	self.scroll.delegate = self;
	self.scroll.pagingEnabled = YES;
	blocked = NO;
}


- (void)setFullScreenMode {
	blocked = YES;
	self.scroll.delegate = nil;
	self.scroll.pagingEnabled = NO;
	pageIndex = scroll.contentOffset.x / pageSize.width;
	littleSizedFrame = self.frame;
	CGRect newFrame = CGRectMake(0, self.frame.origin.y, self.superview.bounds.size.width, imageSize.height);
	littleSizedPageSize = pageSize;
	pageSize = imageSize;
 	scroll.frame = CGRectMake((self.bounds.size.width - pageSize.width) / 2, 0, pageSize.width, pageSize.height);
	NSInteger imagesCount = [imageViews count];
	scroll.contentSize = CGSizeMake(pageSize.width * (imagesCount + 1), pageSize.height);
	scroll.contentOffset = CGPointMake(pageIndex * pageSize.width, 0);
	CGFloat offset = (pageIndex + 0.5) * pageSize.width - (pageIndex + 0.5) * littleSizedPageSize.width;
	for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [imageViews objectAtIndex:i];
		CGRect imageFrame = image.frame;
		imageFrame.origin.x += offset;
		image.frame = imageFrame;
	}
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.3];	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.frame = newFrame;
	scroll.frame = CGRectMake((NSInteger)((newFrame.size.width - pageSize.width) / 2), 0, pageSize.width, pageSize.height);
	
	CGSize size = CGSizeMake(pageSize.width * littlePictureRatio, pageSize.height * littlePictureRatio);
	for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [imageViews objectAtIndex:i];
		if (i == pageIndex) {
        	image.frame = CGRectMake(i * pageSize.width, 0, pageSize.width, pageSize.height);
		} else {			
			image.frame = CGRectMake(i * pageSize.width + (pageSize.width - size.width) / 2, (pageSize.height - size.height) / 2, size.width, size.height);
		}
    }
	[UIView commitAnimations];
}

- (void)removeFullScreenMode {
	blocked = YES;
	self.scroll.delegate = nil;
	self.scroll.pagingEnabled = NO;
	pageIndex = scroll.contentOffset.x / pageSize.width; 	
	
	NSInteger imagesCount = [imageViews count];
	CGFloat offset = (pageIndex + 0.5) * imageSize.width - (pageIndex + 0.5) * littleSizedPageSize.width;
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.3];	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(collapseAnimationDidStop:finished:context:)];
	
	self.frame = littleSizedFrame;
	scroll.frame = CGRectMake((self.bounds.size.width - pageSize.width) / 2, 0, pageSize.width, pageSize.height);
	CGSize size = CGSizeMake(littleSizedPageSize.width * littlePictureRatio, littleSizedPageSize.height * littlePictureRatio);
	for (NSInteger i = 0; i < imagesCount; ++i) {
		UIImageView* image = [imageViews objectAtIndex:i];
		if (i == pageIndex) {
        	image.frame = CGRectMake(i * littleSizedPageSize.width + offset, 0, littleSizedPageSize.width, littleSizedPageSize.height);
		} else {			
			image.frame = CGRectMake(i * littleSizedPageSize.width + (littleSizedPageSize.width - size.width) / 2 + offset, (littleSizedPageSize.height - size.height) / 2, size.width, size.height);
		}
	}
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark properties

- (void)setPhotos:(NSArray*)photosArray {
    photos = photosArray;
    [self reloadPhotos];
}

- (void)setFullScreenMode:(BOOL)isFullScreen {
	if (fullScreenMode == isFullScreen) {
		return;
	}
	fullScreenMode = isFullScreen;
	fullScreenMode ? [self setFullScreenMode] : [self removeFullScreenMode];
}

#pragma mark -
#pragma mark UIView methods

- (UIView*)hitTest:(CGPoint) point withEvent:(UIEvent*)event {
    if ([self pointInside:point withEvent:event]) {
        return scroll;
    }
    return nil;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    CGFloat offset = scrollView.contentOffset.x + pageSize.width / 2;
    CGFloat percentsOfFullSize;
    NSInteger imagesCount = [imageViews count];
    for (NSInteger i = 0; i < imagesCount; ++i) {
        UIView* view = [imageViews objectAtIndex:i];
        CGFloat imageOffset = fabsf(offset - view.center.x);
        if (imageOffset >= pageSize.width) {
            percentsOfFullSize = littlePictureRatio;
        } else {
            percentsOfFullSize = 1 - (imageOffset / pageSize.width) * (1 - littlePictureRatio);
        }
        CGSize size = CGSizeMake(pageSize.width * percentsOfFullSize, pageSize.height * percentsOfFullSize);
        view.frame = CGRectMake(i * pageSize.width + (pageSize.width - size.width) / 2, (pageSize.height - size.height) / 2, size.width, size.height);
    }
}

- (void)changeMode {
    self.fullScreenMode = !self.fullScreenMode;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
	if (blocked) {
		return NO;
	}
    return (touch.view == scroll);
}

@end
