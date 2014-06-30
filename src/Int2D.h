//
//  Int2D.h
//  MeshEditor
//
//  Created by rOBERTO tORO on 08/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Int2D : NSObject
{
	int	ve[2];
	int	deleted;
}
-(int*)ve;
-(void)setVerts:(int)a :(int)b;
-(int)deleted;
-(void)setDeleted:(int)flag;
@end
