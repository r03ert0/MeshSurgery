//
//  Trackball.h
//  TeaView
//
//  Created by daves on Wed May 03 2000.
//  Copyright (c) 2000 Apple Computer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Trackball : NSObject {
    float m_radius;
    float m_startPt[3];
    float m_endPt[3];
    NSPoint m_ctr;
}

- (id)init;
- (void)start:(NSPoint)pt sender:(NSView *)sender;
- (void)rollTo:(NSPoint)pt sender:(NSView *)sender;
- (void)add:(float *)dA toRotation:(float *)A;

@end
