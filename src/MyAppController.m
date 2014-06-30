#import "MyAppController.h"

@implementation MyAppController
-(void)applicationDidFinishLaunching:(NSNotification*)an
{
	omesh=[[Mesh new] retain];
	[omesh readFromPath:@"/Users/roberto/Applications/MeanValueCoordinates/_socios/mono.txt"];
	[omesh setDisplayVertices:NO];
	[view setObject:omesh];

	cmesh=[[Mesh new] retain];
	[cmesh readFromPath:@"/Users/roberto/Applications/MeanValueCoordinates/_socios/monobox.txt"];
	[cmesh setDisplaySurface:NO];
	[view setControl:cmesh];
	
	//[view setupWeights];
	
	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(vertexChanged:)
											name:@"VertexChanged"
											object:nil];
	
	[view setNeedsDisplay:YES];
}
-(IBAction)openDocument:(id)sender
{
	int			selection=[mode selectedColumn];
	NSOpenPanel	*o=[NSOpenPanel openPanel];
	int			result;
	
	switch(selection)
	{
		case 0:
			[o setMessage:@"Open Control Mesh..."];
			break;
		case 1:
			[o setMessage:@"Open Object Mesh..."];
			break;
		case 2:
			[o setMessage:@"Open Deformed Control Mesh..."];
			break;
	}

	result=[o runModalForTypes:nil];
	if(result!=NSOKButton)
		return;
	
	switch(selection)
	{
		case 0:
			[cmesh readFromPath:[[o filenames] objectAtIndex:0]];
			break;
		case 1:
			[omesh readFromPath:[[o filenames] objectAtIndex:0]];
			break;
		case 2:
			[cmesh readVerticesFromPath:[[o filenames] objectAtIndex:0]];
			break;
	}
	[view setNeedsDisplay:YES];
}
-(IBAction)saveDocument:(id)sender
{
	int			selection=[mode selectedColumn];
	NSString	*filename=nil;
	NSSavePanel	*s=[NSSavePanel savePanel];
	int			result;
	
	if(selection==2)
		return;

	// There is only Save As for the moment
	/*
	switch(selection)
	{
		case 0:
			filename=[cmesh filename];
			break;
		case 1:
			filename=[omesh filename];
			break;
	}
	*/
	
	if(filename==nil)
	{
		[self saveDocumentAs:self];
		return;
	}

	result=[s runModal];
	if(result!=NSOKButton)
		return;
	
	switch(selection)
	{
		case 0:
			[cmesh writeToPath:filename];
			break;
		case 1:
			[omesh writeToPath:filename];
			break;
	}
}
-(IBAction)saveDocumentAs:(id)sender
{
	int			selection=[mode selectedColumn];
	NSSavePanel	*s=[NSSavePanel savePanel];
	int			result;
	
	if(selection==2)
		return;

	switch(selection)
	{
		case 0:
			[s setMessage:@"Save Control Mesh As..."];
			break;
		case 1:
			[s setMessage:@"Save Object Mesh As..."];
			break;
	}

	result=[s runModal];
	if(result!=NSOKButton)
		return;
	
	switch(selection)
	{
		case 0:
			[cmesh writeToPath:[s filename]];
			break;
		case 1:
			[omesh writeToPath:[s filename]];
			break;
	}
}
-(IBAction)changeMode:(id)sender
{
	int	selection=[sender selectedColumn];
	[view setMode:selection];
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
-(IBAction)setStandardRotation:(id)sender
{
	int	tag=[[sender selectedCell] tag];
	
	[view setStandardRotation:tag];
}
-(void)vertexChanged:(NSNotification*)no
{
	[vertex setStringValue:[no object]];
}
@end
