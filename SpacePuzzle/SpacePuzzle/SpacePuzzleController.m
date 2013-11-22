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

@implementation SpacePuzzleController
@synthesize board = _board;
@synthesize scene = _scene;
@synthesize currentUnit = _currentUnit;
@synthesize bigL = _bigL;
@synthesize littleJohn = _littleJohn;
@synthesize player = _player;

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [MainScene sceneWithSize:skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    
    _player = [[Player alloc] init];
    
    [self setupBoard];
    [self setupElements];
    [self setupUnits];
    
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
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:_scene.view];
        
        // Convert to board coordinates. Invert with -9.
        location = [Converter convertMousePosToCoord:location];
        location.y = abs(location.y - 9);
        
        [self unitWantsToMoveTo:location];
    }
}

/* 
 *  Called when the user double taps the view. */
-(void)doubleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:_scene.view];
        
        // Convert to board coordinates. Invert with -9.
        location = [Converter convertMousePosToCoord:location];
        location.y = abs(location.y - 9);
        
        [self unitWantsToDoActionAt:location];
    }
}

-(void)swipeUp:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.y -= 1;
        [self unitWantsToMoveTo:location];
    }
}

-(void)swipeDown:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.y += 1;
        [self unitWantsToMoveTo:location];
    }
}

-(void)swipeLeft:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.x -= 1;
        [self unitWantsToMoveTo:location];
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = CGPointMake(_currentUnit.x, _currentUnit.y);
        location.x += 1;
        [self unitWantsToMoveTo:location];
    }
}

/*
 *  Loads the board according to the level. ADD LEVELFACTORY!!!. */
-(void)setupBoard {
    _board = [[Board alloc] init];
    // Load the board.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mario" ofType:@"splvl"];
    [_board loadBoard:path];
    
    for(int i = 0; i < BOARD_SIZE_Y; i++) {
        for(int j = 0; j < BOARD_SIZE_X; j++) {
            BoardCoord *bc = [_board.board objectAtIndex:BOARD_SIZE_X*i + j];
            [_scene setupBoardX:[bc x] Y:[bc y] Status:[bc status]];
        }
    }
}

-(void)setupElements {
    // Talk to the scene what to show.
    NSEnumerator *enumerator = [[_board elementDictionary] objectEnumerator];
    Element *obj;
    while((obj = [enumerator nextObject])) {
        CGPoint p = CGPointMake([obj x], [obj y]);
        NSString *str = NSStringFromClass([obj class]);
        
        if(![str isEqualToString:@"StarButton"] && ![str isEqualToString:@"BridgeButton"]) {
            [_scene setupElement:p Name:str Hidden:[obj hidden]];
        } else {
            [_scene setupElement:p Name:@"ButtonOFF" Hidden:[obj hidden]];
        }
    }
    // TEMP TEST CODE FOR STAR BUTTON
    NSNumber *nr = [NSNumber numberWithInteger:2*BOARD_SIZE_X];
    obj = [[_board elementDictionary] objectForKey:nr];
    Star *s = (Star*)obj;
    s.hidden = YES;
    [_scene setElementAtPosition:s.key IsHidden:YES];
    StarButton *st = [[StarButton alloc] initWithStar:s X:0 Y:0];
    nr = [NSNumber numberWithInteger:0];
    [[_board elementDictionary] setObject:st forKey:nr];
    CGPoint p = CGPointMake(0, 0);
    [_scene setupElement:p Name:@"ButtonOFF" Hidden:NO];
    
    // TEMP TEST CODE FOR PLATFORM LEVER
    nr = [NSNumber numberWithInteger:2*BOARD_SIZE_X+1];
    MovingPlatform *mp = [[MovingPlatform alloc] initWithX:2 Y:0 Hidden:NO];
    [[_board elementDictionary] setObject:mp forKey:mp.key];
    PlatformLever *pl = [[PlatformLever alloc] initWithMovingPlatform:mp X:1 Y:0];
    [[_board elementDictionary] setObject:pl forKey:pl.key];
    p = CGPointMake(2, 0);
    [_scene setupElement:p Name:@"MovingPlatform" Hidden:NO];
    [_scene setElementAtPosition:mp.key IsHidden:NO];
    [_scene setElementAtPosition:pl.key IsHidden:NO];
    
    nr = [NSNumber numberWithInteger:1];
    [[_board elementDictionary] setObject:pl forKey:nr];
    p = CGPointMake(1, 0);
    [_scene setupElement:p Name:@"SwitchOFF" Hidden:NO];
}

