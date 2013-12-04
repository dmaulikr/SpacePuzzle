//
//  GViewViewController.m
//  SpacePuzzle

#import "SpacePuzzleController.h"
#import "Element.h"
#import "Converter.h"
#import "Box.h"
#import "Star.h"
#import "Player.h"
#import "StarButton.h"
#import "BridgeButton.h"
#import "PlatformLever.h"
#import "Bridge.h"
#import "Path.h"
#import "Position.h"
#import "LoadSaveFile.h"

@implementation SpacePuzzleController
@synthesize board = _board;
@synthesize scene = _scene;
@synthesize currentUnit = _currentUnit;
@synthesize nextUnit = _nextUnit;
@synthesize bigL = _bigL;
@synthesize littleJohn = _littleJohn;
@synthesize player = _player;
@synthesize world = _world;
@synthesize level = _level;

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [MainScene sceneWithSize:skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    
    [LoadSaveFile saveFileWithWorld:0 andLevel:5];
    _board = [[Board alloc] init];
    [self setupNextLevel];
    
    // Present the scene.
    [skView presentScene:_scene];
    
    // Input recognizers.
    UITapGestureRecognizer *singleTapR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapR.numberOfTapsRequired = 1;
    [_scene.view addGestureRecognizer:singleTapR];
    
    UITapGestureRecognizer *doubleTapR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(doubleTap:)];
    doubleTapR.numberOfTapsRequired = 2;
    [_scene.view addGestureRecognizer:doubleTapR];
    
    UITapGestureRecognizer *trippleTapR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trippleTap:)];
    trippleTapR.numberOfTapsRequired = 3;
    [_scene.view addGestureRecognizer:trippleTapR];

    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [_scene.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [_scene.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_scene.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_scene.view addGestureRecognizer:swipeRight];
}

/*
 *  Called when the user taps once. */
-(void)singleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        CGPoint location = [sender locationInView:_scene.view];
        
        // Convert to board coordinates. Invert with -9.
        location = [Converter convertMousePosToCoord:location];
        //location.y = abs(location.y - 9);

        [self unitWantsToMoveTo:location WithSwipe:NO];
    }
}

/* 
 *  Called when the user double taps the view. */
-(void)doubleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        CGPoint location = [sender locationInView:_scene.view];
        
        // Convert to board coordinates. Invert with -9.
        location = [Converter convertMousePosToCoord:location];
        location.y = abs(location.y - 9);
    
        [self unitWantsToDoActionAt:location];
    }
}

-(void)trippleTap:(UIGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        //[self changeUnit];
    }
}

-(void)swipeUp:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.y -= 1;
        [self unitWantsToMoveTo:location WithSwipe:YES];
    }
}

-(void)swipeDown:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.y += 1;
        [self unitWantsToMoveTo:location WithSwipe:YES];
    }
}

-(void)swipeLeft:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.x -= 1;
        [self unitWantsToMoveTo:location WithSwipe:YES];
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && ![[_scene currentUnit] hasActions]) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.x += 1;
        [self unitWantsToMoveTo:location WithSwipe:YES];
    }
}

-(void)changeUnit {
    if (_currentUnit == _bigL) {
        if([_littleJohn isPlayingOnLevel]) {
            _currentUnit = _littleJohn;
            _nextUnit = _bigL;
            [_scene changeUnit];
            NSLog(@"Change unit");
        }
        NSLog(@"cant change, only L");
    } else if(_currentUnit == _littleJohn) {
        if([_bigL isPlayingOnLevel]) {
            _currentUnit = _bigL;
            _nextUnit = _littleJohn;
            [_scene changeUnit];
        }
    }
}

/*
 *  Loads the board according to the level. ADD LEVELFACTORY!!!. */
