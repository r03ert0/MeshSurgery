#import "MyView.h"
@implementation MyView

#pragma mark -
- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)becomeFirstResponder
{
	return YES;
}
- (BOOL)resignFirstResponder
{
	return YES;
}
- (id) initWithFrame: (NSRect) frame
{
    GLuint attribs[] = 
    {
            NSOpenGLPFANoRecovery,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAStencilSize, 8,
            NSOpenGLPFAAccumSize, 0,
            0
    };

    NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes: (NSOpenGLPixelFormatAttribute*) attribs];
    
    self = [super initWithFrame:frame pixelFormat:[fmt autorelease]];
    if (!fmt)	NSLog(@"No OpenGL pixel format");
    [[self openGLContext] makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_SMOOTH);
	glLineWidth(2);
	//glEnable(GL_LINE_SMOOTH);
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
    // initialize the trackball
    m_trackball = [[Trackball alloc] init];
    m_rotation[0]=0.0; // angle
    m_rotation[1]=0.0; // x
    m_rotation[2]=1.0; // y
    m_rotation[3]=0.0; // z
    m_tbRot[0] = 0.0; // angle
    m_tbRot[1] = 0.0; // x
    m_tbRot[2] = 0.0; // y
    m_tbRot[3] = 0.0; // z
	
	// init state
	zoom=1;
	moving=0;
	rot[0]=0;
	rot[1]=0;
	rot[2]=0;
	
	depth=0;
	displayBackface=YES;
	
    return self;
}
-(void)configureSettings
{
	[[settings content] setValue:[NSNumber numberWithFloat:0] forKey:@"smooth"];
	[[settings content] setValue:[NSNumber numberWithFloat:0] forKey:@"zoom"];
	[[settings content] setValue:[NSNumber numberWithFloat:200] forKey:@"cropMax"];
	[[settings content] setValue:[NSNumber numberWithFloat:200] forKey:@"crop"];
}
- (void) drawRect: (NSRect) rect
{
    float	aspectRatio;
	float	crop;
	
	crop=[[[settings content] valueForKey:@"crop"] floatValue];
    
    [self update];

 	// set display configuration
		[mesh setDisplayVertices: [[[settings content] valueForKey:@"vertices"] intValue]];
		[mesh setDisplayWireframe:[[[settings content] valueForKey:@"wireframe"] intValue]];
		[mesh setDisplayNormals:  [[[settings content] valueForKey:@"normals"] intValue]];
		[self setDisplayBackface: [[[settings content] valueForKey:@"backface"] intValue]];

   // init projection
		//if(displayBackface)
		//	glDisable(GL_CULL_FACE);
		//else
			glEnable(GL_CULL_FACE);
        glViewport(0, 0, (GLsizei) 2 * rect.size.width, (GLsizei) 2 * rect.size.height);
        glClearColor(1,1,1, 1);
        glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT+GL_STENCIL_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        aspectRatio = (float)rect.size.width/(float)rect.size.height;
        glOrtho(-aspectRatio*zoom, aspectRatio*zoom, -zoom, zoom, -crop, 500.0);

    // prepare drawing
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glRotatef(m_tbRot[0],m_tbRot[1], m_tbRot[2], m_tbRot[3]);
        glRotatef(m_rotation[0],m_rotation[1], m_rotation[2], m_rotation[3]);
        glRotatef(rot[0],1,0,0);
        glRotatef(rot[1],0,1,0);
        glRotatef(rot[2],0,0,1);
		glGetFloatv(GL_MODELVIEW_MATRIX, m);
		inverse4x4(invm,m);
    	
	// draw
		glLoadMatrixf(m);
		[mesh setZoom:zoom];
		[mesh draw];
		int np,nt;
		np=[[mesh points] count];
		nt=[[mesh triangles] count];			
		[msg setStringValue:[NSString stringWithFormat:@"(%i) v:%i t:%i Euler:%i selected:%i\n",[mesh indexOfFirstSelectedVertex],np,nt,np-nt/2,[mesh numberOfSelectedVertices]]];
	
    [[self openGLContext] flushBuffer];
}
#pragma mark-
-(void)rotateBy:(float *)r
{
    m_tbRot[0] = r[0];
    m_tbRot[1] = r[1];
    m_tbRot[2] = r[2];
    m_tbRot[3] = r[3];
}
-(void)setRotationAroundAxis:(int)axis angle:(float)angle
{
    rot[axis]=angle;
    [self setNeedsDisplay:YES];
}
-(void)setStandardRotation:(int)tag
{
    m_rotation[0] = m_tbRot[0] = 0.0;
    m_rotation[1] = m_tbRot[1] = 0.0;
    m_rotation[2] = m_tbRot[2] = 1.0;
    m_rotation[3] = m_tbRot[3] = 0.0;

    switch(tag)
    {
		case 1:m_rotation[0]= 90;	m_rotation[1]=1;m_rotation[2]=0; break; //sup
        case 4:m_rotation[0]= 90;	break; //frn
        case 5:m_rotation[0]=  0;	break; //lat
        case 6:m_rotation[0]=270;	break; //pos
        case 7:m_rotation[0]=180;	break; //med
        case 9:m_rotation[0]=270;	m_rotation[1]=1;m_rotation[2]=0; break; //inf
    }

    [self setNeedsDisplay:YES];
}
-(void)addRotation:(float)value toAxis:(int)axis
{
	float	tmp[4]={0,0,0,0};
	tmp[axis]=1;
	tmp[0]=value;
	[m_trackball add:tmp toRotation:m_rotation];
	[self setNeedsDisplay:YES];
}
-(void)setZoom:(float)z
{
	zoom=pow(2,-z);
	[self setNeedsDisplay:YES];
}
-(void)setMesh:(Mesh*)theMesh
{
	mesh=theMesh;
}
-(void)setDisplayBackface:(int)flag
{
	displayBackface=flag;
}
#pragma mark -
-(void)keyDown:(NSEvent *) event
{
	int		k;
	
	k=[event keyCode];

	printf("key code:%i\n",k);
	
	if(k==3) // key F, add face
	{
		// count selected
		int		sel=[mesh selectedCount];		
		if([event modifierFlags]&NSShiftKeyMask)
		{
			[mesh fillLoop];
		}
		else
		if(sel==2)	[mesh addEdge];
		else
		if(sel==3)	[mesh addTriangle];
	}
	else
	if(k==8) // key C, change center to first selected vertex
	{
		[mesh setCenterToSelectedVertex];
	}
	else
	if(k==1) // key S, select the loop
	{
		[mesh selectLoop];
	}
	else
	if(k==51) // delete key, delete selection
	{
		if([event modifierFlags]&NSShiftKeyMask)
			[mesh deleteSelectedTriangles];
		else
			[mesh deleteSelectedVertices];
	}

	[self setNeedsDisplay:YES];
}
-(void)mouseDown:(NSEvent *)theEvent
{
	// event: selection
	if([theEvent modifierFlags]&NSAlternateKeyMask)
	{
		NSMutableArray	*p;
		float			*co;
		int				i,indx;
		
		p=[mesh points];
		
		oldmp=[self convertPoint:[theEvent locationInWindow] fromView:nil];

		indx=[self pickVertex:oldmp];
	
		// update selection
		if(([theEvent modifierFlags]&NSShiftKeyMask)==0)
		{
			for(i=0;i<[p count];i++)
				[(Float3D*)[p objectAtIndex:i] setSelected:NO];
		}
		if(indx>=0)
		{
			moving=1;

			if([[p objectAtIndex:indx] selected])
				[(Float3D*)[p objectAtIndex:indx] setSelected:NO];
			else
			{
				[(Float3D*)[p objectAtIndex:indx] setSelected:YES];
				[(Float3D*)[p objectAtIndex:indx] print];
				[[settings content] setValue:[NSNumber numberWithInt:indx] forKey:@"selectedVertex"];
			}
			
			// send 'VertexMoved' notification
			co=[[p objectAtIndex:indx] co];
			NSNotification *no=[NSNotification notificationWithName:@"VertexChanged"
												object:[NSString stringWithFormat:@"%.4f,%.4f,%.4f",
														co[0],co[1],co[2]]];
			[[NSNotificationCenter defaultCenter] postNotification:no];
		}
			
		[self setNeedsDisplay:YES];
	}
	// event: add vertex
	if([theEvent modifierFlags]&NSControlKeyMask)
		[self addVertex:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	// event: rotate
	else
		[m_trackball  start:[theEvent locationInWindow] sender:self];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    // Accumulate the trackball rotation
    // into the current rotation.
    [m_trackball add:m_tbRot toRotation:m_rotation];

    m_tbRot[0]=0;
    m_tbRot[1]=1;
    m_tbRot[2]=0;
    m_tbRot[3]=0;
	
	moving=0;
}
- (void)mouseDragged:(NSEvent *)theEvent
{
    [self lockFocus];
	if(moving)
		[self dragVertex:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	else
		[m_trackball rollTo:[theEvent locationInWindow] sender:self];
    [self unlockFocus];
    [self setNeedsDisplay:YES];
}

-(int)pickVertex:(NSPoint)mp
{
	NSRect		bounds=[self bounds];
	float		dist,min,aspectRatio;
	int			i,indx=-1;
	float3D		r,center;
	float3D		po;
	NSMutableArray	*p;

	p=[mesh points];
	center=[mesh center];

	aspectRatio = (float)bounds.size.width/(float)bounds.size.height;
	mp=(NSPoint){aspectRatio*zoom*(2*mp.x-bounds.size.width)/bounds.size.width,zoom*(2*mp.y-bounds.size.height)/bounds.size.height};
	min=zoom*10/(float)bounds.size.width;
	for(i=0;i<[p count];i++)
	{
		po=[mesh interp:(Float3D*)[p objectAtIndex:i]];
		po=sub3D(po,center);
		v_m((float*)&r,(float*)&po,m);
		dist=sqrt(pow(r.x-mp.x,2)+pow(r.y-mp.y,2));
		if(dist<min)
		{
			min=dist;
			indx=i;
		}
	}
    
    if(indx>-1)
    {
        po=*(float3D*)[[p objectAtIndex:indx] co];
        printf("R:%f\n",norm3D(po));
    }
	return indx;
}
-(void)dragVertex:(NSPoint)mp
{
	NSPoint		d;
	NSRect		bounds=[self bounds];
	float		aspectRatio;
	float3D		tmp,tp;
	int			i;
	float3D		po;
	float		*co,*cos;
	Float3D		*p;

	
	for(i=0;i<[[mesh points] count];i++)
	{
		p=[[mesh points] objectAtIndex:i];
		if([p selected])
		{
			po=[mesh interp:p];
			v_m((float*)&tp,(float*)&po,m);
			aspectRatio=(float)bounds.size.width/(float)bounds.size.height;
			d=(NSPoint){mp.x-oldmp.x,mp.y-oldmp.y};
			tp=(float3D){aspectRatio*zoom*2*d.x/bounds.size.width,zoom*2*d.y/bounds.size.height,0};
			v_m((float*)&tmp,(float*)&tp,invm);
			
			co=[p co];
			cos=[p cos];
			[p setCoords:co[0]+tmp.x:co[1]+tmp.y:co[2]+tmp.z];
			[p setSmoothCoords:cos[0]+tmp.x:cos[1]+tmp.y:cos[2]+tmp.z];
		}
	}
	oldmp=mp;
	
	// send 'VertexMoved' notification
	NSNotification *no=[NSNotification notificationWithName:@"VertexMoved"
										object:[NSString stringWithFormat:@"%.4f,%.4f,%.4f",
												po.x+tmp.x,po.y+tmp.y,po.z+tmp.z]];
	[[NSNotificationCenter defaultCenter] postNotification:no];
	
	[self setNeedsDisplay:YES];
}
-(void)addVertex:(NSPoint)mp
{
	NSRect	bounds=[self bounds];
	Float3D	*p;
	float3D	tmp,tp,tp0,center,po,o;
	int		i,n;
	float	aspectRatio;
	
	center=[mesh center];
	depth=0;
	o=(float3D){0,0,0};
	n=0;
	for(i=0;i<[[mesh points] count];i++)
	{
		p=[[mesh points] objectAtIndex:i];
		if([p selected])
		{
			po=*(float3D*)[p co];
			po=sub3D(po,center);
			v_m((float*)&tp0,(float*)&po,m);
			o=add3D(o,tp0);
			n++;
		}
	}
	if(n)
		o=sca3D(o,1/(float)n);
	depth=o.z;
	
	aspectRatio = (float)bounds.size.width/(float)bounds.size.height;
	mp=(NSPoint){aspectRatio*zoom*(2*mp.x-bounds.size.width)/bounds.size.width,zoom*(2*mp.y-bounds.size.height)/bounds.size.height};

	tp=(float3D){mp.x,mp.y,depth};
	v_m((float*)&tmp,(float*)&tp,invm);
	tmp=add3D(tmp,center);
	
	[mesh addVertex:tmp];

	// send 'VertexAdded' notification
	NSNotification *no=[NSNotification notificationWithName:@"VertexAdded" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:no];

	[self setNeedsDisplay:YES];
}
-(void)selectVertex:(int)vertexIndex
{
	NSMutableArray	*p;
	int	i;

	p=[mesh points];

	for(i=0;i<[p count];i++)
		[(Float3D*)[p objectAtIndex:i] setSelected:NO];
	[(Float3D*)[p objectAtIndex:vertexIndex] setSelected:YES];
}
-(void)scrollWheel:(NSEvent *)theEvent
{
	float	resolution=0.1;
	zoom = pow(2,log(zoom)/log(2)-[theEvent deltaY]*resolution);
	[self setNeedsDisplay:YES];
}
#pragma mark -
#pragma mark [   Mean Value Coordinates   ]
float sign(float t)
{
	return (t>=0)?1:(-1);
}
float det(float3D a, float3D b, float3D c)
{
	return a.x*b.y*c.z - a.x*b.z*c.y + a.y*b.z*c.x - a.y*b.x*c.z + a.z*b.x*c.y - a.z*b.y*c.x;
}
@end
