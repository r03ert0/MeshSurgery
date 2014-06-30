/* MyMVCView */

#import <Cocoa/Cocoa.h>
#import "Trackball.h"
#import "Mesh.h"

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>

@interface MyView : NSOpenGLView
{
	IBOutlet NSTextField		*msg;
	IBOutlet NSObjectController	*settings;
	
	Mesh		*mesh;

	// view
	float		zoom;
	float		m[16],invm[16];
	
	// trackball & rotation
	Trackball	*m_trackball;
	float		m_rotation[4];	// The main rotation
	float		m_tbRot[4];		// The trackball rotation
	float		rot[3];			// 3-axes rotation (controller with sliders)
	
	float		depth;
	
	//state
	int			moving;
	NSPoint		oldmp;
	
	// display
	int			displayBackface;
}
-(void)configureSettings;

-(void)rotateBy:(float *)r;		// trackball method
-(void)setRotationAroundAxis:(int)axis angle:(float)angle; // 3-axes rotation
-(void)setZoom:(float)z;
-(void)setStandardRotation:(int)tag;
-(void)addRotation:(float)value toAxis:(int)axis;
-(void)setMesh:(Mesh*)theMesh;
-(void)setDisplayBackface:(int)flag;

-(int)pickVertex:(NSPoint)mp;
-(void)dragVertex:(NSPoint)mp;
-(void)addVertex:(NSPoint)mp;

-(void)selectVertex:(int)vertexIndex;
@end
