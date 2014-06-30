//
//  Trackball.m
//  TeaView
//
//  Created by daves on Wed May 03 2000.
//  Copyright (c) 2000 Apple Computer, Inc. All rights reserved.
//

#import "Trackball.h"
#include <math.h>

static const float kTol = 0.001;
static const float kRad2Deg = 180. / 3.1415927;
static const float kDeg2Rad = 3.1415927 / 180.;

@implementation Trackball
- (id)init
{
    self = [super init];
    return self;
}

- (void)start:(NSPoint)pt sender:(NSView *)sender
{
    NSRect frame = [sender frame];
    float xxyy;
    float nx, ny;
    
    /* Start up the trackball.  The trackball works by pretending that a ball
       encloses the 3D view.  You roll this pretend ball with the mouse.  For
       example, if you click on the center of the ball and move the mouse straight
       to the right, you roll the ball around its Y-axis.  This produces a Y-axis
       rotation.  You can click on the "edge" of the ball and roll it around
       in a circle to get a Z-axis rotation.
       
       The math behind the trackball is simple: start with a vector from the first
       mouse-click on the ball to the center of the 3D view.  At the same time, set the radius
       of the ball to be the smaller dimension of the 3D view.  As you drag the mouse
       around in the 3D view, a second vector is computed from the surface of the ball
       to the center.  The axis of rotation is the cross product of these two vectors,
       and the angle of rotation is the angle between the two vectors.
     */
    nx = frame.size.width;
    ny = frame.size.height;
    if (nx > ny)
        m_radius = ny * 0.5;
    else
        m_radius = nx * 0.5;
    // Figure the center of the view.
    m_ctr.x = frame.origin.x + frame.size.width * 0.5;
    m_ctr.y = frame.origin.y + frame.size.height * 0.5;
    
    // Compute the starting vector from the surface of the ball to its center.
    m_startPt[0] = pt.x - m_ctr.x;
    m_startPt[1] = +(pt.y - m_ctr.y);
    xxyy = m_startPt[0]*m_startPt[0] + m_startPt[1]*m_startPt[1];
    if (xxyy > m_radius*m_radius) {
        // Outside the sphere.
        m_startPt[2] = 0.;
    } else
        m_startPt[2] = sqrt(m_radius*m_radius - xxyy);
    
}

- (void)rollTo:(NSPoint)pt sender:(NSView*)sender
{
    float xxyy;
    float rot[4];
    float cosAng, sinAng;
    float ls, le, lr;
    
    m_endPt[0] = pt.x - m_ctr.x;
    m_endPt[1] = +(pt.y - m_ctr.y);
    if (fabs(m_endPt[0] - m_startPt[0]) < kTol && fabs(m_endPt[1] - m_startPt[1]) < kTol)
        return; // Not enough change in the vectors to have an action.

    // Compute the ending vector from the surface of the ball to its center.
    xxyy = m_endPt[0]*m_endPt[0] + m_endPt[1]*m_endPt[1];
    if (xxyy > m_radius*m_radius) {
        // Outside the sphere.
        m_endPt[2] = 0.;
    } else
        m_endPt[2] = sqrt(m_radius*m_radius - xxyy);
        
    // Take the cross product of the two vectors. r = s X e
    rot[1] =  m_startPt[1] * m_endPt[2] - m_startPt[2] * m_endPt[1];
    rot[2] = -m_startPt[0] * m_endPt[2] + m_startPt[2] * m_endPt[0];
    rot[3] =  m_startPt[0] * m_endPt[1] - m_startPt[1] * m_endPt[0];
    
    // Use atan for a better angle.  If you use only cos or sin, you only get
    // half the possible angles, and you can end up with rotations that flip around near
    // the poles.
    
    // cos(a) = (s . e) / (||s|| ||e||)
    cosAng = m_startPt[0]*m_endPt[0] + m_startPt[1]*m_endPt[1] + m_startPt[2]*m_endPt[2]; // (s . e)
    ls = sqrt(m_startPt[0]*m_startPt[0] + m_startPt[1]*m_startPt[1] + m_startPt[2]*m_startPt[2]);
    ls = 1. / ls; // 1 / ||s||
    le = sqrt(m_endPt[0]*m_endPt[0] + m_endPt[1]*m_endPt[1] + m_endPt[2]*m_endPt[2]);
    le = 1. / le; // 1 / ||e||
    cosAng = cosAng * ls * le;
    
    // sin(a) = ||(s X e)|| / (||s|| ||e||)
    sinAng = lr = sqrt(rot[1]*rot[1] + rot[2]*rot[2] + rot[3]*rot[3]); // ||(s X e)||;
                                // keep this length in lr for normalizing the rotation vector later.
    sinAng = sinAng * ls * le;
    rot[0] = (float)atan2(sinAng, cosAng) * kRad2Deg; // GL rotations are in degrees.
    
    // Normalize the rotation axis.
    lr = 1. / lr;
    rot[1] *= lr; rot[2] *= lr; rot[3] *= lr;
    
    [sender rotateBy:rot];
}

