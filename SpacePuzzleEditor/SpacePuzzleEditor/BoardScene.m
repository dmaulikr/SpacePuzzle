//
//  GViewMyScene.m
//  SpacePuzzleEditor
//

#import "BoardScene.h"

@implementation BoardScene
@synthesize solid = _solid;
@synthesize voidTile = _voidTile;
@synthesize crackedTile = _crackedTile;
@synthesize boardSprites = _boardSprites;
@synthesize bkg = _bkg;
@synthesize startElement = _startElement;
@synthesize startElSprite = _startElSprite;
@synthesize finishElement = _finishElement;
@synthesize finishSprite = _finishSprite;
@synthesize rockTexture = _rockTexture;
@synthesize elementSprites = _elementSprites;
@synthesize starTexture = _starTexture;
@synthesize buttonTexture = _buttonTexture;
@synthesize controlHover = _controlHover;
@synthesize connectionNodes = _connectionNodes;
@synthesize bridgeTexture = _bridgeTexture;
@synthesize leverTexture = _leverTexture;
@synthesize platformTexture = _platformTexture;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        _elementSprites = [[NSMutableDictionary alloc] init];
        _connectionNodes = [[NSMutableDictionary alloc] init];
        pathNodes = [[NSMutableArray alloc] init];
        rainbowSprites = [[NSMutableArray alloc] init];
        
        pathDrag = NO;
        controlClickDrag = NO;
        controlDragLine = [SKShapeNode node];
        //controlDragLine.glowWidth = 1;
        controlDragLine.lineWidth = 1;
        [controlDragLine setStrokeColor:[SKColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:255.0/255.0 alpha:1]];
        //[controlDragLine setStrokeColor:[SKColor colorWithRed:244.0/255.0 green:185.0/255.0 blue:43.0/255.0 alpha:1]]; // Orange colour.
        controlDragOutline = [SKShapeNode node];
        controlDragOutline.lineWidth = 2;
        
        pathHover = [SKSpriteNode spriteNodeWithImageNamed:@"OrangeTile.png"];
        pathHover.size = CGSizeMake(42,42);
        pathHover.hidden = YES;
        pathHover.zPosition = 999996;
        pathHover.color = [SKColor colorWithRed:100.0/255.0 green:190.0/255.0 blue:100.0/255.0 alpha:1];
        pathHover.colorBlendFactor = 1;
        
        _controlHover = [SKSpriteNode spriteNodeWithImageNamed:@"OrangeTile.png"];
        _controlHover.size = CGSizeMake(42, 42);
        _controlHover.hidden = YES;
        _controlHover.zPosition = 999996;
        
        circle = [SKShapeNode node];
        circleOutline = [SKShapeNode node];
        [circleOutline setStrokeColor:[NSColor whiteColor]];
        circle.strokeColor = controlDragLine.strokeColor;
        circleOutline.glowWidth = 0;
        
        self.backgroundColor = [SKColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
        self.size = CGSizeMake(size.width, size.height);
        _solid = [SKTexture textureWithImageNamed:@"solidtile.png"];
        _voidTile = [SKTexture textureWithImageNamed:@"voidtile.png"];
        _crackedTile = [SKTexture textureWithImageNamed:@"Cracked.png"];
        _bkg = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
        _startElement = [SKTexture textureWithImageNamed:@"Start.gif"];
        _finishElement = [SKTexture textureWithImageNamed:@"Finish.png"];
        _rockTexture = [SKTexture textureWithImageNamed:@"Box.png"];
        _starTexture = [SKTexture textureWithImageNamed:@"Star.png"];
        _buttonTexture = [SKTexture textureWithImageNamed:@"Button.png"];
        _bridgeTexture = [SKTexture textureWithImageNamed:@"BridgeON.png"];
        _platformTexture = [SKTexture textureWithImageNamed:@"MovingPlatform.png"];
        _leverTexture = [SKTexture textureWithImageNamed:@"SwitchOFF.png"];
        rainbowLeftTurn = [SKTexture textureWithImageNamed:@"RainbLTurn.png"];
        rainbowRightTurn = [SKTexture textureWithImageNamed:@"RainbRTurn.png"];
        rainbowStraight = [SKTexture textureWithImageNamed:@"RainbHoriz.png"];
        
        _startElSprite = [SKSpriteNode spriteNodeWithTexture:_startElement];
        _startElSprite.position = CGPointMake(-100, -100);
        _startElSprite.size = CGSizeMake(TILESIZE/2, TILESIZE/2);
        _startElSprite.zPosition = 10;
        [self addChild:_startElSprite];
        
        _finishSprite = [SKSpriteNode spriteNodeWithTexture:_finishElement];
        _finishSprite.position = CGPointMake(-100, -100);
        _finishSprite.size = CGSizeMake(TILESIZE/2, TILESIZE/2);
        _finishSprite.zPosition = 10;
        [self addChild:_finishSprite];
        
        _bkg.size = CGSizeMake(size.width, size.height);
        _bkg.position = CGPointMake(WIN_SIZE_X/2, WIN_SIZE_Y/2);
        [self addChild:_bkg];
        
        _boardSprites = [[NSMutableArray alloc] init];
        statusOfPalette = MAPSTATUS_SOLID;
        currentTexture = _solid;
        
        [self observeText:@"SolidClick" Selector:@selector(solidClick)];
        [self observeText:@"VoidClick" Selector:@selector(voidClick)];
        [self observeText:@"CrackedClick" Selector:@selector(crackedClick)];
        [self observeText:@"StartClick" Selector:@selector(startClick)];
        [self observeText:@"FinishClick" Selector:@selector(finishClick)];
        [self observeText:@"RockClick" Selector:@selector(rockClick)];
        [self observeText:@"StarClick" Selector:@selector(starClick)];
        [self observeText:@"EraserClick" Selector:@selector(eraserClick)];
        [self observeText:@"StarButtonClick" Selector:@selector(starButtonClick)];
        [self observeText:@"HighlightElement" Selector:@selector(highlightElement:)];
        [self observeText:@"BridgeButtonClick" Selector:@selector(bridgeButtonClick)];
        [self observeText:@"BridgeClick" Selector:@selector(bridgeClick)];
        [self observeText:@"LeverClick" Selector:@selector(leverClick)];
        [self observeText:@"PlatformClick" Selector:@selector(platformClick)];
        
        controlDragLine.zPosition = 999999;
        circle.zPosition = 999998;
        circleOutline.zPosition = 999997;
        controlDragOutline.zPosition = 999997;
        [self addChild:controlDragLine];
        [self addChild:circle];
        [self addChild:circleOutline];
        [self addChild:_controlHover];
        [self addChild:pathHover];
        //  [self addChild:controlDragOutline];
    }
    return self;
}

