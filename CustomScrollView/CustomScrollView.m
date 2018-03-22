//
//  CustomScrollView.m
//  CustomScrollView
//
//  Created by Ole Begemann on 16.04.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "CustomScrollView.h"

@interface CustomScrollView ()
@property CGRect startBounds;
@end

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    
    [self commonInitForCustomScrollView];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self == nil) {
        return nil;
    }
    
    [self commonInitForCustomScrollView];
    return self;
}

- (void)commonInitForCustomScrollView
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self pop_removeAnimationForKey:@"decelerate"];
            self.startBounds = self.bounds;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self];
            CGRect bounds = self.startBounds;
            
            CGFloat newBoundsOriginX = bounds.origin.x - translation.x;
            CGFloat minBoundsOriginX = 0.0;
            CGFloat maxBoundsOriginX = self.contentSize.width - bounds.size.width;
            bounds.origin.x = fmax(minBoundsOriginX, fmin(newBoundsOriginX, maxBoundsOriginX));
            
            CGFloat newBoundsOriginY = bounds.origin.y - translation.y;
            CGFloat minBoundsOriginY = 0.0;
            CGFloat maxBoundsOriginY = self.contentSize.height - bounds.size.height;
            bounds.origin.y = fmax(minBoundsOriginY, fmin(newBoundsOriginY, maxBoundsOriginY));
            
            self.bounds = bounds;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [panGestureRecognizer velocityInView:self];
            
            if (self.bounds.size.width >= self.contentSize.width) {
                velocity.x = 0;
            }
            if (self.bounds.size.height >= self.contentSize.height) {
                velocity.y = 0;
            }
            
            velocity.x = -velocity.x;
            velocity.y = -velocity.y;
            
            POPDecayAnimation *decayAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPViewBounds];
            
            POPAnimatableProperty *animatableProperty = [POPAnimatableProperty propertyWithName:@"com.anieduard.bounds.origin" initializer:^(POPMutableAnimatableProperty *prop) {
                
                prop.readBlock = ^(id obj, CGFloat values[]) {
                    values[0] = [obj bounds].origin.x;
                    values[1] = [obj bounds].origin.y;
                };
                
                prop.writeBlock = ^(id obj, const CGFloat values[]) {
                    CGRect tempBounds = [obj bounds];
                    tempBounds.origin.x = values[0];
                    tempBounds.origin.y = values[1];
                    [obj setBounds:tempBounds];
                };
                
                prop.threshold = 0.01;
            }];
            
            decayAnimation.property = animatableProperty;
            decayAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(velocity.x, velocity.y, 0, 0)];
            [self pop_addAnimation:decayAnimation forKey:@"decelerate"];
        }
            break;
        default:
            break;
    }
}

- (void)setBounds:(CGRect)bounds {
    CGFloat minBoundsOriginX = 0.0;
    CGFloat maxBoundsOriginX = self.contentSize.width - bounds.size.width;
    bounds.origin.x = fmax(minBoundsOriginX, fmin(bounds.origin.x, maxBoundsOriginX));
    
    CGFloat minBoundsOriginY = 0.0;
    CGFloat maxBoundsOriginY = self.contentSize.height - bounds.size.height;
    bounds.origin.y = fmax(minBoundsOriginY, fmin(bounds.origin.y, maxBoundsOriginY));
    
    [super setBounds:bounds];
}

@end
