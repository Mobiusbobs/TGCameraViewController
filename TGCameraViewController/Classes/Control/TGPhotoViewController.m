//
//  TGPhotoViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 15/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

@import AssetsLibrary;
#import "TGPhotoViewController.h"
#import "TGAssetsLibrary.h"
#import "TGCameraColor.h"
#import "TGCameraFilterView.h"
#import "UIImage+CameraFilters.h"
#import "TGTintedButton.h"
#import "TGCameraFilterCollectionViewCell.h"

static NSString* const kTGCacheSatureKey = @"TGCacheSatureKey";
static NSString* const kTGCacheCurveKey = @"TGCacheCurveKey";
static NSString* const kTGCacheVignetteKey = @"TGCacheVignetteKey";

@interface TGPhotoViewController ()

<
    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet TGTintedButton *cancelButton;
@property (weak, nonatomic) IBOutlet TGTintedButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

@property (weak) id<TGCameraDelegate> delegate;
@property (strong, nonatomic) UIView *detailFilterView;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSCache *cachePhoto;
@property (nonatomic) BOOL albumPhoto;

- (IBAction)backTapped;
- (IBAction)confirmTapped;

- (void)addDetailViewToButton:(UIButton *)button;
+ (instancetype)newController;

@end



@implementation TGPhotoViewController

+ (instancetype)newWithDelegate:(id<TGCameraDelegate>)delegate photo:(UIImage *)photo
{
    TGPhotoViewController *viewController = [TGPhotoViewController newController];
    
    if (viewController) {
        viewController.delegate = delegate;
        viewController.photo = photo;
        viewController.cachePhoto = [[NSCache alloc] init];
    }
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_collectionView registerClass:[TGCameraFilterCollectionViewCell class]
         forCellWithReuseIdentifier:kTGCameraFilterCollectionViewCellIdentifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) <= 480) {
        _topViewHeight.constant = 0;
    }
    
    _photoView.clipsToBounds = YES;
    _photoView.image = _photo;
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    [_cancelButton setImage:[UIImage imageNamed:@"CameraBack" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_confirmButton setImage:[UIImage imageNamed:@"CameraNext" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    NSString *firstDigit = [[language componentsSeparatedByString:@"-"] firstObject];
    if ([firstDigit isEqualToString:@"zh"]) {
        _tipLabel.text = @"選擇濾鏡";
    } else {
        _tipLabel.text = @"Select Your Filter";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark - Controller actions

- (IBAction)backTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmTapped
{
    if ( [_delegate respondsToSelector:@selector(cameraWillTakePhoto)]) {
        [_delegate cameraWillTakePhoto];
    }
    
    if ([_delegate respondsToSelector:@selector(cameraDidTakePhoto: andViewController:)]) {
        _photo = _photoView.image;
        
        if (_albumPhoto) {
            [_delegate cameraDidSelectAlbumPhoto:_photo andViewController:self.navigationController];
        } else {
            [_delegate cameraDidTakePhoto:_photo andViewController:self.navigationController];
        }
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        TGAssetsLibrary *library = [TGAssetsLibrary defaultAssetsLibrary];
        
        void (^saveJPGImageAtDocumentDirectory)(UIImage *) = ^(UIImage *photo) {
            [library saveJPGImageAtDocumentDirectory:_photo resultBlock:^(NSURL *assetURL) {
                [_delegate cameraDidSavePhotoAtPath:assetURL andViewController:self.navigationController];
            } failureBlock:^(NSError *error) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoWithError:)]) {
                    [_delegate cameraDidSavePhotoWithError:error];
                }
            }];
        };
        
        if ([[TGCamera getOption:kTGCameraOptionSaveImageToAlbum] boolValue] && status != ALAuthorizationStatusDenied) {
            [library saveImage:_photo resultBlock:^(NSURL *assetURL) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:andViewController:)]) {
                    [_delegate cameraDidSavePhotoAtPath:assetURL andViewController:self.navigationController];
                }
            } failureBlock:^(NSError *error) {
                saveJPGImageAtDocumentDirectory(_photo);
            }];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                saveJPGImageAtDocumentDirectory(_photo);
            }
        }
    }
}

#pragma mark -
#pragma mark - Filter view actions

- (NSString *)cacheKeyWithFilterType:(TGCameraFilterType)type
{
    switch (type) {
        case TGCameraFilterTypeSaturate:
            return kTGCacheSatureKey;
            break;
        case TGCameraFilterTypeCurve:
            return kTGCacheCurveKey;
            break;
        case TGCameraFilterTypeVignette:
            return kTGCacheVignetteKey;
            break;
        default:
            return @"None";
            break;
    }
}

- (IBAction)defaultFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = _photo;
}

- (IBAction)satureFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheSatureKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheSatureKey];
    } else {
        [_cachePhoto setObject:[_photo saturateImage:1.8 withContrast:1] forKey:kTGCacheSatureKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheSatureKey];
    }
    
}

- (IBAction)curveFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheCurveKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheCurveKey];
    } else {
        [_cachePhoto setObject:[_photo curveFilter] forKey:kTGCacheCurveKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheCurveKey];
    }
}

- (IBAction)vignetteFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheVignetteKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheVignetteKey];
    } else {
        [_cachePhoto setObject:[_photo vignetteWithRadius:0 intensity:6] forKey:kTGCacheVignetteKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheVignetteKey];
    }
}


#pragma mark -
#pragma mark - Private methods

+ (instancetype)newController
{
    return [[self alloc] initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return TGCameraFilterTypeCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGCameraFilterCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kTGCameraFilterCollectionViewCellIdentifier
                                              forIndexPath:indexPath];
    
    
    [cell updateImageWithFilterType:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cacheKey = [self cacheKeyWithFilterType:indexPath.row];
    
    if ([_cachePhoto objectForKey:cacheKey]) {
        _photoView.image = [_cachePhoto objectForKey:cacheKey];
    } else {
        [_cachePhoto setObject:[_photo applyFilterWithType:indexPath.row]
                        forKey:cacheKey];
        _photoView.image = [_cachePhoto objectForKey:cacheKey];
    }
}
@end
