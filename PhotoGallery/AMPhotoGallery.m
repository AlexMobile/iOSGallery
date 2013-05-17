//
//  PhotoGallery_iPad.m
//  AMPhotoGallery
//
//  Created by Alexey Golovenkov on 30.04.13.
//  Copyright (c) 2013 Alexey Golovenkov. All rights reserved.
//

#import "AMPhotoGallery.h"

@interface AMPhotoGallery () {
	NSMutableArray* _images;
    CGSize _imageSize;
    CGSize _pageSize;
	CGSize _littleSizedPageSize;
	CGRect _littleSizedFrame;
    UITapGestureRecognizer* _gestureRecognizer;
    NSMutableArray* _imageViews;
	NSInteger _pageIndex;
	BOOL _blocked;
}

@property (nonatomic, strong) UIScrollView* scroll;

- (void)baseInit;
- (void)reloadPhotos;
- (void)changeMode;

@end

@implementation AMPhotoGallery

- (void) dealloc {
	for (UIView* photo in _imageViews) {
		[photo removeFromSuperview];
	}
	_imageViews = nil;
}

- (void)baseInit {
    self.scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scroll.pagingEnabled = YES;
    self.scroll.clipsToBounds = NO;
    self.scroll.delegate = self;
	self.littleImageRatio = 0.6;
    [self addSubview:self.scroll];
    _imageViews = [NSMutableArray new];
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMode)];
    _gestureRecognizer.delegate = self;
    [self addGestureRecognizer:_gestureRecognizer];
	_expandedMode = NO;
	_blocked = NO;
	_images = [NSMutableArray alloc];
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

#pragma mark -
#pragma mark UIView methods

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	if (_expandedMode) {
		_expandedFrame = frame;
	} else {
		_collapsedFrame = frame;
	}
}

#pragma mark -
#pragma mark Private methods

- (CGSize)imageSize {
    if ([self.images count] == 0) {
        return CGSizeZero;
    }
    UIImage* image = [self.images objectAtIndex:0];
    return image.size;
}

- (void)reloadPhotos {
    _imageSize = [self imageSize];
    CGFloat ratio = self.bounds.size.height / _imageSize.height;
    _pageSize = CGSizeMake(_imageSize.width * ratio, self.bounds.size.height);
    self.scroll.frame = CGRectMake((NSInteger)((self.bounds.size.width - _pageSize.width) / 2), 0, _pageSize.width, _pageSize.height);
    NSInteger imagesCount = [self.images count];
    for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [[UIImageView alloc] initWithImage:[self.images objectAtIndex:i]];
        image.frame = CGRectMake(i * _pageSize.width, 0, _pageSize.width, _pageSize.height);
        image.userInteractionEnabled = NO;
        [self.scroll addSubview:image];
        [_imageViews addObject:image];
    }
    self.scroll.contentSize = CGSizeMake(_pageSize.width * imagesCount, _pageSize.height);
    [self scrollViewDidScroll:self.scroll];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.scroll.delegate = self;
	self.scroll.pagingEnabled = YES;
	self.scroll.contentSize = CGSizeMake(_pageSize.width * [self.images count], _pageSize.height);
	_blocked = NO;
}

- (void)collapseAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	NSInteger imagesCount = [_imageViews count];
	
	_pageSize = _littleSizedPageSize;
	self.scroll.frame = CGRectMake((self.bounds.size.width - _pageSize.width) / 2, 0, _pageSize.width, _pageSize.height);
	self.scroll.contentSize = CGSizeMake(_pageSize.width * imagesCount, _pageSize.height);	
	self.scroll.contentOffset = CGPointMake(_pageIndex * _pageSize.width, 0);
	
	CGSize size = CGSizeMake(_pageSize.width * self.littleImageRatio, _pageSize.height * self.littleImageRatio);
	for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [_imageViews objectAtIndex:i];
		if (i == _pageIndex) {
        	image.frame = CGRectMake(i * _pageSize.width, 0, _pageSize.width, _pageSize.height);
		} else {			
			image.frame = CGRectMake(i * _pageSize.width + (_pageSize.width - size.width) / 2, (_pageSize.height - size.height) / 2, size.width, size.height);
		}
    }
	self.scroll.delegate = self;
	self.scroll.pagingEnabled = YES;
	_blocked = NO;
}


