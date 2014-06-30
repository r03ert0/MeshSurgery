//
//  Int3D.h
//  MeshEditor
//
//  Created by rOBERTO tORO on 08/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Int3D : NSObject
{
	int	ve[3];
	int	deleted;
}
-(int*)ve;
-(void)setVerts:(int)a :(int)b :(int)c;
-(int)deleted;
-(void)setDeleted:(int)flag;
-(NSString*)description;
@end
