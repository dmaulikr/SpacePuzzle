// Board.m
#import "Converter.h"
#import "Board.h"
#import "Macros.h"
#import "XMLParser.h"
#import "Box.h"
#import "Element.h"
#import "StarButton.h"
#import "Star.h"
#import "Bridge.h"
#import "BridgeButton.h"
#import "MovingPlatform.h"
#import "PlatformLever.h"
#import "Path.h"

@implementation Board

@synthesize board = _board;
@synthesize tilesize = _tilesize;
@synthesize boardSizeX = _boardSizeX;
@synthesize boardSizeY = _boardSizeY;
@synthesize boardBegin = _boardBegin;
@synthesize elementDictionary = _elementDictionary; // Used when getting board from XMLParser.
@synthesize startPosAstronaut = _startPosAstronaut;
@synthesize startPosAlien = _startPosAlien;
@synthesize finishPos = _finishPos;
@synthesize originalNumberOfStars = _originalNumberOfStars;

-(id) init {
    if(self = [super init]){
        _board = [[NSMutableArray alloc] init];
        _parser = [[XMLParser alloc] init];
        _boardSizeX = BOARD_SIZE_X;
        _boardSizeY = BOARD_SIZE_Y;
        _tilesize = TILESIZE;
        _boardBegin.x = BOARD_PIXEL_BEGIN_X;
        _boardBegin.y = BOARD_PIXEL_BEGIN_Y;
        _elementDictionary = [[NSMutableDictionary alloc] init];
        _startPosAstronaut = [[Position alloc] initWithX:-2 Y:-2];
        _startPosAlien = [[Position alloc] initWithX:-2 Y:-2];
        _finishPos = [[Position alloc] initWithX:0 Y:0];
        _originalNumberOfStars = 0;
    }
    return self;
}

-(void)moveElementFrom:(CGPoint)from To:(CGPoint)to {
    NSNumber *oldFlatIndex = [NSNumber numberWithInt:from.y*_boardSizeX + from.x];
    NSNumber *newFlatIndex = [NSNumber numberWithInt:to.y*_boardSizeX + to.x];
    
    Element *e = [_elementDictionary objectForKey:oldFlatIndex];
    [_elementDictionary setObject:e forKey:newFlatIndex];
    [_elementDictionary removeObjectForKey:oldFlatIndex];
}

/*
 *  Loads a board given a path, i.e. |BoardValues| are set for each coordinate on 
 *  the board. */
- (void) loadBoard:(NSString*) path {
    NSURL *s = [[NSURL alloc] initFileURLWithPath:path];
    _parser = [[XMLParser alloc] initWithContentsOfURL:s];
    
    [_elementDictionary removeAllObjects];
    [_board removeAllObjects];
    
    // The board tiles.
    for (int i = 0; i < _boardSizeY; i++) {
        //j = columns
        for (int j = 0; j < _boardSizeX; j++) {
            BoardCoord* bc = [[BoardCoord alloc] init];
            bc.x = j;
            bc.y = i;
    
            if(i*_boardSizeX + j < [[_parser board] count]) {
                bc.status = [[[_parser board] objectAtIndex:((i*_boardSizeX) + j)] intValue];
            } else {
                // If the |BoardList| is incomplete for some reason, fill it up with
                // |MAPSTATUS_UNPLAYABLE|.
                bc.status = MAPSTATUS_VOID;
            }
            //(Row number * y) + Column number)
            [_board insertObject:bc atIndex:((i*_boardSizeX) + j)];
        }
    }
    NSLog(@"Loaded board in load board");
    // Start and finish positions
    _startPosAstronaut.x = [[_parser startAstronaut] x];
    _startPosAstronaut.y = [[_parser startAstronaut] y];
    
    _startPosAlien.x = [[_parser startAlien] x];
    _startPosAlien.y = [[_parser startAlien] y];
    
    _finishPos.x = [[_parser finish] x];
    _finishPos.y = [[_parser finish] y];

    // The elements.
    _elementDictionary = [_parser elements];
    _originalNumberOfStars = 0;
    
    for(NSNumber *key in _elementDictionary) {
        NSMutableArray *posArray = [_elementDictionary objectForKey:key];
        NSInteger index = [key integerValue];

        BoardCoord *bc = [_board objectAtIndex:index];

        for(int i = 0; i < posArray.count; i++) {
            [[bc elements] addObject:[posArray objectAtIndex:i]];
            if ([[posArray objectAtIndex:i] isKindOfClass:[Star class]]) {
                _originalNumberOfStars++;
            }
        }
    }
}

/*
 *  Adds an element to the board model. Called when the user has used the editor to create an item. */