- (void)setFullScreenMode {
	_blocked = YES;
	self.scroll.delegate = nil;
	self.scroll.pagingEnabled = NO;
	_pageIndex = self.scroll.contentOffset.x / _pageSize.width;
	_littleSizedFrame = self.frame;
	CGRect newFrame = CGRectMake(0, self.frame.origin.y, self.superview.bounds.size.width, _imageSize.height);
	_littleSizedPageSize = _pageSize;
	_pageSize = _imageSize;
 	self.scroll.frame = CGRectMake((self.bounds.size.width - _pageSize.width) / 2, 0, _pageSize.width, _pageSize.height);
	NSInteger imagesCount = [_imageViews count];
	self.scroll.contentSize = CGSizeMake(_pageSize.width * (imagesCount + 1), _pageSize.height);
	self.scroll.contentOffset = CGPointMake(_pageIndex * _pageSize.width, 0);
	CGFloat offset = (_pageIndex + 0.5) * _pageSize.width - (_pageIndex + 0.5) * _littleSizedPageSize.width;
	for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [_imageViews objectAtIndex:i];
		CGRect imageFrame = image.frame;
		imageFrame.origin.x += offset;
		image.frame = imageFrame;
	}
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.3];	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.frame = newFrame;
	self.scroll.frame = CGRectMake((NSInteger)((newFrame.size.width - _pageSize.width) / 2), 0, _pageSize.width, _pageSize.height);
	
	CGSize size = CGSizeMake(_pageSize.width * self.littleImageRatio, _pageSize.height * self.littleImageRatio);
	for (NSInteger i = 0; i < imagesCount; ++i) {
        UIImageView* image = [_imageViews objectAtIndex:i];
		if (i == _pageIndex) {
        	image.frame = CGRectMake(i * _pageSize.width, 0, _pageSize.width, _pageSize.height);
		} else {			
			image.frame = CGRectMake(i * _pageSize.width + (_pageSize.width - size.width) / 2, (_pageSize.height - size.height) / 2, size.width, size.height);
		}
    }
	[UIView commitAnimations];
}

- (void)removeFullScreenMode {
	_blocked = YES;
	self.scroll.delegate = nil;
	self.scroll.pagingEnabled = NO;
	_pageIndex = self.scroll.contentOffset.x / _pageSize.width;
	
	NSInteger imagesCount = [_imageViews count];
	CGFloat offset = (_pageIndex + 0.5) * _imageSize.width - (_pageIndex + 0.5) * _littleSizedPageSize.width;
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.3];	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(collapseAnimationDidStop:finished:context:)];
	
	self.frame = _littleSizedFrame;
	self.scroll.frame = CGRectMake((self.bounds.size.width - _pageSize.width) / 2, 0, _pageSize.width, _pageSize.height);
	CGSize size = CGSizeMake(_littleSizedPageSize.width * self.littleImageRatio, _littleSizedPageSize.height * self.littleImageRatio);
	for (NSInteger i = 0; i < imagesCount; ++i) {
		UIImageView* image = [_imageViews objectAtIndex:i];
		if (i == _pageIndex) {
        	image.frame = CGRectMake(i * _littleSizedPageSize.width + offset, 0, _littleSizedPageSize.width, _littleSizedPageSize.height);
		} else {			
			image.frame = CGRectMake(i * _littleSizedPageSize.width + (_littleSizedPageSize.width - size.width) / 2 + offset, (_littleSizedPageSize.height - size.height) / 2, size.width, size.height);
		}
	}
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Properties

- (void)setExpandedFrame:(CGRect)expandedFrame {
	_expandedFrame = expandedFrame;
	if (_expandedMode) {
		self.frame = expandedFrame;
	}
}

- (void)setCollapsedFrame:(CGRect)collapsedFrame {
	_collapsedFrame = collapsedFrame;
	if (_expandedMode == NO) {
		self.frame = collapsedFrame;
	}
}

- (NSArray *)images {
	return [NSArray arrayWithArray:_images];
}

- (void)setExpandedMode:(BOOL)expandedMode {
	if (_expandedMode == expandedMode) {
		return;
	}
	_expandedMode = expandedMode;
	_expandedMode ? [self setFullScreenMode] : [self removeFullScreenMode];
}

#pragma mark -
#pragma mark UIView methods

- (UIView*)hitTest:(CGPoint) point withEvent:(UIEvent*)event {
    if ([self pointInside:point withEvent:event]) {
        return self.scroll;
    }
    return nil;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    CGFloat offset = scrollView.contentOffset.x + _pageSize.width / 2;
    CGFloat percentsOfFullSize;
    NSInteger imagesCount = [_imageViews count];
    for (NSInteger i = 0; i < imagesCount; ++i) {
        UIView* view = [_imageViews objectAtIndex:i];
        CGFloat imageOffset = fabsf(offset - view.center.x);
        if (imageOffset >= _pageSize.width) {
            percentsOfFullSize = self.littleImageRatio;
        } else {
            percentsOfFullSize = 1 - (imageOffset / _pageSize.width) * (1 - self.littleImageRatio);
        }
        CGSize size = CGSizeMake(_pageSize.width * percentsOfFullSize, _pageSize.height * percentsOfFullSize);
        view.frame = CGRectMake(i * _pageSize.width + (_pageSize.width - size.width) / 2, (_pageSize.height - size.height) / 2, size.width, size.height);
    }
}

- (void)changeMode {
    self.expandedMode = !self.expandedMode;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
	if (_blocked) {
		return NO;
	}
    return (touch.view == self.scroll);
}

#pragma mark -
#pragma mark images methods

- (void)addImage:(UIImage *)image {
	[_images addObject:image];
	[self reloadPhotos];
}

- (void)addImagesFromArray:(NSArray *)images {
	[_images addObjectsFromArray:images];
	[self reloadPhotos];
}

- (void)removeImageWithIndex:(NSUInteger)index animated:(BOOL)animated completionBlock:(void (^)(BOOL))completion {
	// TODO: to be implemented
}

@end
