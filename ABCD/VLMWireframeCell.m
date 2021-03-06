//
//  VLMWireframeCell.m
//  Cartoonist
//
//  Created by David Lu on 1/9/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMWireframeCell.h"
#import "VLMPaddedLabel.h"
#import "VLMPanelModel.h"
#import "VLMViewController.h"

@implementation VLMWireframeCell

+ (NSString *)CellIdentifier
{
    return @"VLMWireframeCellID";
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setLabel:[[VLMPaddedLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.normalFrame.size.width, self.normalFrame.size.height)]];
        [self.label setTextColor:[UIColor whiteColor]];
        [self.label setFont:FONT_WIREFRAME];
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setAdjustsFontSizeToFitWidth:YES];
        [self.label setNumberOfLines:100];
        [self.base addSubview:self.label];
        
        if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
        {
            self.label.padding = 20.0f;
        }
        else
        {
            self.label.padding = 120.0f;
        }

    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
	[super applyLayoutAttributes:layoutAttributes];
    
    CGAffineTransform t;
    if (UIDeviceOrientationIsPortrait([VLMViewController orientation]))
    {
        t = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0f);
    } else {
        t = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/2.0f);
    }
/*
    [UIView animateWithDuration:ROT_DURATION delay:0.0f options:ROT_OPTIONS animations:^{
        self.label.transform = t;
    } completion:^(BOOL completed){}];
*/
    self.label.transform = t;

}


- (void)configureWithModel:(VLMPanelModel *)model
{
    [super configureWithModel:model];
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
        self.label.attributedText = attributedString;
        
        //http://www.colourlovers.com/palette/77121/Good_Friends
        switch (model.index%5) {
            case 0:
                //217,206,178
                [self.base setBackgroundColor:[UIColor colorWithRed:217.0f/360.0f green:206.0f/360.0f blue:178.0f/360.0f alpha:1.0f]];
                [self.label setTextColor:[UIColor whiteColor]];
                break;
            case 1:
                //148,140,117
                [self.base setBackgroundColor:[UIColor colorWithRed:148.0f/360.0f green:146.0f/360.0f blue:117.0f/360.0f alpha:1.0f]];
                [self.label setTextColor:[UIColor whiteColor]];
                break;
            case 2:
                //213,222,217
                [self.base setBackgroundColor:[UIColor colorWithRed:213.0f/360.0f green:222.0f/360.0f blue:217.0f/360.0f alpha:1.0f]];
                [self.label setTextColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];                break;
            case 3:
                //122,106,83
                [self.base setBackgroundColor:[UIColor colorWithRed:122.0f/360.0f green:106.0f/360.0f blue:83.0f/360.0f alpha:1.0f]];
                [self.label setTextColor:[UIColor whiteColor]];
                break;
            case 4:
                //153,178,183
                [self.base setBackgroundColor:[UIColor colorWithRed:153.0f/360.0f green:178.0f/360.0f blue:183.0f/360.0f alpha:1.0f]];
                [self.label setTextColor:[UIColor whiteColor]];
                break;
                
            default:
                //46,38,51
                [self.base setBackgroundColor:[UIColor colorWithRed:46.0f/360.0f green:38.0f/360.0f blue:51.0f/360.0f alpha:1.0f]];
                [self.label setTextColor:[UIColor whiteColor]];
                break;
        }
	}
	self.cellType = model.cellType;
}

@end