-(void)addElementNamed:(NSString *)name AtPosition:(CGPoint)pos IsBlocking:(BOOL)block{
    Element *element = [[NSClassFromString(name) alloc] init];
    element.x = pos.x;
    element.y = pos.y;
    element.blocking = block;
    
    if([name isEqualToString:CLASS_MOVING_PLATFORM]) {
        MovingPlatform *mp = (MovingPlatform*)element;
        [[mp path] addPoint:pos];
    }
    BoardCoord *bc = [_board objectAtIndex:pos.y*BOARD_SIZE_X+pos.x];
    [bc.elements addObject:element];
}

-(void)createEmptyBoard {
    [_board removeAllObjects];
    for (int i = 0; i < _boardSizeY; i++) {
        //j = columns
        for (int j = 0; j < _boardSizeX; j++) {
            BoardCoord* bc = [[BoardCoord alloc] init];
            bc.x = j;
            bc.y = i;
            bc.status = MAPSTATUS_VOID;
            
            //(Row number * y) + Column number)
            [_board insertObject:bc atIndex:((i*_boardSizeX) + j)];
        }
    }
    [_elementDictionary removeAllObjects];
    _startPosAlien.x = -2;
    _startPosAlien.y = -2;
    _startPosAstronaut.x = -2;
    _startPosAstronaut.y = -2;
}

/* 
 *  Saves the board to a given path/filename. First you have to add the output to the parser then finally
 *  the actual write to file. */
-(void)saveBoard:(NSString *)fileName {
    // Add the tiles in xml format.
    [_parser addOutput:@"<board>"];
    [_parser addOutput:@"<coords>"];
    for (int i = 0; i < _boardSizeY; i++) {
        for (int j = 0; j < _boardSizeX; j++) {
            BoardCoord* bc = [_board objectAtIndex:(i*_boardSizeX + j)] ;
            NSString *s = @"<status>";
            s = [s stringByAppendingString:[@(bc.status) stringValue]];
            s = [s stringByAppendingString:@"</status>"];
            [_parser addOutput:s];
        }
    }
    [_parser addOutput:@"</coords>"];
    // End of tiles.
    
    // Start and finish pos in xml format.
    [self startAndFinishExport];
    [self elementExport];
    // Elements.
    // ...
    [_parser addOutput:@"</board>"];
    [_parser writeToFile:fileName];
}

/*
 *  Exports the start and finish tokens to the splvl file. */
-(void)startAndFinishExport {
    // Start pos astro.
    [_parser addOutput:@"<startastronaut>"];
    NSString *coordX = @"<x>";
    
    coordX = [coordX stringByAppendingString:[@(_startPosAstronaut.x) stringValue]];
    coordX = [coordX stringByAppendingString:@"</x>"];
    [_parser addOutput:coordX];
    
    NSString *coordY = @"<y>";
    coordY = [coordY stringByAppendingString:[@(_startPosAstronaut.y) stringValue]];
    coordY = [coordY stringByAppendingString:@"</y>"];
    [_parser addOutput:coordY];
    [_parser addOutput:@"</startastronaut>"];
    
    // Start pos alien.
    [_parser addOutput:@"<startalien>"];
    NSString *coordXAlien = @"<x>";
    coordXAlien = [coordXAlien stringByAppendingString:[@(_startPosAlien.x) stringValue]];
    coordXAlien = [coordXAlien stringByAppendingString:@"</x>"];
    [_parser addOutput:coordXAlien];
    
    NSString *coordYAlien = @"<y>";
    coordYAlien = [coordYAlien stringByAppendingString:[@(_startPosAlien.y) stringValue]];
    coordYAlien = [coordYAlien stringByAppendingString:@"</y>"];
    [_parser addOutput:coordYAlien];
    [_parser addOutput:@"</startalien>"];
    
    // Finish pos.
    [_parser addOutput:@"<finish>"];
    coordX = @"<x>";
    coordX = [coordX stringByAppendingString:[@(_finishPos.x) stringValue]];
    coordX = [coordX stringByAppendingString:@"</x>"];
    [_parser addOutput:coordX];
    
    coordY = @"<y>";
    coordY = [coordY stringByAppendingString:[@(_finishPos.y) stringValue]];
    coordY = [coordY stringByAppendingString:@"</y>"];
    [_parser addOutput:coordY];
    [_parser addOutput:@"</finish>"];
}

/*
 *  Exporting XML formatted data about elements on the canvas. */
