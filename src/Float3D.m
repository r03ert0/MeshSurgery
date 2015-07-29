//
//  Float3D.m
//  MeshEditor
//
//  Created by rOBERTO tORO on 08/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Float3D.h"


@implementation Float3D
-(id)init
{
	co[0]=0;
	co[1]=0;
	co[2]=0;
	cos[0]=0;
	cos[1]=0;
	cos[2]=0;
	selected=NO;
	deleted=NO;
	return [super init];
}
-(float*)co
{
	return co;
}
-(void)setCoords:(float)x :(float)y :(float)z
{
	co[0]=x;
	co[1]=y;
	co[2]=z;
}
-(float*)cos
{
	return cos;
}
-(void)setSmoothCoords:(float)x :(float)y :(float)z
{
	cos[0]=x;
	cos[1]=y;
	cos[2]=z;
}
-(int)selected
{
	return selected;
}
-(void)setSelected:(int)flag
{
	selected=flag;
}
-(int)deleted
{
	return deleted;
}
-(void)setDeleted:(int)flag
{
	deleted=flag;
}
-(void)print
{
	printf("%f %f %f\n",co[0],co[1],co[2]);
}
@end
