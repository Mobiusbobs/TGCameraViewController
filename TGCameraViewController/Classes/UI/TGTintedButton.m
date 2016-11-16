//
//  TGTintedButton.m
//  TGCameraViewController
//
//  Created by Mike Sprague on 3/30/15.
//  Copyright (c) 2015 Tudo Gostoso Internet. All rights reserved.
//

#import "TGTintedButton.h"
#import "TGCameraColor.h"

@implementation TGTintedButton

- (void)setNeedsLayout {
    [super setNeedsLayout];
    //[self updateTintIfNeeded];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {

    [super setBackgroundImage:image forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
}


- (void)updateTintIfNeeded {
    UIColor *color = self.customTintColorOverride != nil ? self.customTintColorOverride : [TGCameraColor tintColor];
    
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    
    if (self.tintColor != color) {
        [self setTintColor:color];
        
        UIImage *backgroundImage = [[self backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:renderingMode];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        UIImage *image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:renderingMode];
        [self setImage:image forState:UIControlStateNormal];
    }
}

@end