/*
 *  Called when a unit wants to move to a location on the board. This method checks if the move is possible,
 *  if so moves the unit. If unit moves to star, consume the star. */
-(void)unitWantsToMoveTo:(CGPoint)loc {
    // The position that the unit wants to move to.
    NSInteger x  = loc.x;
    NSInteger y = loc.y;
    NSNumber *nextPosKey = [NSNumber numberWithInt:y*BOARD_SIZE_X + x];
    NSInteger nextPosIntKey = [nextPosKey integerValue];
    // The unit who wants to move's position.
    NSInteger unitX = _currentUnit.x;
    NSInteger unitY = _currentUnit.y;
    NSNumber *unitKey = [NSNumber numberWithInt:unitY*BOARD_SIZE_X + unitX];
    NSInteger unitIntKey = [unitKey integerValue];
    
    // First check if the movement was inside the board and if the tile isn't |void| (which units cannot
    // move to).
    if(x >= 0 && x < BOARD_SIZE_X && y >= 0 && y < BOARD_SIZE_Y
       && [[[_board board] objectAtIndex:nextPosIntKey] status] != MAPSTATUS_VOID) {
        // Checks if the move is 1 step in x or y, but not both at the same time.
        if( ((x - unitX == 1 || x - unitX == -1) && y == unitY) ||
            ((y - unitY == 1 || y - unitY == -1) && x == unitX) )
        {
            // If |bigL| is standing on a cracked tile and moves away from it. This will destroy the tile,
            // making it void, and also destroying the item on it.
            if ([[[_board board] objectAtIndex:unitIntKey] status] == MAPSTATUS_CRACKED && _currentUnit == _bigL) {
                [[_board elementDictionary] removeObjectForKey:unitKey];
                [_scene removeElementAtPosition:unitKey];
                [[[_board board] objectAtIndex:unitIntKey] setStatus:MAPSTATUS_VOID];
                [_scene refreshTileAtFlatIndex:unitIntKey WithStatus:MAPSTATUS_VOID];
            }
           
            // Updates the position of curKey to the one that the unit is moving towards.
            NSNumber *nextPos = [NSNumber numberWithInt:y*BOARD_SIZE_X + x];
            // Check elements on the board.
            Element *e = [[_board elementDictionary] objectForKey:nextPos];
            
            // If the element isn't blocking, move unit.
            if(![e blocking]) {
                _currentUnit.x = x;
                _currentUnit.y = y;
                [_scene updateUnit:CGPointMake(x, y)];
                [e movedTo];
                
                // If the element is a star.
                if([e isKindOfClass:[Star class]] && ![e hidden]) {
                    _player.starsTaken += 1;
                    [[_board elementDictionary] removeObjectForKey:nextPosKey];
                    [_scene removeElementAtPosition:nextPosKey];
                }
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
 
    // Checks if element will be next to the unit.
    if( ((x - unitX == 1 || x - unitX == -1) && y == unitY) ||
       ((y - unitY == 1 || y - unitY == -1) && x == unitX) ||
       (x == unitX && y == unitY) )
    {
        Element *e = [[_board elementDictionary] objectForKey:actionPointKey];
    
        // If the element exists.
        if(e) {
            // Do action depending on element type.
            if ([e isKindOfClass:[Box class]]) {
                NSInteger dir = [Converter convertCoordsTo:actionPoint Direction:unitPoint];
                [self doActionOnBox:e InDirection:dir];
            } else if ([e isKindOfClass:[StarButton class]]) {
                [self doActionOnStarButton:e];
            } else if ([e isKindOfClass:[BridgeButton class]]) {
                [self doActionOnBridgeButton:e];
            } else if ([e isKindOfClass:[PlatformLever class]]) {
                [self doActionOnPlatformLever:e];
            }
        }
    }
}

/*
 *  Does an action on a box based on the direction. The action moves the box to a tile. */
-(void)doActionOnBox:(Element *)rock InDirection:(NSInteger)dir{
    NSNumber *nextKey;
    CGPoint nextPos;
    Element *e;
    NSNumber *elementKey = [NSNumber numberWithInteger:rock.y*BOARD_SIZE_X + rock.x];
    
    if (dir == RIGHT) {
        nextKey = [NSNumber numberWithInt:rock.y*BOARD_SIZE_X + rock.x + 1];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x + 1, rock.y);
    } else if (dir == LEFT) {
        nextKey = [NSNumber numberWithInt:rock.y*BOARD_SIZE_X + rock.x - 1];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x - 1, rock.y);
    } else if (dir == UP) {
        nextKey = [NSNumber numberWithInt:(rock.y - 1)*BOARD_SIZE_X + rock.x];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x, rock.y - 1);
    } else {
        nextKey = [NSNumber numberWithInt:(rock.y + 1)*BOARD_SIZE_X + rock.x];
        e = [[_board elementDictionary] objectForKey:nextKey];
        nextPos = CGPointMake(rock.x, rock.y + 1);
    }
    
    // Add more elements which cannot be pushed upon to if-statement.
    if (![e isKindOfClass:[Box class]]) {
        NSInteger intKey = [nextKey integerValue];
        NSInteger nextTile = [[[_board board] objectAtIndex:intKey] status];
        
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
    [sb doAction];
    
    // Updates the button on the scene.
    [_scene refreshElementAtPosition:sb.key OfClass:@"Button" WithStatus:sb.state];
    // Updates the star connected to the button on the scene, i.e. showing it.
    [_scene setElementAtPosition:sb.star.key IsHidden:NO];
    
}

-(void)doActionOnBridgeButton: (Element*)button {
    BridgeButton *bb = (BridgeButton*)button;
    [bb doAction];
    
    // Updates the button on the scene.
    [_scene refreshElementAtPosition:bb.key OfClass:@"Button" WithStatus:bb.state];
    // Updates the bridge connected to the button on the scene, i.e. showing it.
    [_scene setElementAtPosition:bb.bridge.key IsHidden:NO];
    [_scene refreshElementAtPosition:bb.bridge.key OfClass:@"Bridge" WithStatus:bb.bridge.blocking];
}

-(void)doActionOnPlatformLever:(Element *)lever {
    PlatformLever *pl = (PlatformLever*)lever;
    [pl doAction];
    
    // Updates the lever on the scene.
    [_scene refreshElementAtPosition:pl.key OfClass:@"Lever" WithStatus:pl.state];
    // Updates the moving platform connected to the lever on the scene, i.e. moving it.
    [_scene setElementAtPosition:pl.movingPlatform.key IsHidden:NO];
    [_scene refreshElementAtPosition:pl.movingPlatform.key OfClass:@"MovingPlatform" WithStatus:pl.movingPlatform.blocking];
}

-(NSArray*) getDataFromNotification:(NSNotification *)notif Key:(NSString *)key {
    NSDictionary *userInfo = notif.userInfo;
    NSSet *objectSent = [userInfo objectForKey:key];
    return [objectSent allObjects];
}

/*
 *  Creates the units. */
-(void)setupUnits {
    _bigL = [[BigL alloc] init];
    _littleJohn = [[LittleJohn alloc] init];
    
    _currentUnit = _littleJohn;
    _littleJohn.x = _board.startPos.x;
    _littleJohn.y = _board.startPos.y;
    CGPoint p = CGPointMake(_littleJohn.x, _littleJohn.y);
    [_scene setupUnits:p];
}

/*
 *  Adds a notification to listen to from this class. */
-(void)observeText:(NSString *)text Selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:text object:nil];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
