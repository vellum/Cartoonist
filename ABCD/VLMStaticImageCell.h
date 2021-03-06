//
//  VLMStaticImageCell.h
//  Cartoonist
//
//  Created by David Lu on 1/9/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface VLMStaticImageCell : VLMCollectionViewCell

@property (nonatomic, strong) VLMNarrationCaption *caption;
@property (nonatomic, strong) NSString *imagename;
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic) CGPoint captionCenterPortrait;
@property (nonatomic) CGPoint captionCenterLandscape;

@end
