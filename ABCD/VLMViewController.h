//
//  VLMViewController.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

// Data
#import "VLMDataSource.h"

// Views
#import "VLMCaptureView.h"
#import "VLMCollectionViewCell.h"
#import "VLMCollectionViewCellWithChoices.h"
#import "VLMGradient.h"

// Models
#import "VLMPanelModel.h"

// Layout
#import "VLMSinglePanelFlowLayout.h"

@interface VLMViewController : UICollectionViewController<UIScrollViewDelegate>
@property (nonatomic, strong) VLMCaptureView *capture;
@property (nonatomic, strong) VLMDataSource *dataSource;
@property (nonatomic, strong) VLMGradient *overlay;
@property (nonatomic, strong) UIScrollView *secretScrollview;
@property (nonatomic, strong) VLMSinglePanelFlowLayout *singlePanelFlow;
@property CGFloat currentPage;

@end
