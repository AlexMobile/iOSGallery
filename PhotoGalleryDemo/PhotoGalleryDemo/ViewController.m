//
//  ViewController.m
//  PhotoGalleryDemo
//
//  Created by Alexey Golovenkov on 30.04.13.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

const NSInteger imagesCount = 7;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	for (NSInteger index = 0; index < imagesCount; ++index) {
		UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpeg", index]];
		[self.galleryView addImage:image];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
