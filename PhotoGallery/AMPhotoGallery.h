//
//  AMPhotoGallery.h
//  AMPhotoGallery
//
//  Created by Alexey Golovenkov on 30.04.13.
//  Copyright (c) 2013 Alexey Golovenkov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AMPhotoGallery : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray* photos;
@property (nonatomic) BOOL fullScreenMode;

@end
