/* MyAppController */

#import <Cocoa/Cocoa.h>
#import "MyMVCView.h"

@interface MyAppController : NSObject
{
    IBOutlet MyMVCView		*view;
	IBOutlet NSTextField	*vertex;
	IBOutlet NSMatrix		*mode;
	
	Mesh	*omesh;		// object mesh
	Mesh	*cmesh;		// control mesh
}
-(IBAction)changeMode:(id)sender;
-(IBAction)changeVertex:(id)sender;
-(IBAction)setZoom:(id)sender;
-(IBAction)setStandardRotation:(id)sender;

-(void)vertexChanged:(NSNotification*)no;
@end
