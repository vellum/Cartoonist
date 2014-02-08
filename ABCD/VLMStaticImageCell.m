//
//  VLMStaticImageCell.m
//  Cartoonist
//
//  Created by David Lu on 1/9/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//
#import <objc/runtime.h>

#import "VLMStaticImageCell.h"
#import "VLMNarrationCaption.h"
#import "VLMCollectionViewLayoutAttributes.h"
#import "VLMPanelModel.h"
#import "VLMViewController.h"
#import "VLMApplicationData.h"
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"

@implementation VLMStaticImageCell

+ (NSString *)CellIdentifier
{
    return @"VLMStaticImageCellID";
}

static char * const kPanelModelAssociationKey = "VLM_PanelModel";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat edge = self.base.frame.size.height;
        [self setImageview:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, edge, edge)]];
        [self.imageview setCenter:CGPointMake(self.base.frame.size.width/2.0f, self.base.frame.size.height/2.0f)];
        [self.imageview setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageview setAutoresizingMask:UIViewAutoresizingNone];
        [self.imageview setOpaque:YES];
        [self.imageview setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:1.0f]];
        [self.base addSubview:self.imageview];
        [self.base setAutoresizingMask:UIViewAutoresizingNone];
        [self.contentView setAutoresizingMask:UIViewAutoresizingNone];

        VLMNarrationCaption *vvvv = [[VLMNarrationCaption alloc] initWithFrame:CGRectZero];
        [self setCaption:vvvv];
        [self.base addSubview:self.caption];
        self.imagename = nil;
        
        [self computeDimensions:60.0f];

    }
    return self;
}

- (void)computeDimensions:(CGFloat)targetHeight
{
    CGFloat pad;
    CGSize captionsize;
    if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
    {
        pad = roundf(kItemPadding*0.75f);
        captionsize = CGSizeMake(self.base.frame.size.width - pad * 2, targetHeight);
    }
    else
    {
        pad = roundf(kItemPadding*1.0f);
        captionsize = CGSizeMake(320.0f, targetHeight);
    }
    
    [self.caption setTransform:CGAffineTransformIdentity];
    
    CGRect b = self.caption.bounds;
    b.size.width = captionsize.width;
    b.size.height = captionsize.height;
    self.caption.bounds = b;
    //[self.caption setFrame:CGRectMake(pad, pad, captionsize.width, captionsize.height)];

    
    self.captionCenterPortrait = CGPointMake(pad + captionsize.width/2.0f, pad + captionsize.height/2.0f);
    self.captionCenterLandscape = CGPointMake(self.base.frame.size.width-self.caption.frame.size.height/2.0f - pad, 0 + self.caption.frame.size.width/2.0f + pad);
    [self.caption setCenter:self.captionCenterPortrait];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
	[super applyLayoutAttributes:layoutAttributes];
    
	// Important! Check to make sure we're actually this special subclass.
	// Failing to do so could cause the app to crash!
	if (![layoutAttributes isKindOfClass:[VLMCollectionViewLayoutAttributes class]])
	{
		return;
	}
    
	VLMCollectionViewLayoutAttributes *castedLayoutAttributes = (VLMCollectionViewLayoutAttributes *)layoutAttributes;
	switch (self.cellType)
	{
		case kCellTypeCaption :
            [self.caption applyLayoutAttributes:castedLayoutAttributes];
			break;
            
		case kCellTypeNoCaption :
			break;

		default :
			break;
	}
    
    CGAffineTransform t;
    if (UIDeviceOrientationIsPortrait([VLMViewController orientation]))
    {
        t = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0f);
        if (!CGPointEqualToPoint(self.caption.center, self.captionCenterPortrait)) {
            self.caption.center = self.captionCenterPortrait;
        }
    } else {
        t = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/2.0f);
        if (!CGPointEqualToPoint(self.caption.center, self.captionCenterLandscape)) {
            self.caption.center = self.captionCenterLandscape;
        }
    }
    if (!CGAffineTransformEqualToTransform(self.imageview.transform, t)){
        self.imageview.transform = t;
    }
    if (!CGAffineTransformEqualToTransform(self.caption.transform, t)){
        self.caption.transform = t;
    }

    /*
    [UIView animateWithDuration:ROT_DURATION delay:0.0f options:ROT_OPTIONS animations:^{
    } completion:^(BOOL completed){}];
     */

}

- (void)configureWithModel:(VLMPanelModel *)model
{
	[super configureWithModel:model];
    
    [self.imageview setFrame:CGRectMake(0, 0, self.base.frame.size.width, self.base.frame.size.height)];
	if ([model.name length] > 0)
	{
        NSString *labelText;
        if (USE_ALL_CAPS) {
            labelText = [model.name uppercaseString];
        } else {
            labelText = model.name;
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:FONT_LINE_SPACING];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        
        
        NSDictionary *attributes = @{NSFontAttributeName: FONT_CAPTION, NSParagraphStyleAttributeName: paragraphStyle};
       
        
        CGRect rect = [labelText boundingRectWithSize:(CGSize){self.caption.bounds.size.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
        
        [self computeDimensions:rect.size.height + 18.0f*2.0f];
        [self.caption setAttributedText:attributedString];
	}
	self.cellType = model.cellType;
    
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *imageFolder = [[resourcePath stringByAppendingPathComponent:@"Images"] copy];
    NSString *fileName = [model.image stringByAppendingString:@".png"];
    NSString *filePath = [imageFolder stringByAppendingPathComponent:fileName];
    NSLog(@"%@", filePath);
    
    VLMApplicationData *appdata = [VLMApplicationData sharedInstance];
    NSCache *cache = appdata.imageCache;
    BOOL shouldApplyImage = NO;
	switch (self.cellType)
	{
		case kCellTypeCaption :
			self.caption.hidden = NO;
            shouldApplyImage = YES;
			break;
            
		case kCellTypeNoCaption :
			self.caption.hidden = YES;
			self.imageview.hidden = NO;
            shouldApplyImage = YES;
			break;

		default :
			break;
	}
    
    if (shouldApplyImage) {
        if (model.image && [model.image length]>0)
        {
            // if exists in cache, add it
            if ([cache objectForKey:model.image])
            {
                UIImage *img = (UIImage *)[cache objectForKey:model.image];
                [self.imageview setImage:img];
            }
            else
            {
                [self.imageview setImage:nil];
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                // Now, we can’t cancel a block once it begins, so we’ll use associated objects and compare
                // index paths to see if we should continue once we have a resized image.
                objc_setAssociatedObject(self,
                                         kPanelModelAssociationKey,
                                         model,
                                         OBJC_ASSOCIATION_RETAIN);
   
                dispatch_async(queue, ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                    CGFloat scale = [UIScreen mainScreen].scale;
                    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                                        bounds:CGSizeMake(self.base.frame.size.height*scale, self.base.frame.size.height*scale)
                                                          interpolationQuality:kCGInterpolationHigh];

                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        VLMPanelModel *requestingModel =
                        (VLMPanelModel *)objc_getAssociatedObject(self, kPanelModelAssociationKey);
                        
                        if ([requestingModel.image isEqualToString:model.image]) {
                            [self.imageview setImage:resizedImage];
                        }
                        [cache setObject:resizedImage forKey:requestingModel.image];

                    });
                });
            }
        }
    }
}

@end
