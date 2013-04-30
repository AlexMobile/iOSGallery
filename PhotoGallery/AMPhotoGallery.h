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

/// Array with all images
@property (nonatomic, readonly) NSArray* images;

/// Indicates if the gallery component works in full screen mode.
@property (nonatomic, assign) BOOL fullScreenMode;

/// Orientation. Shows indicates
@property (nonatomic, assign) AMPhotoGalleryOrientation orientation;

/// Size of non-active image
@property (nonatomic, assign) CGFloat littleImageRatio;

/**
 Adds new image to the of of the images list
 @param image Image to be added
 */
- (void)addImage:(UIImage*)image;

/**
 Adds a number of images to the end of images list
 @param images Images to be added
 */
- (void)addImagesFromArray:(NSArray*)images;

/**
 Removes image with specified index from gallery
 @param index Index of image to be removed. Nothing happens if image with such index does not exists.
 @param animated If YES, the removing process will be animated
 @param completion A block called after the removing has been finished
 */
- (void)removeImageWithIndex:(NSUInteger)index animated:(BOOL)animated completionBlock:(void (^)(BOOL finished))completion;

@end
