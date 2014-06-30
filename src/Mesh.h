//
//  Mesh.h
//  MeanValueCoordinates
//
//  Created by rOBERTO tORO on 02/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#import "Float3D.h"
#import "Int3D.h"
#import "Int2D.h"
#include "math3D.h"

@interface Mesh : NSObject
{
	// mesh
	NSMutableArray		*edges;
	NSMutableArray		*triangles;
	NSMutableArray		*points;
	NSMutableArray		*colours;
	
	int	displaySurface;
	int	displayWireframe;
	int	displayVertices;
	int	displayNormals;

	// vertices and selection cursor
	float3D			cp[8];
	int3D			ct[12];
	float3D			cc[12];
	float			zoom;
	
	float3D			center;
	int				smoothFlag;
	float			smoothValue;
    float           smoothIter;
	float			angle1; // CNS flexure
	float			angle2;	// left right angle
	
	int				numberOfSelectedVertices;
	
	// filename
	NSString		*filename;
}
-(float3D)center;
-(void)setCenter:(float3D)theCenter;
-(void)setCenterToSelectedVertex;

-(NSMutableArray*)edges;
-(NSMutableArray*)triangles;
-(NSMutableArray*)points;
-(NSMutableArray*)colours;

-(int)selectedCount;
-(void)selectAll;
-(void)selectNone;
-(void)selectConnected;
-(void)selectMore;
-(void)selectLess;
-(void)selectTunnel;
-(void)selectNonmanifold;

-(void)configureSmooth;
-(void)setSmoothValue:(float)t;

-(void)setAngle1:(float)a;
-(void)setAngle2:(float)a;

-(void)setDisplaySurface:(int)flag;
-(void)setDisplayWireframe:(int)flag;
-(void)setDisplayVertices:(int)flag;
-(void)setDisplayNormals:(int)flag;

-(void)setZoom:(float)theZoom;

-(NSString*)filename;

-(void)draw;
-(float3D)interp:(Float3D*)p;
-(void)drawSurface;
-(void)drawWireframe;
-(void)drawVertices;
-(void)drawNormals;
-(void)drawEdges;
-(void)drawSelectedVertices;

-(void)depth;

-(Float3D*)addVertex:(float3D)p;
-(void)addEdge;
-(void)addTriangle;
-(void)deleteSelectedVertices;
-(void)deleteSelectedTriangles;
-(void)cleanMesh;
-(NSArray*)selectLoop;
-(void)fillLoop;
-(void)fillLoop2;
-(void)invertSelection;
-(void)fixNormals;
-(void)flipNormals;

-(void)writeToPath:(NSString*)path;
-(void)readFromPath:(NSString*)path;
-(void)readVerticesFromPath:(NSString*)path;

-(int)numberOfSelectedVertices;
-(int)indexOfFirstSelectedVertex;

-(void)nradio;
-(void)flipEdge;
-(void)applyRotation;

void mobius1(float x0, float y0, float th, float R, float *x1, float *y1);
void mobius2(float x0, float y0, float th, float R, float *x1, float *y1);
@end
