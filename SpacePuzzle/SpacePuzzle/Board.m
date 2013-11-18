// Board.m
#import "Board.h"
#import "Macros.h"
#import "XMLParser.h"
#import "Rock.h"

@implementation Board

@synthesize board = _board;
@synthesize tilesize = _tilesize;
@synthesize boardSizeX = _boardSizeX;
@synthesize boardSizeY = _boardSizeY;
@synthesize boardBegin = _boardBegin;
@synthesize elementDictionary = _elementDictionary;
@synthesize startPos = _startPos;
@synthesize finishPos = _finishPos;

-(id) init {
    if(self = [super init]){
        _board = [[NSMutableArray alloc] init];
        _parser = [[XMLParser alloc] init];
        _boardSizeX = 7;
        _boardSizeY = 10;
        _tilesize = 44;
        _boardBegin.x = BOARD_PIXEL_BEGIN_X;
        _boardBegin.y = BOARD_PIXEL_BEGIN_Y;
        _elementDictionary = [[NSMutableDictionary alloc] init];
        _startPos = [[Position alloc] initWithX:5 Y:8];
        _finishPos = [[Position alloc] initWithX:0 Y:0];
    }
    return self;
}

/*
 *  Loads a board given a path, i.e. |BoardValues| are set for each coordinate on 
 *  the board. */
- (void) loadBoard:(NSString*) path {
    NSURL *s = [[NSURL alloc] initFileURLWithPath:path];
    _parser = [[XMLParser alloc] initWithContentsOfURL:s];
    
    NSLog(@"%@",[s absoluteString]);
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
    
    // Start and finish positions
    _startPos.x = [[_parser start] x];
    _startPos.y = [[_parser start] y];
    
    _finishPos.x = [[_parser finish] x];
    _finishPos.y = [[_parser finish] y];
    // The elements.
    // Få coords från XMLParser. Används de som key, object själva item. Skapa item mha ClassFromString (strängen fås från XMLParser.
    Rock *rock = [[Rock alloc] initWithX:2 Y:2];
    Rock *rock2 =[[Rock alloc] initWithX:4 Y:3];
    NSNumber *nr = [NSNumber numberWithInt:rock.y*_boardSizeX + rock.x];
    NSNumber *nr2 = [NSNumber numberWithInt:rock2.y*_boardSizeX + rock2.x];
    [_elementDictionary setObject:rock forKey:nr];
    [_elementDictionary setObject:rock2 forKey:nr2];
    
    // id object = [[NSClassFromString(@"NameofClass") alloc] init];
}

-(void)createEmptyBoard {
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
}

/* 
 *  Saves the board to a given path/filename. First you have to add the output to the parser then finally
 *  the actual write to file. */
-(void)saveBoard:(NSString *)fileName {
    // Add the board in xml format.
    [_parser addOutput:@"<board>"];
    for (int i = 0; i < _boardSizeY; i++) {
        for (int j = 0; j < _boardSizeX; j++) {
            BoardCoord* bc = [_board objectAtIndex:(i*_boardSizeX + j)] ;
            NSString *s = @"\n<status>";
            s = [s stringByAppendingString:[@(bc.status) stringValue]];
            s = [s stringByAppendingString:@"</status>"];
            [_parser addOutput:s];
        }
    }
    [_parser addOutput:@"\n</board>"];
    // End of board.
    
    // Start and finish pos.
    [self startAndFinishExport];
    
    // Elements.
    // ...
    
    [_parser writeToFile:fileName];
}

-(void)startAndFinishExport {
    // Start pos.
    [_parser addOutput:@"\n<start>"];
    NSString *coordX = @"\n<x>";
    coordX = [coordX stringByAppendingString:[@(_startPos.x) stringValue]];
    coordX = [coordX stringByAppendingString:@"</x>"];
    [_parser addOutput:coordX];
    
    NSString *coordY = @"\n<y>";
    coordY = [coordY stringByAppendingString:[@(_startPos.y) stringValue]];
    coordY = [coordY stringByAppendingString:@"</y>"];
    [_parser addOutput:coordY];
    [_parser addOutput:@"\n</start>"];
    
    // Finish pos.
    [_parser addOutput:@"\n<finish>"];
    coordX = @"\n<x>";
    coordX = [coordX stringByAppendingString:[@(_finishPos.x) stringValue]];
    coordX = [coordX stringByAppendingString:@"</x>"];
    [_parser addOutput:coordX];
    
    coordY = @"\n<y>";
    coordY = [coordY stringByAppendingString:[@(_finishPos.y) stringValue]];
    coordY = [coordY stringByAppendingString:@"</y>"];
    [_parser addOutput:coordY];
    [_parser addOutput:@"\n</finish>"];
}
@end