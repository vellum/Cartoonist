//
//  VLMCachableImageView.h
//  Cartoonist
//
//  Created by David Lu on 2/8/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMCachableImageView : UIImageView
- (void)loadImageNamed:(NSString*)fileName;
- (void)prepareForReuse;
@end