/*
 *  Highlights an element. Used when control dragging to show if a connection can be made. */
-(void)highlightElement:(CGPoint) elementIndex {
    _controlHover.hidden = NO;
   
    elementIndex = [Converter convertCoordToPixel:elementIndex];
    elementIndex.x += 22;
    _controlHover.position = elementIndex;
}

-(void)noHighlight {
    _controlHover.hidden = YES;
}

-(void)mouseDown:(NSEvent *)theEvent {
    if((theEvent.modifierFlags & NSAlternateKeyMask) && (theEvent.modifierFlags & NSControlKeyMask)) {
        pathDrag = YES;
        SKView *sk = self.view;
        NSPoint loc = [sk convertPoint:[theEvent locationInWindow] fromView:nil];
        startPathLine = CGPointMake(loc.x, loc.y);
        loc = [Converter convertMousePosToCoord:loc];
        // INTE GÖRA DETTA I SCENE!?
    } else if (theEvent.modifierFlags & NSControlKeyMask) {
        controlClickDrag = YES;
        
        SKView *sk = self.view;
        NSPoint loc = [sk convertPoint:[theEvent locationInWindow] fromView:nil];
        startControlDrag = CGPointMake(loc.x, loc.y);
        loc = [Converter convertMousePosToCoord:loc];
    } else if (!controlClickDrag || !pathDrag) {
        [self editABoardItem:theEvent];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent {
    SKView *sk = self.view;
    NSPoint loc = [sk convertPoint:[theEvent locationInWindow] fromView:nil];
    if (controlClickDrag) {
        controlDragLine.hidden = NO;
        circle.hidden = NO;
        circleOutline.hidden = NO;
        controlDragOutline.hidden = NO;
        endControlDrag = CGPointMake(loc.x, loc.y);
        [self drawControlLine];
        CGPoint start = [Converter convertMousePosToCoord:startControlDrag];
        CGPoint end = [Converter convertMousePosToCoord:endControlDrag];
        NSArray *arr = [NSArray arrayWithObjects:[NSValue valueWithPoint:start],
                        [NSNumber valueWithPoint:end], nil];
        [self notifyText:@"ControlDrag" Object:arr Key:@"ControlDrag"];
    } else if(pathDrag) {
        CGPoint end = CGPointMake(loc.x, loc.y);
        end = [Converter convertMousePosToCoord:end];

        CGPoint start = [Converter convertMousePosToCoord:startPathLine];
        NSArray *arr = [NSArray arrayWithObjects:[NSValue valueWithPoint:start],
                        [NSNumber valueWithPoint:end], nil];
        [self notifyText:@"PathDrag" Object:arr Key:@"PathDrag"];
  //      [self drawPathLine];
        
    } else {
        circle.hidden = YES;
        circleOutline.hidden = YES;
        controlDragLine.hidden = YES;
        controlDragOutline.hidden = YES;
        controlClickDrag = NO;
        [self editABoardItem:theEvent];
    }
}

-(void)mouseUp:(NSEvent *)theEvent {
    if(controlClickDrag) {
        controlDragLine.hidden = YES;
        circleOutline.hidden = YES;
        circle.hidden = YES;
        controlDragOutline.hidden = YES;
        controlClickDrag = NO;
        
        startControlDrag = [Converter convertMousePosToCoord:startControlDrag];
        endControlDrag = [Converter convertMousePosToCoord:endControlDrag];
        

        NSArray *arr = [NSArray arrayWithObjects:[NSValue valueWithPoint:startControlDrag],
                        [NSNumber valueWithPoint:endControlDrag], nil];
        [self notifyText:@"ControlDragUp" Object:arr Key:@"ControlDragUp"];
        [self noHighlight];
    } else if(pathDrag) {
        pathDrag = NO;
        pathHover.hidden = YES;
    }
}

/*
 *  Draws a path using rainbow textures and lines. */
-(void)drawPathLineFrom:(CGPoint)from To:(CGPoint)to InDirection:(NSInteger)dir
      WithLastDirection:(NSInteger)lastDir {
    SKShapeNode *pathLine = [SKShapeNode node];

    pathLine.lineWidth = 1;
    [pathLine setStrokeColor:[SKColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:0.6]];
    pathLine.hidden = NO;
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    from = [Converter convertCoordToPixel:from];
    to = [Converter convertCoordToPixel:to];
    from.x += TILESIZE/2;
    to.x += TILESIZE/2;
    CGFloat alpha = 0.2;
    
    // Removes overlapping lines in different directions.
    if(dir == RIGHT) {
        // A simple line following the path
        CGPathMoveToPoint(pathToDraw, NULL, from.x, from.y);
        CGPathAddLineToPoint(pathToDraw, NULL, to.x-1, to.y);
        // The rainbow showing the path. The texture and rotation depends of previous direction.
        
        if(lastDirChange == RAINBOW_FROM_DOWN_TO_RIGHT) {
            NSLog(@"down right");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = 0.25;
            rainbow.position = to;
//            rainbow.zRotation = PI;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else if(lastDirChange == RAINBOW_FROM_UP_TO_RIGHT) {
            NSLog(@"up right");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else {
            NSLog(@"just right");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = 0.25;
            rainbow.position = to;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        }
    } else if (dir == LEFT) {
        CGPathMoveToPoint(pathToDraw, NULL, from.x, from.y);
        CGPathAddLineToPoint(pathToDraw, NULL, to.x+1, to.y);
        if(lastDirChange == RAINBOW_FROM_DOWN_TO_LEFT) {
            NSLog(@"down left");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            rainbow.zRotation = PI;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else if(lastDirChange == RAINBOW_FROM_UP_TO_LEFT) {
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            rainbow.zRotation = PI;
            NSLog(@"up left");
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else {
            NSLog(@"just left");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        }
    } else if (dir == DOWN) {
        CGPathMoveToPoint(pathToDraw, NULL, from.x, from.y);
        CGPathAddLineToPoint(pathToDraw, NULL, to.x, to.y+1);
        if(lastDirChange == RAINBOW_FROM_LEFT_TO_DOWN) {
            NSLog(@"left down");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            rainbow.zRotation = -PI/2;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else if(lastDirChange == RAINBOW_FROM_RIGHT_TO_DOWN) {
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            rainbow.zRotation = -PI/2;
            NSLog(@"right down");
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else {
            NSLog(@"just down");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = alpha;
            rainbow.position = to;
            rainbow.zRotation = PI/2;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        }
    } else if (dir == UP) {
        CGPathMoveToPoint(pathToDraw, NULL, from.x, from.y);
        CGPathAddLineToPoint(pathToDraw, NULL, to.x, to.y-1);
        
        if(lastDirChange == RAINBOW_FROM_LEFT_TO_UP) {
            NSLog(@"left up");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = 0.25;
            rainbow.zRotation = PI/2;
            rainbow.position = to;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else if(lastDirChange == RAINBOW_FROM_RIGHT_TO_UP) {
            NSLog(@"right up");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = 0.25;
            rainbow.zRotation = PI/2;
            rainbow.position = to;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        } else {
            NSLog(@"just up");
            SKSpriteNode *rainbow = [SKSpriteNode spriteNodeWithTexture:rainbowStraight];
            rainbow.size = CGSizeMake(TILESIZE, TILESIZE);
            rainbow.alpha = 0.25;
            rainbow.position = to;
            rainbow.zRotation = PI/2;
            [rainbowSprites addObject:rainbow];
            [self addChild:rainbow];
        }
    }
    pathLine.path = pathToDraw;
    pathLine.zPosition = 9999999;
    [pathNodes addObject:pathLine];
    [self addChild:pathLine];
}

/*
 *  Checks if a point is an end point of a connection. */
-(BOOL)isPointAConnectionEndPoint:(CGPoint)loc {
    for(id key in _connectionNodes) {
        SKShapeNode* s = [_connectionNodes objectForKey:key];
        CGPoint p = [Converter convertMousePosToCoord: s.position];
        
        if(loc.x == p.x && loc.y == p.y) {
            return YES;
        }
    }
    return NO;
}

/*
 *  Removes all connections from the scene. */
-(void)removeAllConnections {
    for(id key in _connectionNodes) {
        SKShapeNode* s = [_connectionNodes objectForKey:key];
        [s removeFromParent];
    }
    [_connectionNodes removeAllObjects];
}

-(void)removeAllPaths {
    for(int i = 0; i < pathNodes.count; i++) {
        SKShapeNode* s = [pathNodes objectAtIndex:i];
        [s removeFromParent];
    }
    [pathNodes removeAllObjects];
    
    for(int i = 0; i < rainbowSprites.count; i++) {
        SKSpriteNode* s = [rainbowSprites objectAtIndex:i];
        [s removeFromParent];
    }
    [rainbowSprites removeAllObjects];
}

-(void)addAPath:(NSMutableArray *)path {
    for(int i = 0; i < path.count-1; i++) {
        NSValue *from = [path objectAtIndex:i];
        NSValue *to = [path objectAtIndex:i+1];
        CGPoint f = CGPointMake(from.pointValue.x, from.pointValue.y);
        CGPoint t = CGPointMake(to.pointValue.x, to.pointValue.y);
        NSInteger dir = [Converter convertCoordsTo:t Direction:f];
        
        if(i > 0) {
            // ADD: OM REGNBÅGE REDAN FINNS PÅ POS, RITA EJ!!
            NSValue *prevFrom = [path objectAtIndex:i-1];
            NSValue *prevTo = [path objectAtIndex:i];
            CGPoint pf = CGPointMake(prevFrom.pointValue.x, prevFrom.pointValue.y);
            CGPoint pt = CGPointMake(prevTo.pointValue.x, prevTo.pointValue.y);
            NSInteger prevDir = [Converter convertCoordsTo:pt Direction:pf];
            if(prevDir == DOWN && dir == RIGHT) {
                lastDirChange = RAINBOW_FROM_DOWN_TO_RIGHT;
            } else if(prevDir == UP && dir == RIGHT) {
                lastDirChange = RAINBOW_FROM_UP_TO_RIGHT;
            } else if(prevDir == DOWN && dir == LEFT) {
                lastDirChange = RAINBOW_FROM_DOWN_TO_LEFT;
            } else if(prevDir == UP && dir == LEFT) {
                lastDirChange = RAINBOW_FROM_UP_TO_LEFT;
            } else if(prevDir == LEFT && dir == DOWN) {
                lastDirChange = RAINBOW_FROM_LEFT_TO_DOWN;
            } else if(prevDir == LEFT && dir == UP) {
                lastDirChange = RAINBOW_FROM_LEFT_TO_UP;
            } else if(prevDir == RIGHT && dir == UP) {
                lastDirChange = RAINBOW_FROM_RIGHT_TO_UP;
            } else if(prevDir == RIGHT && dir == DOWN) {
                lastDirChange = RAINBOW_FROM_RIGHT_TO_DOWN;
            }
        } else {
            lastDirChange = dir;
        }
        
        [self drawPathLineFrom: f To:t InDirection:dir WithLastDirection:lastDirChange];
    }
}

-(void)pathHighlight:(CGPoint)pos {
    pos = [Converter convertCoordToPixel:pos];
    pos.x += TILESIZE/2;
    pathHover.hidden = NO;
    pathHover.position = pos;
}

-(void)drawControlLine {
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, startControlDrag.x, startControlDrag.y);
    CGPathAddLineToPoint(pathToDraw, NULL, endControlDrag.x, endControlDrag.y);
    controlDragLine.path = pathToDraw;
    
    CGMutablePathRef pathToDraw2 = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw2, NULL, startControlDrag.x, startControlDrag.y);
    CGPathAddLineToPoint(pathToDraw2, NULL, endControlDrag.x, endControlDrag.y);
    controlDragOutline.path = pathToDraw2;
    
    circle.position = controlDragLine.position;
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, startControlDrag.x, startControlDrag.y, 2, 0, M_PI*2, NO);
    circle.path = circlePath;
    
    circleOutline.position = controlDragLine.position;
    CGMutablePathRef circlePath2 = CGPathCreateMutable();
    CGPathAddArc(circlePath2, NULL, startControlDrag.x, startControlDrag.y, 3, 0, M_PI*2, NO);
    circleOutline.path = circlePath2;
}

/*
 *  Could be used to change brush? */
-(void)keyDown:(NSEvent *)theEvent {
    //if(theEvent.modifierFlags & NSControl)
}

/*
 *  Changes one tile/element on the board according to what brush is used and notifies observers that the
 *  view has changed. */
-(void)editABoardItem:(NSEvent *)theEvent {
    // Find mouse location and convert.
    SKView *sk = self.view;
    NSPoint mouseLoc = [sk convertPoint:[theEvent locationInWindow] fromView:nil];
    CGPoint loc = CGPointMake(mouseLoc.x*WIN_SIZE_X/(sk.frame.size.width), mouseLoc.y*WIN_SIZE_Y/(sk.frame.size.height));
    
    loc = [Converter convertMousePosToCoord:loc];
    NSArray *arr = [NSArray arrayWithObjects:[NSValue valueWithPoint:loc],
                    [NSNumber numberWithInteger: statusOfPalette],nil];
    NSNumber *flatIndex = [NSNumber numberWithInt:loc.y*BOARD_SIZE_X + loc.x];
    // Check if the click was inside the board.
    if(loc.x >= 0 && loc.x < BOARD_SIZE_X && loc.y >= 0 && loc.y < BOARD_SIZE_Y) {
        // Change texture of sprite if tiles.
        if(statusOfPalette == MAPSTATUS_SOLID || statusOfPalette == MAPSTATUS_CRACKED || statusOfPalette == MAPSTATUS_VOID) {
            SKSpriteNode *s = [_boardSprites objectAtIndex:loc.y * BOARD_SIZE_X + loc.x];
            s.texture = currentTexture;
            
            [self notifyText:@"BoardEdited" Object:arr Key:@"BoardEdited"];
        }
        // Elements.
        else {
            if(statusOfPalette == BRUSH_START) {
                // Change position of Start sprite.
                loc = [Converter convertCoordToPixel:loc];
                loc.x += TILESIZE/2;
                _startElSprite.position = CGPointMake(loc.x, loc.y);
                [self notifyText:@"BoardEdited" Object:arr Key:@"BoardEdited"];
            } else if(statusOfPalette == BRUSH_FINISH) {
                loc = [Converter convertCoordToPixel:loc];
                loc.x +=TILESIZE/2;
                _finishSprite.position = CGPointMake(loc.x, loc.y);
                [self notifyText:@"BoardEdited" Object:arr Key:@"BoardEdited"];
            } else if(statusOfPalette == BRUSH_ERASER) {
                if([_elementSprites objectForKey:flatIndex]) {
                    [self notifyText:@"BoardEdited" Object:arr Key:@"BoardEdited"];
                }
            }
            // Elements that are part of the element dictionary.
            else if (![_elementSprites objectForKey:flatIndex]) {
                [self notifyText:@"BoardEdited" Object:arr Key:@"BoardEdited"];
                [self addElement:statusOfPalette Position:loc];
            }
        }
    }
}

-(void)setAConnectionFrom:(CGPoint)from To:(CGPoint)to {
    SKShapeNode *s = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    from = [Converter convertCoordToPixel:from];
    to = [Converter convertCoordToPixel:to];
    to.x += 20;
    from.x += 20;
    s.lineWidth = 0.4;
    s.zPosition = 999999999;
    
    // Sets the position of the node to the end point. This is used later to check if end points of
    // attempted connections are free. 
    s.position = to;
    float relPX = from.x - s.position.x;
    float relPY = from.y - s.position.y;
    
    [s setStrokeColor:[SKColor colorWithRed:244.0/255.0 green:185.0/255.0 blue:43.0/255.0 alpha:0.25]];
    CGPathMoveToPoint(pathToDraw, NULL, 0, 0);
    CGPathAddLineToPoint(pathToDraw, NULL, relPX, relPY);
    
    // Add a connecting circle to end points.
    CGPathAddArc(pathToDraw, NULL, relPX, relPY, 2, 0, M_PI*2, NO);
    CGPathAddArc(pathToDraw, NULL, relPX, relPY, 1, 0, M_PI*2, NO);
    CGPathAddArc(pathToDraw, NULL, relPX, relPY, 0.5, 0, M_PI*2, NO);
    
    CGPathAddArc(pathToDraw, NULL, 0, 0, 2, 0, M_PI*2, NO);
    CGPathAddArc(pathToDraw, NULL, 0, 0, 1, 0, M_PI*2, NO);
    CGPathAddArc(pathToDraw, NULL, 0, 0, 0.5, 0, M_PI*2, NO);
    
    s.path = pathToDraw;
   
    [self addChild:s];
    
    from = [Converter convertMousePosToCoord:from];
    to = [Converter convertMousePosToCoord:to];
    NSNumber *indexFrom = [NSNumber numberWithInteger:from.y * BOARD_SIZE_X + from.x];
    [_connectionNodes setObject:s forKey:indexFrom];
   // [_connectionNodes setObject:s forKey:indexTo];
}

-(BOOL)removeAConnectionFrom:(CGPoint)from {
    NSNumber *index = [NSNumber numberWithInteger:from.y * BOARD_SIZE_X + from.x];
    SKShapeNode *s = [_connectionNodes objectForKey:index];
    // If the connection doesn't exist, nothing removed.
    if(!s) {
        return NO;
    }
    [s removeFromParent];
    [_connectionNodes removeObjectForKey:index];
    return YES;
}

-(BOOL)removeAConnectionBasedOnEndPoint:(CGPoint)loc {
    for(id key in _connectionNodes) {
        SKShapeNode* s = [_connectionNodes objectForKey:key];
        CGPoint p = [Converter convertMousePosToCoord: s.position];
        
        if(loc.x == p.x && loc.y == p.y) {
            [_connectionNodes removeObjectForKey:key];
            [s removeFromParent];
            return YES;
        }
    }
    return NO;
}

-(BOOL)removeAConnectionFrom:(CGPoint)from To: (CGPoint)to {
    NSNumber *index = [NSNumber numberWithInteger:from.y * BOARD_SIZE_X + from.x];
    NSNumber *indexTo = [NSNumber numberWithInteger:to.y * BOARD_SIZE_X + to.x];
    SKShapeNode *s = [_connectionNodes objectForKey:index];
  
    // If the connection doesn't exist, nothing removed.
    if(!s) {
        return NO;
    }
    [s removeFromParent];
    [_connectionNodes removeObjectForKey:index];
    [_connectionNodes removeObjectForKey:indexTo];
    return YES;
}

-(void)removeOneSprite:(NSNumber *)index {
    SKSpriteNode* s = [_elementSprites objectForKey:index];
    [s removeFromParent];
    [_elementSprites removeObjectForKey:index];
}

/*
 *  Runs when something is clicked on the palette. */
-(void)startClick {
    [self changeTextureOfBrush:BRUSH_START];
}

-(void)finishClick {
    [self changeTextureOfBrush:BRUSH_FINISH];
}

-(void)solidClick {
    [self changeTextureOfBrush:MAPSTATUS_SOLID];
}

-(void)crackedClick {
    [self changeTextureOfBrush:MAPSTATUS_CRACKED];
}

-(void)voidClick {
    [self changeTextureOfBrush:MAPSTATUS_VOID];
}

-(void)rockClick {
    [self changeTextureOfBrush:BRUSH_ROCK];
}

-(void)starClick {
    [self changeTextureOfBrush:BRUSH_STAR];
}

-(void)eraserClick {
    [self changeTextureOfBrush:BRUSH_ERASER];
}

-(void)starButtonClick {
    [self changeTextureOfBrush:BRUSH_STARBUTTON];
}

-(void)bridgeButtonClick {
    [self changeTextureOfBrush:BRUSH_BRIDGEBUTTON];
}

-(void)bridgeClick {
    [self changeTextureOfBrush:BRUSH_BRIDGE];
}

-(void)platformClick {
    [self changeTextureOfBrush:BRUSH_MOVING_PLATFORM];
}

-(void)leverClick {
    [self changeTextureOfBrush:BRUSH_LEVER];
}

/*
 *  Changes the texture of the brush, i.e. what the brush will "paint". */
-(void)changeTextureOfBrush:(NSInteger)status {
    statusOfPalette = status;
    
    switch (status) {
        case MAPSTATUS_SOLID:
            currentTexture = _solid;
            break;
        case MAPSTATUS_VOID:
            currentTexture = _voidTile;
            break;
        case MAPSTATUS_CRACKED:
            currentTexture = _crackedTile;
            break;
        case BRUSH_START:
            currentTexture = _startElement;
            break;
        case BRUSH_FINISH:
            currentTexture = _finishElement;
            break;
        case BRUSH_ROCK:
            currentTexture = _rockTexture;
            break;
        case BRUSH_STAR:
            currentTexture = _starTexture;
            break;
        case BRUSH_STARBUTTON:
            currentTexture = _buttonTexture;
            break;
        case BRUSH_BRIDGE:
            currentTexture = _bridgeTexture;
            break;
        case BRUSH_BRIDGEBUTTON:
            currentTexture = _buttonTexture;
            break;
        case BRUSH_LEVER:
            currentTexture = _leverTexture;
            break;
        case BRUSH_MOVING_PLATFORM:
            currentTexture = _platformTexture;
            break;
        case BRUSH_ERASER:
            currentTexture = nil;
            break;
        default:
            break;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)setupBoardX:(NSInteger)x Y:(NSInteger)y TileSize:(NSInteger)ts Status:(NSInteger)status {
    SKSpriteNode *sprite = [[SKSpriteNode alloc] init];
    
    [self setTextureOfSprite:sprite AccordingToStatus:status];
    
    sprite.size = CGSizeMake(ts, ts);
    CGPoint p = CGPointMake(x, y);
    p = [Converter convertCoordToPixel:p];
    p.x += TILESIZE/2;
    
    // NSInteger xx = x*ts + p.x + ts/2;
    // NSInteger yy = [Converter convertCoordToPixel:p];//WIN_SIZE_Y - 22 - y*ts;
    
    sprite.position = p;
    [_boardSprites addObject:sprite];
    [self addChild:sprite];
}

-(void)refreshBoardX:(NSInteger)x Y:(NSInteger)y Status: (NSInteger)status {
    SKSpriteNode *sprite = [_boardSprites objectAtIndex:y*BOARD_SIZE_X + x];
    [self setTextureOfSprite:sprite AccordingToStatus:status];
}

-(void)refreshElementsStart:(CGPoint)start Finish:(CGPoint)finish {
    start = [Converter convertCoordToPixel:start];
    finish = [Converter convertCoordToPixel:finish];
    start.x += TILESIZE/2;
    finish.x += TILESIZE/2;
    
    _startElSprite.position = start;
    _finishSprite.position = finish;
}

/*
 *  Adds an element to the scene, according to class name and position sent as arguments. */
-(void)addElement:(NSInteger)brush Position:(CGPoint)pos {
    NSNumber *flatIndex = [NSNumber numberWithInt:pos.y*BOARD_SIZE_X + pos.x];
    
    switch (brush) {
        case BRUSH_ROCK:
            [self addARock:pos Index:flatIndex];
            break;
        case BRUSH_STAR:
            [self addAStar:pos Index:flatIndex];
            break;
        case BRUSH_STARBUTTON:
            [self addAStarButton:pos Index:flatIndex];
            break;
        case BRUSH_BRIDGE:
            [self addABridge:pos Index:flatIndex];
            break;
        case BRUSH_BRIDGEBUTTON:
            [self addABridgeButton:pos Index:flatIndex];
            break;
        case BRUSH_LEVER:
            [self addALever:pos Index:flatIndex];
            break;
        case BRUSH_MOVING_PLATFORM:
            [self addAPlatform:pos Index:flatIndex];
            break;
        default:
            break;
    }
}

/*
 *  Adds a star at a given coordinate. */
-(void)addAStar:(CGPoint)pos Index:(NSNumber*)index{
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithTexture:_starTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    star.position = pxl;
    star.size = CGSizeMake(TILESIZE-20, TILESIZE-20);
    
    [_elementSprites setObject:star forKey:index];
    [self addChild:star];
}

-(void)addARock:(CGPoint)pos Index:(NSNumber *)index {
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithTexture:_rockTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    rock.position = pxl;
    rock.size = CGSizeMake(TILESIZE-4, TILESIZE-4);
    
    [_elementSprites setObject:rock forKey:index];
    [self addChild:rock];
}

-(void)addABridge:(CGPoint)pos Index:(NSNumber *)index {
    SKSpriteNode *bridge = [SKSpriteNode spriteNodeWithTexture:_bridgeTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    bridge.position = pxl;
    bridge.size = CGSizeMake(TILESIZE-4, TILESIZE-4);
    
    [_elementSprites setObject:bridge forKey:index];
    [self addChild:bridge];
}

-(void)addAStarButton:(CGPoint)pos Index:(NSNumber *)index {
    SKSpriteNode *starbtn = [SKSpriteNode spriteNodeWithTexture:_buttonTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    starbtn.position = pxl;
    starbtn.size = CGSizeMake(TILESIZE-4, TILESIZE-4);
    starbtn.color = [SKColor yellowColor];
    starbtn.colorBlendFactor = 0.3;
    
    [_elementSprites setObject:starbtn forKey:index];
    [self addChild:starbtn];
}

-(void)addABridgeButton:(CGPoint)pos Index:(NSNumber *)index {
    SKSpriteNode *bridgebtn = [SKSpriteNode spriteNodeWithTexture:_buttonTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    bridgebtn.position = pxl;
    bridgebtn.size = CGSizeMake(TILESIZE-4, TILESIZE-4);
    bridgebtn.color = [SKColor blueColor];
    bridgebtn.colorBlendFactor = 0.25;
    
    [_elementSprites setObject:bridgebtn forKey:index];
    [self addChild:bridgebtn];
}

-(void)addAPlatform:(CGPoint)pos Index:(NSNumber *)index {
    SKSpriteNode *platform = [SKSpriteNode spriteNodeWithTexture:_platformTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    platform.position = pxl;
    platform.size = CGSizeMake(TILESIZE-1, TILESIZE-1);
    
    [_elementSprites setObject:platform forKey:index];
    [self addChild:platform];
}

-(void)addALever:(CGPoint)pos Index:(NSNumber *)index {
    SKSpriteNode *lever = [SKSpriteNode spriteNodeWithTexture:_leverTexture];
    
    CGPoint pxl = [Converter convertCoordToPixel:pos];
    pxl.x += TILESIZE/2;
    lever.position = pxl;
    lever.size = CGSizeMake(TILESIZE-4, _leverTexture.size.height/2);
    
    [_elementSprites setObject:lever forKey:index];
    [self addChild:lever];
}

-(void)cleanElements {
    for(id key in _elementSprites) {
        SKSpriteNode* s = [_elementSprites objectForKey:key];
        [s removeFromParent];
    }
    [_elementSprites removeAllObjects];
    
    for(id key in _connectionNodes) {
        SKShapeNode* s = [_connectionNodes objectForKey:key];
        [s removeFromParent];
    }
    [_connectionNodes removeAllObjects];
}

-(void)cleanView {
    for(id key in _elementSprites) {
        SKSpriteNode* s = [_elementSprites objectForKey:key];
        
        [s removeFromParent];
    }
    
    [_elementSprites removeAllObjects];
    
    _startElSprite.position = CGPointMake(-100, -100);
    _finishSprite.position = CGPointMake(-100, -100);
}

-(NSInteger)classToBrush:(NSString *)className {
    if ([className isEqualToString:CLASS_BOX]) {
        return BRUSH_ROCK;
    } else if ([className isEqualToString:CLASS_STAR]) {
        return BRUSH_STAR;
    } else if ([className isEqualToString:CLASS_BRIDGE]) {
        return BRUSH_BRIDGE;
    } else if ([className isEqualToString:CLASS_LEVER]) {
        return BRUSH_LEVER;
    } else if ([className isEqualToString:CLASS_MOVING_PLATFORM]) {
        return BRUSH_MOVING_PLATFORM;
    } else if ([className isEqualToString:CLASS_STARBUTTON]) {
        return BRUSH_STARBUTTON;
    } else if ([className isEqualToString:CLASS_BRIDGEBUTTON]) {
        return BRUSH_BRIDGEBUTTON;
    }
    
    return 0;
}

/*
 *  Sets the texture of a sprite according to the status of the board coordinate. */
-(void)setTextureOfSprite:(SKSpriteNode *)sprite AccordingToStatus:(NSInteger)status {
    if(status == MAPSTATUS_SOLID) {
        sprite.texture = _solid;
    } else if(status == MAPSTATUS_VOID) {
        sprite.texture = _voidTile;
    } else if(status == MAPSTATUS_CRACKED) {
        sprite.texture = _crackedTile;
    } else if(status == BRUSH_START) {
        sprite.texture = _startElement;
    }
}

-(void) notifyText:(NSString *)text Object:(NSObject *)object Key:(NSString *)key {
    if(object) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:object forKey:key];
        [[NSNotificationCenter defaultCenter] postNotificationName:text object:nil
                                                          userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:text object:nil];
    }
}

-(void)observeText:(NSString *)text Selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:text object:nil];
}


@end