-(void)setupBoard {
    // Load the board.
    [self getNextLevel];
    NSString *currentLevel = @"Level";
    currentLevel = [currentLevel stringByAppendingString:[NSString stringWithFormat:@"%d", _world]];
    if(_level < 10) {
        currentLevel = [currentLevel stringByAppendingString:[NSString stringWithFormat:@"%d%d", 0, _level]];
    } else {
        currentLevel = [currentLevel stringByAppendingString:[NSString stringWithFormat:@"%d", _level]];
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:currentLevel ofType:@"splvl"];
    NSLog(@"p %@", currentLevel);
    [_board loadBoard:path];
    
    for(int i = 0; i < BOARD_SIZE_Y; i++) {
        for(int j = 0; j < BOARD_SIZE_X; j++) {
            BoardCoord *bc = [_board.board objectAtIndex:BOARD_SIZE_X*i + j];
            [_scene setupBoardX:[bc x] Y:[bc y] Status:[bc status]];
        }
    }
    CGPoint p = CGPointMake(_board.finishPos.x, _board.finishPos.y);
    p = [Converter convertCoordToPixel:p];
    p.x += TILESIZE/2;
    p.y -= 2;
    [_scene finish].position = p;
}

-(void)setupElements {
    // Talk to the scene what to show.
    NSEnumerator *enumerator = [[_board elementDictionary] objectEnumerator];
    Element *obj;
    
    while(obj = [enumerator nextObject]) {
        CGPoint p = CGPointMake([obj x], [obj y]);
       // if([obj isKindOfClass:[Bridge class]]) {
        //    [_scene setupElement:p Name:@"BridgeOFF.png" Hidden:[obj hidden]];
        //} else if( ![obj isKindOfClass:[StarButton class]] && ![obj isKindOfClass:[BridgeButton class]] ) {
            [_scene setupElement:p Name:NSStringFromClass([obj class]) Hidden:[obj hidden]];
        //} else {
        //    [_scene setupElement:p Name:@"ButtonOFF" Hidden:[obj hidden]];
        //}
    }
}

/*
 *  Called when a unit wants to move to a location on the board. This method checks if the move is 
 *  possible, if so moves the unit. If unit moves to star, consume the star. */
