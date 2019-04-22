//
//  MyDocument.m
//  MeshSurgery
//
//  Created by roberto on 26/04/2009.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self)
	{
			mesh=nil;
	}
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

	// Start RAMON
	[self setObjectType:"Surface"];
	[self ramonizeAtLaunch];
	// End RAMON

	if(mesh==nil)
		mesh=[[Mesh new] retain];
	[view configureSettings];
	[view setMesh:mesh];
	[view setNeedsDisplay:YES];
}

-(BOOL)writeToFile:(NSString*)path ofType:(NSString*)theType
{
	printf("edited:%s\n",[self isDocumentEdited]?"YES":"NO");
	[mesh writeToPath:path];
	return YES;
}
-(BOOL)readFromFile:(NSString*)path ofType:(NSString *)typeName
{
	mesh=[[Mesh new] retain];
	[mesh readFromPath:path];
	
	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(vertexMoved:)
											name:@"VertexMoved"
											object:nil];
	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(vertexAdded:)
											name:@"VertexAdded"
											object:nil];
    return YES;
}
#pragma mark -
// Start RAMON
// Customised methods
-(void)configureVisualisation
{
	if(size>9) // there may be a tailer
	{
		char	path[1024];

		sscanf(shm," <tailer> \n %s ",path);
		if(mesh)
			[mesh release];

		[self setFileURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:path]]];
		[self setFileType:@"DocumentType"];
		[self setFileModificationDate:[NSDate date]];
		[self readFromFile:[NSString stringWithUTF8String:path] ofType:[self fileType]];
		//[[[NSApp orderedWindows] objectAtIndex:0] setRepresentedFilename:[NSString stringWithUTF8String:path]];
		[view setMesh:mesh];
		[view setNeedsDisplay:YES];
		
/*		
		[[NSNotificationCenter defaultCenter]	addObserver:self
												selector:@selector(vertexMoved:)
												name:@"VertexMoved"
												object:nil];
		[[NSNotificationCenter defaultCenter]	addObserver:self
												selector:@selector(vertexAdded:)
												name:@"VertexAdded"
												object:nil];
*/
	}
}
-(void)cleanVisualisation
{
}
// End RAMON
#pragma mark -
-(IBAction)updateDisplay:(id)sender
{
	[view setNeedsDisplay:YES];
}
-(IBAction)changeVertex:(id)sender
{
	char	*str=(char*)[[sender stringValue] UTF8String];
	float	x,y,z;
	int		n;

	n=sscanf(str," %f , %f , %f ",&x,&y,&z);
	if(n==3)
		printf("change vertex to (%i) %f,%f,%f\n",n,x,y,z);
}
-(IBAction)setZoom:(id)sender
{
	[view setZoom:[sender floatValue]];
}

