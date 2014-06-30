//
//  MyDocument.h
//  MeshSurgery
//
//  Created by roberto on 26/04/2009.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "DocumentRAMON.h"
#import "MyView.h"

@interface MyDocument : DocumentRAMON
{
    IBOutlet MyView			*view;
	IBOutlet NSTextField	*vertex;
	
	Mesh	*mesh;
}
// Start RAMON methods
-(void)configureVisualisation;
-(void)cleanVisualisation;
// End RAMON methods

-(IBAction)updateDisplay:(id)sender;
-(IBAction)changeVertex:(id)sender;
-(IBAction)setZoom:(id)sender;
-(IBAction)setSmooth:(id)sender;
-(IBAction)setStandardRotation:(id)sender;
-(IBAction)addRotation:(id)sender;
-(IBAction)selectConnected:(id)sender;
-(IBAction)selectMore:(id)sender;
-(IBAction)selectLess:(id)sender;
-(IBAction)selectNonmanifold:(id)sender;
-(IBAction)selectLoop:(id)sender;
-(IBAction)selectTunnel:(id)sender;
-(IBAction)fillLoop:(id)sender;
-(IBAction)invertSelection:(id)sender;
-(IBAction)flipNormals:(id)sender;
-(IBAction)fixNormals:(id)sender;
-(IBAction)foldingPattern:(id)sender;
-(IBAction)selectVertex:(id)sender;
-(IBAction)nradio:(id)sender;
-(IBAction)fillLoop2:(id)sender;
-(IBAction)flipEdge:(id)sender;
-(IBAction)applyRotation:(id)sender;
-(void)vertexMoved:(NSNotification*)no;
-(void)vertexAdded:(NSNotification*)no;

-(IBAction)rebrain:(id)sender;
-(IBAction)setAngle1:(id)sender;
-(IBAction)setAngle2:(id)sender;

@end
