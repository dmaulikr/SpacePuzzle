//
//  PlatformLever.h
//  SpacePuzzle
//
//  Created by Viktor on 21/11/13.
//  Copyright (c) 2013 WMD. All rights reserved.
//

#import "Element.h"

@class MovingPlatform;

@interface PlatformLever : Element
@property (nonatomic, assign) MovingPlatform* movingPlatform;
@property (nonatomic, assign) BOOL state;
-(id)initWithBridge: (MovingPlatform*)e X:(NSInteger)x Y:(NSInteger)y;

@end