static void rotation2Quat(float *A, float *q)
{
    float ang2;  // The half-angle
    float sinAng2; // sin(half-angle)
    
    // Convert a GL-style rotation to a quaternion.  The GL rotation looks like this:
    // {angle, x, y, z}, the corresponding quaternion looks like this:
    // {{v}, cos(angle/2)}, where {v} is {x, y, z} / sin(angle/2).
    
    ang2 = A[0] * kDeg2Rad * 0.5;  // Convert from degrees ot radians, get the half-angle.
    sinAng2 = sin(ang2);
    q[0] = A[1] * sinAng2; q[1] = A[2] * sinAng2; q[2] = A[3] * sinAng2;
    q[3] = cos(ang2);
}

- (void)add:(float *)dA toRotation:(float *)A
{
    float q0[4], q1[4], q2[4];
    float theta2, sinTheta2;
    
    // Figure out A' = A . dA
    // In quaternions: let q0 <- A, and q1 <- dA.
    // Figure out q2 = q1 + q0 (note the order reversal!).
    // A' <- q3.
    
    rotation2Quat(A, q0);
    rotation2Quat(dA, q1);
    
    // q2 = q1 + q0;
    q2[0] = q1[1]*q0[2] - q1[2]*q0[1] + q1[3]*q0[0] + q1[0]*q0[3];
    q2[1] = q1[2]*q0[0] - q1[0]*q0[2] + q1[3]*q0[1] + q1[1]*q0[3];
    q2[2] = q1[0]*q0[1] - q1[1]*q0[0] + q1[3]*q0[2] + q1[2]*q0[3];
    q2[3] = q1[3]*q0[3] - q1[0]*q0[0] - q1[1]*q0[1] - q1[2]*q0[2];
    // Here's an excersize for the reader: it's a good idea to re-normalize your quaternions
    // every so often.  Experiment with different frequencies.
    
    // An identity rotation is expressed as rotation by 0 about any axis.
    // The "angle" term in a quaternion is really the cosine of the half-angle.
    // So, if the cosine of the half-angle is one (or, 1.0 within our tolerance),
    // then you have an identity rotation.
    if (fabs(fabs(q2[3] - 1.)) < 1.0e-7) {
        // Identity rotation.
        A[0] = 0.;
        A[1] = 1.;
        A[2] = A[3] = 0.;
        return;
    }
    
    // If you get here, then you have a non-identity rotation.  In non-identity rotations,
    // the cosine of the half-angle is non-0, which means the sine of the angle is also
    // non-0.  So we can safely divide by sin(theta2).
    
    // Turn the quaternion back into an {angle, {axis}} rotation.
    theta2 = acos(q2[3]);
    sinTheta2 = 1./sin(theta2);
    A[0] = theta2 * 2. * kRad2Deg;
    A[1] = q2[0] * sinTheta2;
    A[2] = q2[1] * sinTheta2;
    A[3] = q2[2] * sinTheta2;
}

@end