-(void)elementExport {
    [_parser addOutput:@"<boardelements>"];
   
    // Start the export with stars.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [Star class]]) {
                Star *ee = (Star*)e;
                [self starExport:ee];
            }
        }
    }
    // Continue the export with boxes.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [Box class]]) {
                Box *ee = (Box*)e;
                [self boxExport:ee];
            }
        }
    }
    // Bridges.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [Bridge class]]) {
                Bridge *ee = (Bridge*)e;
                [self bridgeExport:ee];
            }
        }
    }
    // Moving platform.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [MovingPlatform class]]) {
                MovingPlatform *ee = (MovingPlatform*)e;
                [self movingPlatformExport:ee];
            }
        }
    }
    
    // Buttons, and other elements with references to other elements should be last.
    // Star buttons.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [StarButton class]]) {
                StarButton *ee = (StarButton*)e;
                [self starButtonExport:ee];
            }
        }
    }
    // Bridge buttons.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [BridgeButton class]]) {
                BridgeButton *ee = (BridgeButton*)e;
                [self bridgeButtonExport:ee];
            }
        }
    }
    // Platform lever.
    for(int i = 0; i < _board.count; i++) {
        BoardCoord *bc = [_board objectAtIndex:i];
        for (int j = 0; j < bc.elements.count; j++) {
            Element *e = [bc.elements objectAtIndex:j];
            if([e isKindOfClass: [PlatformLever class]]) {
                PlatformLever *ee = (PlatformLever*)e;
                [self leverExport:ee];
            }
        }
    }
    [_parser addOutput:@"</boardelements>"];
}

/*
 *  Exporting XML formatted data about |Star|. */
