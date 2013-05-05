//
//  AGPhotoGallery.h
//  AGPhotoGallery
//
//  Created by Alexey Golovenkov on 30.04.13.
//  Copyright (c) 2013 Alexey Golovenkov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AGPhotoGalleryOrientation) {
	AGPhotoGalleryOrientationHorizontal,
	AGPhotoGalleryOrientationVertical
};

/**
 Photo gallery component for iOS
 */
@interface AGPhotoGallery : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

/// Array with all images
@property (nonatomic, readonly) NSArray* images;

/// Indicates if the gallery component works in full screen mode. The default value is NO
@property (nonatomic, assign) BOOL expandedMode;

/// frame for expanded mode
@property (nonatomic, assign) CGRect expandedFrame;

/// frame for collapsed mode
@property (nonatomic, assign) CGRect collapsedFrame;

/// indicates if the gallery can be expanded/collapsed on tap. The default value is YES
@property (nonatomic, assign) BOOL canBeExpanded;

/// Orientation. Shows indicates
@property (nonatomic, assign) AGPhotoGalleryOrientation orientation;

/// Size of non-active image. The default value is 0.6
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

/**
 Changes component orientation. If new orientation is equal to the old and frame is not changed, completion is called immediately
 @param orientation New orientation.
 @param frame New frame. If this parameter is NULL, the frame is not change.
 @param animated If YES, the transition is being animated.
 @param A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
 */
- (void)setOrientation:(AGPhotoGalleryOrientation)orientation withFrame:(CGRect)frame animated:(BOOL)animated completionBlock:(void (^)(BOOL finished))completion;

@end