-(void)unitWantsToMoveTo:(CGPoint)loc WithSwipe:(BOOL)swipe {
    // The position that the unit wants to move to.
    NSInteger x  = loc.x;
    NSInteger y = loc.y;
    NSNumber *nextPosKey = [NSNumber numberWithInt:y*BOARD_SIZE_X + x];
    // NSInteger nextPosIntKey = [nextPosKey integerValue];
    // The unit who wants to move's position.
    NSInteger unitX = _currentUnit.x;
    NSInteger unitY = _currentUnit.y;
    NSNumber *unitKey = [NSNumber numberWithInt:unitY*BOARD_SIZE_X + unitX];
    NSInteger unitIntKey = [unitKey integerValue];
    NSNumber *nextPos = [NSNumber numberWithInt:y*BOARD_SIZE_X + x];

    Element *e = [[_board elementDictionary] objectForKey:nextPos];
    Element *eFrom = [[_board elementDictionary] objectForKey:unitKey];
    CGPoint movePoint = CGPointMake(x, y);
    CGPoint unitPoint = CGPointMake(unitX, unitY);
    // First check if the movement was inside the board and if the tile isn't |void| (which units cannot
    // move to).
    if([_board isPointMovableTo:loc] && ![Converter isPoint:movePoint sameAsPoint:unitPoint]) {
        // Checks if the move is 1 step in x or y, but not both at the same time.
        if( [Converter isPoint:unitPoint NextToPoint:movePoint] ) {
            // If |bigL| is standing on a cracked tile and moves away from it. This will destroy the tile,
            // making it void, and also destroying the item on it.
            if ([[[_board board] objectAtIndex:unitIntKey] status] == MAPSTATUS_CRACKED && _currentUnit == _bigL) {
                [[_board elementDictionary] removeObjectForKey:unitKey];
                [_scene removeElementAtPosition:unitKey];
                [[[_board board] objectAtIndex:unitIntKey] setStatus:MAPSTATUS_VOID];
                [_scene refreshTileAtFlatIndex:unitIntKey WithStatus:MAPSTATUS_VOID];
            }

            NSInteger dir = [Converter convertCoordsTo:movePoint Direction:unitPoint];
            // If the element isn't blocking, move unit.
            if(![e blocking]) {
                _currentUnit.x = x;
                _currentUnit.y = y;
                
                [_scene updateUnit:movePoint inDirection:dir];
                if([self isUnitOnGoal]) {
                    _level++;
                    [LoadSaveFile saveFileWithWorld:_world andLevel:_level];
                    [self setupNextLevel];
                }
                
                [self unitWantsToDoActionAt:movePoint];
                CGPoint nextUnitPos = CGPointMake(_nextUnit.x, _nextUnit.y);
                
                // Checks if the element moved from is a |StarButton|, and the second condition checks if
                // the other unit is still on the button, which means the button shouldn't be deactivated.
                if([eFrom isKindOfClass:[StarButton class]] && ![Converter isPoint:nextUnitPos sameAsPoint:unitPoint]) {
                    // Buttons should be deactivated if left.
                    StarButton *sb = (StarButton*)eFrom;
                    [sb unitLeft];
                    [_scene refreshElementAtPosition:sb.key OfClass:CLASS_STARBUTTON WithStatus:sb.state];
                    // Updates the star connected to the button on the scene, i.e. showing it.
                    if(sb.star.taken == NO) {
                        [_scene setElementAtPosition:sb.star.key IsHidden:sb.star.hidden];
                    }
                } else if([eFrom isKindOfClass:[BridgeButton class]] && ![Converter isPoint:nextUnitPos sameAsPoint:unitPoint]) {
                    // Buttons should be deactivated if left.
                    BridgeButton *bb = (BridgeButton*)eFrom;
                    [bb unitLeft];
                    
                    // Updates the button on the scene.
                    [_scene refreshElementAtPosition:bb.bridge.key OfClass:CLASS_BRIDGE WithStatus:bb.state];
                    [_scene refreshElementAtPosition:bb.key OfClass:CLASS_BRIDGEBUTTON WithStatus:bb.state];
                    // Updates the bridge connected to the button on the scene, i.e. showing it.
                    [_scene setElementAtPosition:bb.bridge.key IsHidden:NO];
                }

                // If the element is a star.
                if([e isKindOfClass:[Star class]] && ![e hidden] && ![e taken]) {
                    [e movedTo];
                    _player.starsTaken += 1;
                    //[[_board elementDictionary] removeObjectForKey:nextPosKey];
                    [_scene removeElementAtPosition:nextPosKey];
                } else if([e isKindOfClass:[StarButton class]]) {
                    [self doActionOnStarButton:e];
                } else if([e isKindOfClass:[BridgeButton class]]) {
                    [self doActionOnBridgeButton:e];
                }
                // Check elements that the unit left.

                } else if([e isKindOfClass:[Box class]] && swipe && _currentUnit == _bigL) {
                [self doActionOnBox:e InDirection:dir];
            }
        }
    }
}

/*
 *  Called when a unit (i.e. the user) wants to do an action. First checks if the action is possible,
 *  then chooses an action based on what element the action is performed on. */