-(void)starExport:(Star *)star {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([star class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(star.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(star.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(star.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    
    // End of this element.
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([star class])];
    element = [element stringByAppendingString:@">"];
    
    [_parser addOutput:element];
}

/*
 *  Exporting XML formatted data about |Box|. */
-(void)boxExport:(Box *)box {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([box class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(box.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(box.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(box.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    
    // End of this element.
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([box class])];
    element = [element stringByAppendingString:@">"];
    
    [_parser addOutput:element];
}

/*
 *  Exporting XML formatted data about |Bridge|. */
-(void)bridgeExport:(Bridge *)b {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([b class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(b.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(b.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(b.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    
    // End of this element.
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([b class])];
    element = [element stringByAppendingString:@">"];
    
    [_parser addOutput:element];
}

/*
 *  Exporting XML formatted data about |BridgeButton|. */
-(void)bridgeButtonExport:(BridgeButton *)bb {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([bb class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(bb.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(bb.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(bb.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    element = [element stringByAppendingString:@"<state>"];
    element = [element stringByAppendingString:[@(bb.state) stringValue]];
    element = [element stringByAppendingString:@"</state>"];
    // End of this element.
    
    // The referenced bridge's coordinates.
    if(bb.bridge) {
        element = [element stringByAppendingString:@"<"];
        element = [element stringByAppendingString:BRIDGE_BUTTON_REF];
        element = [element stringByAppendingString:@">"];
        element = [element stringByAppendingString:@"<x>"];
        element = [element stringByAppendingString:[@(bb.bridge.x) stringValue]];
        element = [element stringByAppendingString:@"</x>"];
        element = [element stringByAppendingString:@"<y>"];
        element = [element stringByAppendingString:[@(bb.bridge.y) stringValue]];
        element = [element stringByAppendingString:@"</y>"];
        element = [element stringByAppendingString:@"</"];
        element = [element stringByAppendingString:BRIDGE_BUTTON_REF];
        element = [element stringByAppendingString:@">"];
    }
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([bb class])];
    element = [element stringByAppendingString:@">"];
    [_parser addOutput:element];
}

/*
 *  Exporting XML formatted data about |StarButton|. */
-(void)starButtonExport:(StarButton *)sb {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([sb class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(sb.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(sb.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(sb.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    element = [element stringByAppendingString:@"<state>"];
    element = [element stringByAppendingString:[@(sb.state) stringValue]];
    element = [element stringByAppendingString:@"</state>"];
    // End of this element.
    
    // The referenced star's coordinates.
    if(sb.star) {
        element = [element stringByAppendingString:@"<"];
        element = [element stringByAppendingString:STAR_BUTTON_REF];
        element = [element stringByAppendingString:@">"];
        element = [element stringByAppendingString:@"<x>"];
        element = [element stringByAppendingString:[@(sb.star.x) stringValue]];
        element = [element stringByAppendingString:@"</x>"];
        element = [element stringByAppendingString:@"<y>"];
        element = [element stringByAppendingString:[@(sb.star.y) stringValue]];
        element = [element stringByAppendingString:@"</y>"];
        element = [element stringByAppendingString:@"</"];
        element = [element stringByAppendingString:STAR_BUTTON_REF];
        element = [element stringByAppendingString:@">"];
    }
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([sb class])];
    element = [element stringByAppendingString:@">"];
    [_parser addOutput:element];
}

/*
 *  Exporting XML formatted data about |MovingPlatform|. ADD PATHS!! */
-(void)movingPlatformExport:(MovingPlatform *)mp {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([mp class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(mp.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(mp.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(mp.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    
    element = [element stringByAppendingString:@"<path>"];
    // Path.
    for(int i = 0; i < [[[mp path] points] count]; i++) {
        // Output path.
        CGPoint p = [[mp path] getCGPointAtIndex:i];
        element = [element stringByAppendingString:@"<x>"];
        element = [element stringByAppendingString:[@(p.x) stringValue]];
        element = [element stringByAppendingString:@"</x>"];
        
        element = [element stringByAppendingString:@"<y>"];
        element = [element stringByAppendingString:[@(p.y) stringValue]];
        element = [element stringByAppendingString:@"</y>"];
    }
    element = [element stringByAppendingString:@"</path>"];
    // End of this element.
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([mp class])];
    element = [element stringByAppendingString:@">"];
    
    [_parser addOutput:element];
}

/*
 *  Exporting XML formatted data about |PlatformLever|. */
-(void)leverExport:(PlatformLever *)pl {
    NSString *element = @"<";
    
    element = [element stringByAppendingString:NSStringFromClass([pl class])];
    element = [element stringByAppendingString:@">"];
    
    // Output actual data about the element.
    element = [element stringByAppendingString:@"<x>"];
    element = [element stringByAppendingString:[@(pl.x) stringValue]];
    element = [element stringByAppendingString:@"</x>"];
    element = [element stringByAppendingString:@"<y>"];
    element = [element stringByAppendingString:[@(pl.y) stringValue]];
    element = [element stringByAppendingString:@"</y>"];
    element = [element stringByAppendingString:@"<blocking>"];
    element = [element stringByAppendingString:[@(pl.blocking) stringValue]];
    element = [element stringByAppendingString:@"</blocking>"];
    element = [element stringByAppendingString:@"<state>"];
    element = [element stringByAppendingString:[@(pl.state) stringValue]];
    element = [element stringByAppendingString:@"</state>"];
    // End of this element.
    
    // The referenced star's coordinates.
    if(pl.movingPlatform) {
        element = [element stringByAppendingString:@"<"];
        element = [element stringByAppendingString:LEVER_REF];
        element = [element stringByAppendingString:@">"];
        element = [element stringByAppendingString:@"<x>"];
        element = [element stringByAppendingString:[@(pl.movingPlatform.x) stringValue]];
        element = [element stringByAppendingString:@"</x>"];
        element = [element stringByAppendingString:@"<y>"];
        element = [element stringByAppendingString:[@(pl.movingPlatform.y) stringValue]];
        element = [element stringByAppendingString:@"</y>"];
        element = [element stringByAppendingString:@"</"];
        element = [element stringByAppendingString:LEVER_REF];
        element = [element stringByAppendingString:@">"];
    }
    element = [element stringByAppendingString:@"</"];
    element = [element stringByAppendingString:NSStringFromClass([pl class])];
    element = [element stringByAppendingString:@">"];
    [_parser addOutput:element];
}

-(BOOL)isPointMovableTo:(CGPoint)p {
    BOOL isMovable = NO;
    BOOL movableElementInVoid = NO;
    
    if([self isPointWithinBoard:p]) {
        BoardCoord *bc = [_board objectAtIndex:[Converter CGPointToKey:p]];
        if(bc.elements) {
            for (int i = 0; i < bc.elements.count; i++) {
                Element *e = [bc.elements objectAtIndex:i];
                isMovable = ![e blocking];
                if(!isMovable) {
                    return NO;
                }
                if( ([e isKindOfClass:[Bridge class]] || [e isKindOfClass:[MovingPlatform class]])
                   && ![e blocking]) {
                    movableElementInVoid = YES;
                }
            }
        }
        return [bc status] != MAPSTATUS_VOID || movableElementInVoid;
    }
    return NO;
}

-(BOOL)isPointCracked:(CGPoint)p {
    NSNumber *posKey = [NSNumber numberWithInt:p.y*BOARD_SIZE_X + p.x];
    NSInteger posIntKey = [posKey integerValue];
    BoardCoord *bc = [_board objectAtIndex:posIntKey];
    return bc.status == MAPSTATUS_CRACKED;
}

-(BOOL)isPointWithinBoard:(CGPoint)p {
    return (p.x >= 0 && p.x < BOARD_SIZE_X && p.y >= 0 && p.y < BOARD_SIZE_Y);
}
@end