//
//  Int2D.m
//  MeshEditor
//
//  Created by rOBERTO tORO on 08/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Int2D.h"


@implementation Int2D
-(id)init
{
	ve[0]=0;
	ve[1]=0;
	deleted=NO;
	return [super init];
}
-(int*)ve
{
	return ve;
}
-(void)setVerts:(int)a :(int)b
{
	ve[0]=a;
	ve[1]=b;
}
-(int)deleted
{
	return deleted;
}
-(void)setDeleted:(int)flag
{
	deleted=flag;
}
@end
