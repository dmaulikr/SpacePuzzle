//
//  XMLParser.h
//  SpacePuzzleEditor
//
//  Created by IxD on 13/11/13.
//  Copyright (c) 2013 WMD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Position;
@class Box;
@class Star;
@class StarButton;

@interface XMLParser : NSObject <NSXMLParserDelegate> {
    NSString *currentElement;
    BOOL boardElement;
    BOOL startElement;
    BOOL finishElement;
    BOOL rockElement;
    BOOL starElement;
    BOOL boardElements;
    BOOL starButtonElement;
    BOOL starButtonStar;
    NSInteger tempXElement;
    NSInteger tempYElement;
    NSInteger tempXRef;
    NSInteger tempYRef;
    BOOL tempBlockingElement;
    BOOL tempState;
    NSString *output;
}

@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *board;
@property (nonatomic, retain) Position *start;
@property (nonatomic, retain) Position *finish;
@property (nonatomic, retain) NSMutableDictionary *elements;
-(id)initWithContentsOfURL:(NSURL *)url;
-(void)addOutput:(NSString *) string;
-(BOOL)writeToFile:(NSString *)fileName;
@end
