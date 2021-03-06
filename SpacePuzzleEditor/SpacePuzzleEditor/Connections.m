//
//  Connections.m
//  SpacePuzzleEditor
//
//  Created by IxD on 25/11/13.
//  Copyright (c) 2013 WMD. All rights reserved.
//

#import "Connections.h"
#import "Element.h"
#import "StarButton.h"
#import "Star.h"
#import "BridgeButton.h"
#import "Bridge.h"
#import "MovingPlatform.h"
#import "PlatformLever.h"

@implementation Connections
@synthesize connections = _connections;

-(id)init {
    if(self = [super init]) {
        _connections = [[NSMutableArray alloc] init];
    }
    return self;
}

/*
 *  Adds a connection from an element to an element, if possible. If the elements are already connected,
 *  the connection is updated. */
-(BOOL)addConnectionFrom: (Element*)from To: (Element*)to {
    // First, check if any of the elements already are connected. If so, update with new connection.
    for(int i = 0; i < _connections.count; i++) {
        Element *first = [[_connections objectAtIndex:i] objectAtIndex:0];
        Element *second = [[_connections objectAtIndex:i] objectAtIndex:1];
        
        // Element has connection. Update.
        if((from.x == first.x && from.y == first.y) || (to.x == second.x && to.y == second.y)) {
            // The case of a starbutton to star.
            if([Connections isAStarConnection:from To:to]) {
                [self removeConnection:CGPointMake(from.x, from.y)];
                [self removeConnection:CGPointMake(to.x, to.y)];
                [self createStarConnection:from To:to];
                return YES;
            }
            // A bridge button to bridge
            else if([Connections isABridgeConnection:from To:to]) {
                [self removeConnection:CGPointMake(from.x, from.y)];
                [self removeConnection:CGPointMake(to.x, to.y)];
                [self createBridgeConnection:from To:to];
                return YES;
            }
            // A lever to platform
            else if([Connections isAMovingPlatformConnection:from To:to]) {
                [self removeConnection:CGPointMake(from.x, from.y)];
                [self removeConnection:CGPointMake(to.x, to.y)];
                [self createMovingPlatformConnection:from To:to];
                return YES;
            }
        }
    }
    
    // A new connection: check if the connection can be made, and if so create it and add to |_connections|. 
    if([Connections isAStarConnection:from To:to]) {
        [self createStarConnection:from To:to];
        return YES;
    } else if([Connections isABridgeConnection:from To:to]) {
        [self createBridgeConnection:from To:to];
        return YES;
    } else if([Connections isAMovingPlatformConnection:from To:to]) {
        [self createMovingPlatformConnection:from To:to];
        return YES;
    }
    
    return NO;
}

/*
 *  Removes a connection based on a point. Either start or end point, both work. */
-(BOOL)removeConnection:(CGPoint)pos {
    for(int i = 0; i < _connections.count; i++) {
        Element *from = [[_connections objectAtIndex:i] objectAtIndex:0];
        Element *to = [[_connections objectAtIndex:i] objectAtIndex:1];
        
        if((pos.x == from.x && pos.y == from.y) || (pos.x == to.x && pos.y == to.y)) {
            if([Connections isAStarConnection:from To:to]) {
                StarButton *sb = (StarButton*)from;
                sb.star = nil;
                [_connections removeObjectAtIndex:i];
                return YES;
            } else if([Connections isABridgeConnection:from To:to]) {
                BridgeButton *bb = (BridgeButton*)from;
                bb.bridge = nil;
                [_connections removeObjectAtIndex:i];
                return YES;
            } else if([Connections isAMovingPlatformConnection:from To:to]) {
                PlatformLever *pl = (PlatformLever*)from;
                pl.movingPlatform = nil;
                [_connections removeObjectAtIndex:i];
            }
        }
    }
    return NO;
}

/*
 *  Checks if two elements can be connected. */
+(BOOL)isValidConnection:(Element *)from To:(Element *)to {
    return ([from isKindOfClass:[StarButton class]] && [to isKindOfClass:[Star class]]) ||
    (([from isKindOfClass:[BridgeButton class]] && [to isKindOfClass:[Bridge class]]) ||
     ([from isKindOfClass:[PlatformLever class]] && [to isKindOfClass:[MovingPlatform class]]));
}

+(BOOL)isAStarConnection: (Element*)from To: (Element*)to {
    return ([from isKindOfClass: [StarButton class]] && [to isKindOfClass: [Star class]]);
}

+(BOOL)isABridgeConnection:(Element *)from To:(Element *)to {
    return ([from isKindOfClass: [BridgeButton class]] && [to isKindOfClass:[Bridge class]]);
}

+(BOOL)isAMovingPlatformConnection:(Element *)from To:(Element *)to {
    return ([from isKindOfClass: [PlatformLever class]] && [to isKindOfClass:[MovingPlatform class]]);
}

-(void)createStarConnection:(Element *)from To: (Element*)to {
    StarButton *sb = (StarButton*)from;
    Star *star = (Star*)to;
    sb.star = star;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr insertObject:from atIndex:0];
    [arr insertObject:to atIndex:1];
    [_connections insertObject:arr atIndex:_connections.count];
}

-(void)createBridgeConnection:(Element *)from To: (Element*)to {
    BridgeButton *bb = (BridgeButton*)from;
    Bridge *bridge = (Bridge*)to;
    bb.bridge = bridge;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr insertObject:from atIndex:0];
    [arr insertObject:to atIndex:1];
    [_connections insertObject:arr atIndex:_connections.count];
}

-(void)createMovingPlatformConnection:(Element *)from To:(Element *)to {
    PlatformLever *pl = (PlatformLever*)from;
    MovingPlatform *mp = (MovingPlatform*)to;
    pl.movingPlatform = mp;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr insertObject:from atIndex:0];
    [arr insertObject:to atIndex:1];
    [_connections insertObject:arr atIndex:_connections.count];
}

-(void)removeAllConnections {
    [_connections removeAllObjects];
}
@end