-(void)unitWantsToDoActionAt:(CGPoint)loc {
    NSInteger x = loc.x;
    NSInteger y = loc.y;

    NSNumber *actionPointKey = [NSNumber numberWithInt:y*BOARD_SIZE_X + x];
    NSInteger unitX = _currentUnit.x;
    NSInteger unitY = _currentUnit.y;
    
    CGPoint unitPoint = CGPointMake(unitX, unitY);
    CGPoint actionPoint = CGPointMake(x, y);
 
    Element *e = [[_board elementDictionary] objectForKey:actionPointKey];
    // If the element exists.
    if(e) {
        // Do action depending on element type and current unit.
        /*if ([e isKindOfClass:[Box class]] && _currentUnit == _bigL && [Converter isPoint:actionPoint NextToPoint:unitPoint]) {
            NSInteger dir = [Converter convertCoordsTo:actionPoint Direction:unitPoint];
            [self doActionOnBox:e InDirection:dir];
        } else*/
        
        if ([e isKindOfClass:[Box class]] && _currentUnit == _bigL && [Converter isPoint:unitPoint NextToPoint:actionPoint]){
            [self doActionOnBoxSmash:e];
        } else if ([e isKindOfClass:[StarButton class]] && [Converter isPoint:unitPoint sameAsPoint:actionPoint]) {
            //[self doActionOnStarButton:e];
        } else if ([e isKindOfClass:[BridgeButton class]] && [Converter isPoint:unitPoint sameAsPoint:actionPoint]) {
            [self doActionOnBridgeButton:e];
        } else if ([e isKindOfClass:[PlatformLever class]] && [Converter isPoint:unitPoint sameAsPoint:actionPoint]) {
            [self doActionOnPlatformLever:e];
        }
    }
}

-(void)doActionOnBoxSmash:(Element*)box {
    NSNumber *elementKey = [NSNumber numberWithInteger:box.y*BOARD_SIZE_X + box.x];
    [[_board elementDictionary] removeObjectForKey:elementKey];
    [_scene removeElementAtPosition:elementKey];
}

/*
 *  Does an action on a box based on the direction. The action moves the box to a tile. */
-(void)doActionOnBox:(Element *)rock InDirection:(NSInteger)dir{
    NSNumber *nextKey;
    CGPoint nextPos;
    Element *e;
    NSNumber *elementKey = [NSNumber numberWithInteger:rock.y*BOARD_SIZE_X + rock.x];

    if (dir == RIGHT) {
        // Check if at the edge of the board, if so do nothing.
        if(rock.x >= BOARD_SIZE_X-1) {
            return;
        }
        nextKey = [NSNumber numberWithInt:rock.y*BOARD_SIZE_X + rock.x + 1];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x + 1, rock.y);
    } else if (dir == LEFT) {
        if(rock.x <= 0) {
            return;
        }
        nextKey = [NSNumber numberWithInt:rock.y*BOARD_SIZE_X + rock.x - 1];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x - 1, rock.y);
    } else if (dir == UP) {
        if(rock.y <= 0) {
            return;
        }
        nextKey = [NSNumber numberWithInt:(rock.y - 1)*BOARD_SIZE_X + rock.x];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x, rock.y - 1);
    } else if (dir == DOWN){
        if(rock.y >= BOARD_SIZE_Y-1) {
            return;
        }
        nextKey = [NSNumber numberWithInt:(rock.y + 1)*BOARD_SIZE_X + rock.x];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x, rock.y + 1);
    }
    // Add more elements which cannot be pushed upon to if-statement.
    // ![e isKindOfClass:[Box class]] ---> !e isBlocking
    CGPoint nextUnitPos = CGPointMake(_nextUnit.x, _nextUnit.y);
    CGPoint finishPos = CGPointMake([_board finishPos].x, [_board finishPos].y);
    
    if (![e isKindOfClass:[Box class]] && ![Converter isPoint:nextPos sameAsPoint:nextUnitPos] &&
        ![Converter isPoint:finishPos sameAsPoint:nextPos]) {
        NSInteger intKey = [nextKey integerValue];
        NSInteger nextTile = [[[_board board] objectAtIndex:intKey] status];
        NSLog(@"MOVE");
        CGPoint posPreMove = CGPointMake(rock.x, rock.y);
        [rock doMoveAction:dir];

        if(nextTile != MAPSTATUS_SOLID) {
            [[_board elementDictionary] removeObjectForKey:elementKey];
            [_scene removeElementAtPosition:elementKey];
            if(nextTile == MAPSTATUS_CRACKED) {
                [[_board elementDictionary] removeObjectForKey:nextKey];
                [_scene removeElementAtPosition:nextKey];
                [[[_board board] objectAtIndex:intKey] setStatus:MAPSTATUS_VOID];
                [_scene refreshTileAtFlatIndex:intKey WithStatus:MAPSTATUS_VOID];
            }
        } else {
            NSNumber *index = [NSNumber numberWithInteger:nextPos.y * BOARD_SIZE_X + nextPos.x];
            // CHANGE THIS WHEN TWO OR MORE OBJECTS CAN BE PLACED ON THE SAME TILE!
            [[_board elementDictionary] removeObjectForKey:index];
            [_board moveElementFrom:posPreMove To:nextPos];
            [_scene removeElementAtPosition:index];
            [_scene moveElement:posPreMove NewCoord:nextPos];
        }
        //nextTile should invoke its "doAction"...
    }
}

