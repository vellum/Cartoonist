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
@end