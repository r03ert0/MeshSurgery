//
//  Int3D.m
//  MeshEditor
//
//  Created by rOBERTO tORO on 08/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Int3D.h"


@implementation Int3D
-(id)init
{
	ve[0]=0;
	ve[1]=0;
	ve[2]=0;
	deleted=NO;
	return [super init];
}
-(int*)ve
{
	return ve;
}
-(void)setVerts:(int)a :(int)b :(int)c
{
	ve[0]=a;
	ve[1]=b;
	ve[2]=c;
}
-(int)deleted
{
	return deleted;
}
-(void)setDeleted:(int)flag
{
	deleted=flag;
}
-(NSString*)description
{
	return [NSString stringWithFormat:@"%i,%i,%i",ve[0],ve[1],ve[2]];
}
@end
