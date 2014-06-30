/*
 *  math3D.h
 *  MeanValueCoordinates
 *
 *  Created by rOBERTO tORO on 02/02/2007.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __math3D__
#define __math3D__

#include <math.h>

#define kPi 3.141592653589793
typedef struct
{
	float	x,y,z;
}float3D;
typedef struct
{
	int	a,b,c;
}int3D;
typedef struct
{
	int	a,b;
}int2D;

float3D add3D(float3D a, float3D b);
float3D sub3D(float3D a, float3D b);
float3D sca3D(float3D a, float f);
float norm3D(float3D v);
float dot3D(float3D a, float3D b);
float3D cross3D(float3D a, float3D b);

void inverse4x4(float b[16],float a[16]);
void v_m(float *r,float *v,float *m);

float triangle_area(float3D p0, float3D p1, float3D p2);
float triangle_perimetre(float3D p0, float3D p1, float3D p2);

#endif