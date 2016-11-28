//
//  TGCameraFilterCollectionViewCell.h
//  Pods
//
//  Created by ringtdblai on 2016/11/28.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+CameraFilters.h"

static NSString* const kTGCameraFilterCollectionViewCellIdentifier  = @"TGCameraFilterCollectionViewCell";


@interface TGCameraFilterCollectionViewCell : UICollectionViewCell

- (void)updateImageWithFilterType:(TGCameraFilterType)type;

@end
