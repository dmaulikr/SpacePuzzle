//
//  Palette.h
//  SpacePuzzleEditor
//
//  Created by IxD on 12/11/13.
//  Copyright (c) 2013 WMD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>

@interface Palette : NSPanel
@property (weak) IBOutlet NSImageView *solidTile;
@property (weak) IBOutlet NSButton *sdf;
@property (weak) IBOutlet NSImageView *crackedTile;
@property (weak) IBOutlet NSImageView *voidTile;
// Image view that indicate which brush that has been selected.
@property (weak) IBOutlet NSImageView *selectedStar;
@property (weak) IBOutlet NSImageView *selectedBridgeButton;
@property (weak) IBOutlet NSImageView *selectedBridge;
@property (weak) IBOutlet NSImageView *selectedSolid;
@property (weak) IBOutlet NSImageView *selectedCracked;
@property (weak) IBOutlet NSImageView *selectedRock;
@property (weak) IBOutlet NSImageView *selectedFinish;
@property (weak) IBOutlet NSImageView *selectedVoid;
@property (weak) IBOutlet NSImageView *selectedEraser;
@property (weak) IBOutlet NSImageView *selectedStarButton;
@property (weak) IBOutlet NSImageView *selectedStart;
@property (weak) IBOutlet NSImageView *selectedLever;
@property (weak) IBOutlet NSImageView *selectedPlatform;
@property (weak) IBOutlet NSImageView *selectedAlien;


-(void)notifyText:(NSString *)text Object: (NSObject*)object Key: (NSString*)key;
-(void)setSelectedIndicatorIsHiddenSolid: (BOOL)solid IsCracked: (BOOL)cracked IsVoid: (BOOL)isVoid
                                 isStart: (BOOL)start isFinished: (BOOL)finish isRock: (BOOL)rock
                                  isStar: (BOOL)star isEraser: (BOOL)eraser isStarButton: (BOOL) starbtn
                          isBridgeButton: (BOOL)bridgebtn isBridge: (BOOL)bridge isLever: (BOOL)lever
                              isPlatform: (BOOL)platform isAlien: (BOOL)alien;
// When a brush has been selected, these actions are run.
-(IBAction)starButtonClick:(id)sender;
-(IBAction)solidClick:(id)sender;
-(IBAction)crackedAction:(id)sender;
-(IBAction)voidClick:(id)sender;
-(IBAction)startClick:(id)sender;
-(IBAction)finishClick:(id)sender;
-(IBAction)rockClick:(id)sender;
-(IBAction)starClick:(id)sender;
-(IBAction)eraserClick:(id)sender;
-(IBAction)bridgeClick:(id)sender;
- (IBAction)platformClick:(id)sender;
- (IBAction)leverClick:(id)sender;
- (IBAction)startAlienClick:(id)sender;


@end
