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
        [self setLabel:[[VLMPaddedLabel alloc] initWithFrame:self.normalFrame]];
        [self.label setTextColor:[UIColor whiteColor]];
        [self.label setFont:FONT_WIREFRAME];
        [self.label setBackgroundColor:[UIColor blackColor]];
        [self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setAdjustsFontSizeToFitWidth:YES];
        [self.label setNumberOfLines:100];
        [self.contentView addSubview:self.label];

    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
	[super applyLayoutAttributes:layoutAttributes];
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
	}
	self.cellType = model.cellType;
}

@end