-(IBAction)setSmooth:(id)sender
{
	float	t=[sender floatValue];

	[mesh configureSmooth];
	[mesh setSmoothValue:t];
	[view setNeedsDisplay:YES];
}
-(IBAction)setAngle1:(id)sender
{
	float	t=[sender floatValue];
	
	[mesh setAngle1:t];
	[view setNeedsDisplay:YES];
}
-(IBAction)setAngle2:(id)sender
{
	float	t=[sender floatValue];
	
	[mesh setAngle2:t];
	[view setNeedsDisplay:YES];
}
-(IBAction)setStandardRotation:(id)sender
{
	int	tag=[[sender selectedCell] tag];
    
    printf("tg:%i\n",tag);
	
	[view setStandardRotation:tag];
}
-(IBAction)addRotation:(id)sender
{
	int	tag=[[sender selectedCell] tag];
	int	value=[sender intValue];
	
	[view addRotation:(value-0.5)*15 toAxis:tag];
}
-(IBAction)selectConnected:(id)sender
{
	[mesh selectConnected];
	[view setNeedsDisplay:YES];
}
-(IBAction)selectMore:(id)sender
{
	[mesh selectMore];
	[view setNeedsDisplay:YES];
}
-(IBAction)selectLess:(id)sender
{
	[mesh selectLess];
	[view setNeedsDisplay:YES];
}
-(IBAction)selectNonmanifoldVerts:(id)sender
{
    [mesh selectNonmanifoldVerts];
    [view setNeedsDisplay:YES];
}
-(IBAction)selectNonmanifoldEds:(id)sender
{
    [mesh selectNonmanifoldEds];
    [view setNeedsDisplay:YES];
}
-(IBAction)selectNonmanifoldTris:(id)sender
{
    [mesh selectNonmanifoldTris];
    [view setNeedsDisplay:YES];
}
-(IBAction)splitVertex:(id)sender
{
    [mesh splitVertex];
    [view setNeedsDisplay:YES];
}
-(IBAction)selectLoop:(id)sender
{
	[mesh selectLoop];
	[view setNeedsDisplay:YES];
}
-(IBAction)selectTunnel:(id)sender
{
	[mesh selectTunnel];
	[view setNeedsDisplay:YES];
}
-(IBAction)fillLoop:(id)sender
{
	[mesh fillLoop];
	[view setNeedsDisplay:YES];
}
-(IBAction)flipNormals:(id)sender
{
	[mesh flipNormals];
	[view setNeedsDisplay:YES];
}
-(IBAction)fixNormals:(id)sender
{
	[mesh fixNormals];
	[view setNeedsDisplay:YES];
}
-(IBAction)foldingPattern:(id)sender
{
	[mesh foldingPattern];
	[view setNeedsDisplay:YES];
}
-(IBAction)invertSelection:(id)sender
{
	[mesh invertSelection];
	[view setNeedsDisplay:YES];
}
-(IBAction)nradio:(id)sender
{
    [mesh nradio];
	[view setNeedsDisplay:YES];
}
-(IBAction)applyRotation:(id)sender
{
    [mesh applyRotation];
    [view setStandardRotation:5];
	[view setNeedsDisplay:YES];
}
-(void)vertexMoved:(NSNotification*)no
{
	[vertex setStringValue:[no object]];
}
-(void)vertexAdded:(NSNotification*)no
{
	// TODO: UPDATE POINTS IN MESH: p STILL CONTAINS THE OLD POINTS  
}
-(IBAction)selectVertex:(id)sender
{
	[view selectVertex:[sender intValue]];
	[view setNeedsDisplay:YES];
}
-(IBAction)fillLoop2:(id)sender
{
    [mesh fillLoop2];
	[view setNeedsDisplay:YES];
}
-(IBAction)flipEdge:(id)sender
{
    [mesh flipEdge];
	[view setNeedsDisplay:YES];
}
-(void)moveTo:(float3D)p
{
	Float3D	*P;
	
	[mesh selectNone];
	P=[mesh addVertex:p];
	[P setSelected:YES];
}
-(void)lineTo:(float3D)p
{
	Float3D	*P;
	
	P=[mesh addVertex:p];
	[P setSelected:YES];
	[mesh addEdge];

	[mesh selectNone];
	[P setSelected:YES];
}
void mobius(float x0, float y0, float th, float R, float *x1, float *y1)
{
	float	x,y;
	float	w,ss;
	float	s0x,s0y,s0z;
	float	s1x,s1y,s1z;
	
	x=x0;
	y=y0;
	
	ss=sqrt(x*x+y*y);
	w=atan2(2*R,ss);
	
	s0x=x*R*sin(2*w)/ss;
	s0y=y*R*sin(2*w)/ss;
	s0z=R*(1+cos(2*w));
	
	s1x=s0x;
	s1y=s0y*cos(th)-(s0z-R)*sin(th);
	s1z=s0y*sin(th)+(s0z-R)*cos(th)+R;
	
	*x1=s1x/(1-s1z/(2*R));
	*y1=s1y/(1-s1z/(2*R));
	
	*x1*=pow(w*2/kPi,0.25);
	*y1*=pow(w*2/kPi,0.25);
}
-(IBAction)rebrain:(id)sender
{
	float	i;
	float	th,R;
	float	x1,y1;
	float	a,x,y,z;
	
	th=0;//th=-0.5;
	R=0.3;
	
	NSArray	*points=[mesh points];
	Float3D	*p;
	float3D	co;
	
	// rotate it right
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		co=*(float3D*)[p co];
		[p setCoords:co.z:co.x:co.y];
	}

	// unbend the mesencephalic flexure
	float3D	ce={0,0,0};
	a=28*kPi/180.0;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		co=*(float3D*)[p co];
		
		x=co.x*cos(a)-co.z*sin(a);
		y=co.y;
		z=co.x*sin(a)+co.z*cos(a);
		mobius(z,x,-0.6,0.3,&x1,&y1);
		[p setCoords:y1:y:x1];
		ce.x+=y1;
		ce.y+=y;
		ce.z+=x1;
	}
	ce.x/=(float)[points count];
	ce.y/=(float)[points count];
	ce.z/=(float)[points count];
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		co=*(float3D*)[p co];
		[p setCoords:co.x-ce.x:co.y-ce.y:co.z-ce.z];
	}
	
	// unsquish
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		co=*(float3D*)[p co];
		
		x=0.5-pow(0.5-co.x,0.6);
		[p setCoords:x:co.y:co.z];
	}

	// lift the temporal lobes
	float3D	o={-1,0,0.5};
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		co=*(float3D*)[p co];
		
		x=sqrt(pow(co.x-o.x,2)+pow(co.y-o.y,2))-0.5;
		y=kPi/2.0-atan2(co.x-o.x,co.y-o.y);
		z=co.z;
		[p setCoords:x:y:z];
	}
	
	[view setNeedsDisplay:YES];
	return;

	// shrink frontal pole
	[self moveTo:(float3D){0.85,-0.1,0}];
	[self lineTo:(float3D){0.85,0.1,0}];
	
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		co=*(float3D*)[p co];
		
		x=1-0.2*pow(pow(co.y-o.y,2)+pow(co.z-o.z,2),0.5);
		[p setCoords:x*co.x:x*co.y:x*co.z];
	}


		
	/*
	 // draw grid
	z=0.7;
	// sagittal
	I=40;
	J=10;
	for(j=0;j<=J;j++)
	for(i=0;i<=I;i++)
	{
		x=-1+2*i/I;
		y=-1+2*j/J;
		mobius1(x,y,th,R,&x1,&y1);
		if(i==0)
			[self moveTo:(float3D){x1,z,y1}];
		else
			[self lineTo:(float3D){x1,z,y1}];
	}
	I=40;
	J=10;
	for(i=0;i<=I;i++)
	for(j=0;j<=J;j++)
	{
		x=-1+2*i/I;
		y=-1+2*j/J;
		mobius1(x,y,th,R,&x1,&y1);
		if(j==0)
			[self moveTo:(float3D){x1,z,y1}];
		else
			[self lineTo:(float3D){x1,z,y1}];
	}

	// coronal
	I=40;
	J=10;
	for(j=0;j<=J;j++)
		for(i=0;i<=I;i++)
		{
			x=-1+2*i/I;
			y=-1+2*j/J;
			mobius1(x,y,th,R,&x1,&y1);
			if(i==0)
				[self moveTo:(float3D){x1,y1,z}];
			else
				[self lineTo:(float3D){x1,y1,z}];
		}
	I=40;
	J=10;
	for(i=0;i<=I;i++)
		for(j=0;j<=J;j++)
		{
			x=-1+2*i/I;
			y=-1+2*j/J;
			mobius1(x,y,th,R,&x1,&y1);
			if(j==0)
				[self moveTo:(float3D){x1,y1,z}];
			else
				[self lineTo:(float3D){x1,y1,z}];
		}
	 */
}
-(IBAction)readSmoothedVertices:(id)sender
{
    NSOpenPanel *open=[NSOpenPanel openPanel];
    int			result;
    NSString	*path;
    
    [open setAllowedFileTypes:[NSArray arrayWithObjects:@"ply",@"txt",nil]];
    result=[open runModal];
    if (result!=NSModalResponseOK)
        return;
    
    path=[[[open URLs] objectAtIndex:0] path];

    [mesh readSmoothedVerticesFromPath:path];
}
@end