-(void)doActionOnStarButton:(Element *)button {
    StarButton *sb = (StarButton*)button;
    [sb movedTo];
    
    // Updates the button on the scene.
    [_scene refreshElementAtPosition:sb.key OfClass:CLASS_STARBUTTON WithStatus:sb.state];
    // Updates the star connected to the button on the scene, i.e. showing it.
    if(sb.star.taken == NO) {
        [_scene setElementAtPosition:sb.star.key IsHidden:sb.star.hidden];
    }
}

-(void)doActionOnBridgeButton: (Element*)button {
    BridgeButton *bb = (BridgeButton*)button;
    [bb movedTo];
    
    // Updates the button on the scene.
    [_scene refreshElementAtPosition:bb.bridge.key OfClass:CLASS_BRIDGE WithStatus:bb.state];
    [_scene refreshElementAtPosition:bb.key OfClass:CLASS_BRIDGEBUTTON WithStatus:bb.state];
    // Updates the bridge connected to the button on the scene, i.e. showing it.
    [_scene setElementAtPosition:bb.bridge.key IsHidden:NO];
}

// Moving platform should have TIMER in it.
-(void)doActionOnPlatformLever:(Element *)lever {
    PlatformLever *pl = (PlatformLever*)lever;
    [pl doAction];
    // Updates the lever on the scene.
    [_scene refreshElementAtPosition:pl.key OfClass:CLASS_LEVER WithStatus:pl.state];
    // Updates the moving platform connected to the lever on the scene, i.e. moving it.
    [_scene setElementAtPosition:pl.movingPlatform.key IsHidden:NO];
    [_scene refreshElementAtPosition:pl.movingPlatform.key OfClass:CLASS_MOVING_PLATFORM WithStatus:pl.movingPlatform.blocking];
    
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:self
                                   selector:@selector(movePlatform:)  userInfo:pl.movingPlatform
                                    repeats:YES];
}

-(void)movePlatform:(NSTimer *)timer {
    MovingPlatform *mp = [timer userInfo];
    [[_board elementDictionary] removeObjectForKey:mp.key];
    
    CGPoint prevPoint = CGPointMake(mp.x, mp.y);
    if(mp) {
        CGPoint p = mp.path.nextPoint;
        mp.x = p.x;
        mp.y = p.y;
        
        NSInteger dir = [Converter convertCoordsTo:prevPoint Direction:p];
        
        if(_littleJohn.x == prevPoint.x && _littleJohn.y == prevPoint.y) {
            _littleJohn.x = mp.x;
            _littleJohn.y = mp.y;
            [_scene updateUnit:CGPointMake(_littleJohn.x, _littleJohn.y) inDirection:dir];
        }
        
        if(_bigL.x == prevPoint.x && _bigL.y == prevPoint.y) {
            _bigL.x = mp.x;
            _bigL.y = mp.y;
            [_scene updateUnit:CGPointMake(_bigL.x, _bigL.y) inDirection:dir];
        }
    }
    [[_board elementDictionary] setObject:mp forKey:mp.key];
    NSLog(@"%f %f --- %ld %ld",prevPoint.x,prevPoint.y,(long)mp.x,(long)mp.y);
    
    // Check if unit is on platform, if so move it.
    NSLog(@"%ld %ld", (long)_bigL.x, (long)_bigL.y);
    
    [_scene moveElement:prevPoint NewCoord:CGPointMake(mp.x, mp.y)];
}

