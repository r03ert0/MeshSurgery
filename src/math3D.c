/*
 *  math3D.c
 *  MeanValueCoordinates
 *
 *  Created by rOBERTO tORO on 02/02/2007.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "math3D.h"

float3D add3D(float3D a, float3D b)
{
	return (float3D){a.x+b.x,a.y+b.y,a.z+b.z};
}
float3D sub3D(float3D a, float3D b)
{
	return (float3D){a.x-b.x,a.y-b.y,a.z-b.z};
}
float3D sca3D(float3D a, float f)
{
	return (float3D){a.x*f,a.y*f,a.z*f};
}
float norm3D(float3D v)
{
	return sqrt(v.x*v.x+v.y*v.y+v.z*v.z);
}
float dot3D(float3D a, float3D b)
{
	return (float){a.x*b.x+a.y*b.y+a.z*b.z};
}
float3D cross3D(float3D a, float3D b)
{
	return (float3D){a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-b.x*a.y};
}

// triangle area using Heron's formula
float triangle_area(float3D p0, float3D p1, float3D p2)
{
    float   a,b,c;    // side lengths
    float   s;        // semiperimeter
    float   area;
    
    a=norm3D(sub3D(p0,p1));
    b=norm3D(sub3D(p1,p2));
    c=norm3D(sub3D(p2,p0));
    s=(a+b+c)/2.0;
    
    area=sqrt(s*(s-a)*(s-b)*(s-c));
    
    return area;
}
float triangle_perimetre(float3D p0, float3D p1, float3D p2)
{
    float   a,b,c;    // side lengths
    float   perimetre;
    
    a=norm3D(sub3D(p0,p1));
    b=norm3D(sub3D(p1,p2));
    c=norm3D(sub3D(p2,p0));
    perimetre=(a+b+c);
        
    return perimetre;
}
void inverse4x4(float b[16],float a[16])
{
	float d=	-a[0]*a[5]*a[10]*a[15]+a[0]*a[5]*a[11]*a[14]
    +a[0]*a[9]*a[6]*a[15]-a[0]*a[9]*a[7]*a[14]
    -a[0]*a[13]*a[6]*a[11]+a[0]*a[13]*a[7]*a[10]
    +a[4]*a[1]*a[10]*a[15]-a[4]*a[1]*a[11]*a[14]
    -a[4]*a[9]*a[2]*a[15]+a[4]*a[9]*a[3]*a[14]
    +a[4]*a[13]*a[2]*a[11]-a[4]*a[13]*a[3]*a[10]
    -a[8]*a[1]*a[6]*a[15]+a[8]*a[1]*a[7]*a[14]
    +a[8]*a[5]*a[2]*a[15]-a[8]*a[5]*a[3]*a[14]
    -a[8]*a[13]*a[2]*a[7]+a[8]*a[13]*a[3]*a[6]
    +a[12]*a[1]*a[6]*a[11]-a[12]*a[1]*a[7]*a[10]
    -a[12]*a[5]*a[2]*a[11]+a[12]*a[5]*a[3]*a[10]
    +a[12]*a[9]*a[2]*a[7]-a[12]*a[9]*a[3]*a[6];
	
	b[0]=-(a[5]*a[10]*a[15]-a[5]*a[11]*a[14]-a[9]*a[6]*a[15]+a[9]*a[7]*a[14]+a[13]*a[6]*a[11]-a[13]*a[7]*a[10])/d;
	b[1]=(a[1]*a[10]*a[15]-a[1]*a[11]*a[14]-a[9]*a[2]*a[15]+a[9]*a[3]*a[14]+a[13]*a[2]*a[11]-a[13]*a[3]*a[10])/d;
	b[2]=-(a[1]*a[6]*a[15]-a[1]*a[7]*a[14]-a[5]*a[2]*a[15]+a[5]*a[3]*a[14]+a[13]*a[2]*a[7]-a[13]*a[3]*a[6])/d;
	b[3]=(a[1]*a[6]*a[11]-a[1]*a[7]*a[10]-a[5]*a[2]*a[11]+a[5]*a[3]*a[10]+a[9]*a[2]*a[7]-a[9]*a[3]*a[6])/d;
	
	b[4]=(a[4]*a[10]*a[15]-a[4]*a[11]*a[14]-a[8]*a[6]*a[15]+a[8]*a[7]*a[14]+a[12]*a[6]*a[11]-a[12]*a[7]*a[10])/d;
	b[5]=(-a[0]*a[10]*a[15]+a[0]*a[11]*a[14]+a[8]*a[2]*a[15]-a[8]*a[3]*a[14]-a[12]*a[2]*a[11]+a[12]*a[3]*a[10])/d;
	b[6]=-(-a[0]*a[6]*a[15]+a[0]*a[7]*a[14]+a[4]*a[2]*a[15]-a[4]*a[3]*a[14]-a[12]*a[2]*a[7]+a[12]*a[3]*a[6])/d;
	b[7]=(-a[0]*a[6]*a[11]+a[0]*a[7]*a[10]+a[4]*a[2]*a[11]-a[4]*a[3]*a[10]-a[8]*a[2]*a[7]+a[8]*a[3]*a[6])/d;
	
	b[8]=-(a[4]*a[9]*a[15]-a[4]*a[11]*a[13]-a[8]*a[5]*a[15]+a[8]*a[7]*a[13]+a[12]*a[5]*a[11]-a[12]*a[7]*a[9])/d;
	b[9]=-(-a[0]*a[9]*a[15]+a[0]*a[11]*a[13]+a[8]*a[1]*a[15]-a[8]*a[3]*a[13]-a[12]*a[1]*a[11]+a[12]*a[3]*a[9])/d;
	b[10]=(-a[0]*a[5]*a[15]+a[0]*a[7]*a[13]+a[4]*a[1]*a[15]-a[4]*a[3]*a[13]-a[12]*a[1]*a[7]+a[12]*a[3]*a[5])/d;
	b[11]=-(-a[0]*a[5]*a[11]+a[0]*a[7]*a[9]+a[4]*a[1]*a[11]-a[4]*a[3]*a[9]-a[8]*a[1]*a[7]+a[8]*a[3]*a[5])/d;
    
	b[12]=(a[4]*a[9]*a[14]-a[4]*a[10]*a[13]-a[8]*a[5]*a[14]+a[8]*a[6]*a[13]+a[12]*a[5]*a[10]-a[12]*a[6]*a[9])/d;
	b[13]=(-a[0]*a[9]*a[14]+a[0]*a[10]*a[13]+a[8]*a[1]*a[14]-a[8]*a[2]*a[13]-a[12]*a[1]*a[10]+a[12]*a[2]*a[9])/d;
	b[14]=-(-a[0]*a[5]*a[14]+a[0]*a[6]*a[13]+a[4]*a[1]*a[14]-a[4]*a[2]*a[13]-a[12]*a[1]*a[6]+a[12]*a[2]*a[5])/d;
	b[15]=(-a[0]*a[5]*a[10]+a[0]*a[6]*a[9]+a[4]*a[1]*a[10]-a[4]*a[2]*a[9]-a[8]*a[1]*a[6]+a[8]*a[2]*a[5])/d;
}
void v_m(float *r,float *v,float *m)
{
	// v=1x3
	// m=4x4
	// r=1x3
	r[0]=v[0]*m[0*4+0]+v[1]*m[1*4+0]+v[2]*m[2*4+0] + m[3*4+0];
	r[1]=v[0]*m[0*4+1]+v[1]*m[1*4+1]+v[2]*m[2*4+1] + m[3*4+1];
	r[2]=v[0]*m[0*4+2]+v[1]*m[1*4+2]+v[2]*m[2*4+2] + m[3*4+2];
}

