//
//  TGCameraFilterCollectionViewCell.m
//  Pods
//
//  Created by ringtdblai on 2016/11/28.
//
//

#import "TGCameraFilterCollectionViewCell.h"

@interface TGCameraFilterCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation TGCameraFilterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        NSArray *resultantNibs = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class)
                                                               owner:nil
                                                             options:nil];
        
        if ([resultantNibs count] < 1) {
            return nil;
        }
        
        if (![[resultantNibs objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [resultantNibs objectAtIndex:0];
    }
    
    return self;    
}

- (void)updateImageWithFilterType:(TGCameraFilterType)type
{
    UIImage *image = [UIImage imageNamed:@"CameraEffectDefault"];
    self.imageView.image = [image applyFilterWithType:type];
    self.titleLabel.text = [self nameWithFilterType:type];
}

- (NSString *)nameWithFilterType:(TGCameraFilterType)type
{
    switch (type) {
        case TGCameraFilterTypeSaturate:
            return @"Bourbon";
            break;
        case TGCameraFilterTypeCurve:
            return @"Aviation";
            break;
        case TGCameraFilterTypeVignette:
            return @"Mojito";
            break;
        case TGCameraFilterTypeProcess:
            return @"Martini";
            break;
        case TGCameraFilterTypeTransfer:
            return @"Gin";
            break;
        case TGCameraFilterChrome:
            return @"Negroni";
            break;
        case TGCameraFilterMono:
            return @"Daiquiri";
            break;
        case TGCameraFilterClamp:
            return @"Alchemy";
            break;
        default:
            return @"None";
            break;
    }
}
@end