/*
 *  Checks if the |currentUnit| is on the finish position. */
-(BOOL)isUnitOnGoal {
    return([[_board finishPos] x] == _currentUnit.x && [[_board finishPos] y] == _currentUnit.y);
}

-(NSArray*) getDataFromNotification:(NSNotification *)notif Key:(NSString *)key {
    NSDictionary *userInfo = notif.userInfo;
    NSSet *objectSent = [userInfo objectForKey:key];
    return [objectSent allObjects];
}

-(void)getNextLevel {
    if([LoadSaveFile loadFile]) {
        NSString *currentState = [LoadSaveFile loadFile];
        _world = [[currentState substringWithRange:NSMakeRange(5, 1)] integerValue];
        if([[currentState substringWithRange:NSMakeRange(6, 1)] integerValue] != 0){
            _level = [[currentState substringWithRange:NSMakeRange(6, 2)] integerValue];
        } else {
            _level = [[currentState substringWithRange:NSMakeRange(7, 1)] integerValue];
        }
        _player = [[Player alloc] initWithWorld:_world andLevel:_level];
    } else {
        _player = [[Player alloc] initWithWorld:0 andLevel:1];
    }
}

/*
 *  Creates the units. */
-(void)setupUnits {
    _bigL = [[BigL alloc] init];
    _bigL.x = _board.startPosAstronaut.x;
    _bigL.y = _board.startPosAstronaut.y;
 
    CGPoint p = CGPointMake(_bigL.x, _bigL.y);
    [_scene setupAstronaut:p];
    // If the unit has a valid starting position, it is playing.
    if(_board.startPosAstronaut.x >= 0 && _board.startPosAstronaut.y >= 0) {
        _bigL.isPlayingOnLevel = YES;
    } else {
        _bigL.isPlayingOnLevel = NO;
    }
    
    _littleJohn = [[LittleJohn alloc] init];
    _littleJohn.x = _board.startPosAlien.x;
    _littleJohn.y = _board.startPosAlien.y;

    CGPoint pp = CGPointMake(_littleJohn.x, _littleJohn.y);
    [_scene setupAlien:pp];
    
    if(_board.startPosAlien.x >= 0 && _board.startPosAlien.y >= 0) {
        _littleJohn.isPlayingOnLevel = YES;
    } else {
        _littleJohn.isPlayingOnLevel = NO;
    }
    
    if(_bigL.isPlayingOnLevel && !_littleJohn.isPlayingOnLevel) {
        NSLog(@"Only L");
        _currentUnit = _bigL;
        _nextUnit = _bigL;
        [_scene setCurrentUnitWithMacro:BIG_L];
    } else if(!_bigL.isPlayingOnLevel && _littleJohn.isPlayingOnLevel) {
        NSLog(@"Only John");
        _currentUnit = _littleJohn;
        _nextUnit = _littleJohn;
        [_scene setCurrentUnitWithMacro:LITTLE_JOHN];
    } else if([_bigL isPlayingOnLevel] && [_littleJohn isPlayingOnLevel]) {
        // If both are playing, set astronaut as starting unit as default.
        _currentUnit = _bigL;
        _nextUnit = _littleJohn;
        [_scene setCurrentUnitWithMacro:BIG_L];
    }
}

-(void)setupNextLevel {
    [_scene cleanScene];
    [self setupBoard];
    [self setupElements];
    [self setupUnits];
}

/*
 *  Adds a notification to listen to from this class. */
-(void)observeText:(NSString *)text Selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:text object:nil];
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden {
    return true;
}

-(IBAction)changeUnitAction:(id)sender {
    [self changeUnit];
}

- (IBAction)restartAction:(id)sender {
    [self setupNextLevel];
}
@end
