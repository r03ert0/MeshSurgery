//
//  Float3D.h
//  MeshEditor
//
//  Created by rOBERTO tORO on 08/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Float3D : NSObject
{
	float	co[3];
	float	cos[3];
	int		selected;
	int		deleted;
}
-(float*)co;
-(void)setCoords:(float)x :(float)y :(float)z;
-(float*)cos;
-(void)setSmoothCoords:(float)x :(float)y :(float)z;
-(int)deleted;
-(void)setDeleted:(int)flag;
-(int)selected;
-(void)setSelected:(int)flag;
-(void)print;
@end
