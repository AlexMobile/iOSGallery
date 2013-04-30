//
//  AMPhotoGallery.h
//  AMPhotoGallery
//
//  Created by Alexey Golovenkov on 30.04.13.
//  Copyright (c) 2013 Alexey Golovenkov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AMPhotoGalleryOrientation) {
	AMPhotoGalleryOrientationHorizontal,
	AMPhotoGalleryOrientationVertical
};

/**
 Photo gallery component for iOS
 */
@interface AMPhotoGallery : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray* photos;
@property (nonatomic, assign) BOOL fullScreenMode;

/// Orientation. Shows indicates
@property (nonatomic, assign) AMPhotoGalleryOrientation orientation;

/// Size of non-active
@property (nonatomic, assign) CGFloat littleImageRatio;


@end
