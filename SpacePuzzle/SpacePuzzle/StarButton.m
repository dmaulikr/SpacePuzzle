//
//  Button.m
//  SpacePuzzle
//
//  Created by Viktor on 21/11/13.
//  Copyright (c) 2013 WMD. All rights reserved.
//

#import "StarButton.h"
#import "Star.h"

@implementation StarButton
@synthesize blocking = _blocking;
@synthesize star = _star;
@synthesize state = _state;

-(id)init {
    if(self = [super init]){
        _blocking = NO;
        _state = NO;
    }
    return self;
}

-(id)initWithX:(NSInteger)x Y:(NSInteger)y {
    if(self = [super initWithX:x Y:y]) {
        _blocking = NO;
        _state = NO;
    }
    return self;
}

-(id)initWithStar:(Star*)e X:(NSInteger)x Y:(NSInteger)y{
    if(self = [super initWithX:x Y:y]) {
        _star = e;
    }
    return self;
}

-(void) doAction {
    _star.hidden = NO;
}

@end
