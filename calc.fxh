////////////////////////////////////////////////////////////////
//
//          Calculus Macros
// 			CCBY 2017 everyoneishappy
////////////////////////////////////////////////////////////////
#define CALC_FXH

// S2, S3, V2, & V3 stand for 2D & 3D scalar and 2D & 3D vector fields 

////////////////////////////////////////////////////////////////
//
//          Placeholder Functions
// 
////////////////////////////////////////////////////////////////

/*
Implmentation placeholder eg:
////////////////////////////////////////////////////////////////
#ifndef VF3D
#define VF3D placeHolderVF3D
#endif

float3 myResult = VF3D(p);
////////////////////////////////////////////////////////////////
*/

float placeHolderS2 (float2 p)
{
	return length(p)*.1;
}

float placeHolderS3 (float3 p)
{
	return length(p)*.1;
}

float2 placeHolderV2 (float2 p)
{
	return p*.1;
}

float3 placeHolderV3 (float3 p)
{
	return p*.1;
}

////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//          Integration
// integrate vector field to position
////////////////////////////////////////////////////////////////

// 	f: function, p: postion, dT: delta time or stepsize

// 'plain' Euler

#define calcEulerV2(f, p, dT)  ( p += f(p) * dT )  
#define calcEulerV3(f, p, dT)  ( p += f(p) * dT )   


//	note RK2 & RK4 will create some variables as 'FOO_FunctionName'

// Runge-Kutta 2

#define calcRK2V2(f, p, dT)								\
	float halfDT_##f = dT * 0.5;						\
	float2 v1_##f = f(p);								\
	float2 v2_##f = f(p + v1_##f * halfDT_##f);			\
	p += (v1_##f + v2_##f)  * halfDT_##f
	

#define calcRK2V3(f, p, dT)								\
	float halfDT_##f = dT * 0.5;						\
	float3 v1_##f = f(p);								\
	float3 v2_##f = f(p + v1_##f * halfDT_##f);			\
	p+= (v1_##f + v2_##f)  * halfDT_##f


// Runge-Kutta 4

#define calcRK4V2(f, p, dT)								\
	float halfDT_##f = dT * 0.5;						\
	float2 v1_##f = f(p);								\
	float2 v2_##f = f(p + v1_##f * halfDT_##f);			\
	float2 v3_##f = f(p + v2_##f * halfDT_##f);			\
	float2 v4_##f = f(p + v3_##f * dT);					\
	p += (v1_##f + v2_##f*2 + v3_##f*2 + v4_##f)/6 *dT 

#define calcRK4V3(f, p, dT)								\
	float halfDT_##f = dT * 0.5;						\
	float3 v1_##f = f(p);								\
	float3 v2_##f = f(p + v1_##f * halfDT_##f);			\
	float3 v3_##f = f(p + v2_##f * halfDT_##f);			\
	float3 v4_##f = f(p + v3_##f * dT);					\
	p += (v1_##f + v2_##f*2 + v3_##f*2 + v4_##f)/6 *dT 

////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//          Partial Derivatives
// 
////////////////////////////////////////////////////////////////

//	Partial Derivative macros work for both scalar or vector function
// 	f: function, p: postion, e: epsilon

// Partial Derivatives in 2D domain
#define calcDx2D(f, p, e) ( (f(p + float2(e,0)) - f(p - float2(e,0))) / (2*e) )
#define calcDy2D(f, p, e) ( (f(p + float2(0,e)) - f(p - float2(0,e))) / (2*e) )


// 2nd Order Partial Derivatives in 2D domain
#define calcDxx2D(f, p, e) ( (f(p + float2(e,0)) + f(p - float2(e,0)) - 2 * f(p)) / (e*e) )
#define calcDyy2D(f, p, e) ( (f(p + float2(0,e)) + f(p - float2(0,e)) - 2 * f(p)) / (e*e) )
#define calcDxy2D(f, p, e) ( (calcDy2D(f, p + float2(0,e), e) - calcDy2D(f, p - float2(0,e), e)) / (2*e) )


// Partial Derivatives in 3D domain
#define calcDx3D(f, p, e) ( (f(p + float3(e,0,0)) - f(p - float3(e,0,0))) / (2*e) )
#define calcDy3D(f, p, e) ( (f(p + float3(0,e,0)) - f(p - float3(0,e,0))) / (2*e) )
#define calcDz3D(f, p, e) ( (f(p + float3(0,0,e)) - f(p - float3(0,0,e))) / (2*e) )

// 2nd Order Partial Derivatives in 3D domain
#define calcDxx3D(f, p, e) ( (f(p + float3(e,0,0)) + f(p - float3(e,0,0)) - 2 * f(p)) / (e*e) )
#define calcDyy3D(f, p, e) ( (f(p + float3(0,e,0)) + f(p - float3(0,e,0)) - 2 * f(p)) / (e*e) )
#define calcDzz3D(f, p, e) ( (f(p + float3(0,0,e)) + f(p - float3(0,0,e)) - 2 * f(p)) / (e*e) )
#define calcDxy3D(f, p, e) ( (calcDx3D(f, p + float3(0,e,0), e) - calcDx3D(f, p - float3(0,e,0), e)) / (2*e) )
#define calcDxz3D(f, p, e) ( (calcDx3D(f, p + float3(0,0,e), e) - calcDx3D(f, p - float3(0,0,e), e)) / (2*e) )
#define calcDyz3D(f, p, e) ( (calcDy3D(f, p + float3(0,0,e), e) - calcDy3D(f, p - float3(0,0,e), e)) / (2*e) )
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//          Gradient
// 
////////////////////////////////////////////////////////////////

//  2D & 3D scalar field gradients
#define calcGradS2(f, p, e) ( float2(calcDx2D(f, p, e), calcDy2D(f, p, e)) )
#define calcGradS3(f, p, e) ( float3(calcDx3D(f, p, e), calcDy3D(f, p, e), calcDz3D(f, p, e)) )

// Normals
#define calcNormS2(f, p, e) normalize( float2(calcDx2D(f, p, e), calcDy2D(f, p, e)) )
#define calcNormS3(f, p, e) normalize( float3(calcDx3D(f, p, e), calcDy3D(f, p, e), calcDz3D(f, p, e)) )

// Jacobian (gradients) of a 2D vector field as 2x2 matrix
#define calcGradV2(f, p, e)(transpose(float2x2(calcDx2D, calcDy2D)))

// Jacobian (gradients) of a 3D vector field as 3x3 matrix
#define calcGradV3(f, p, e)(transpose(float3x3(calcDx3D(f, p, e), calcDy3D(f, p, e), calcDz3D(f, p, e))))


// Hessian aka Jacobian of gradient of a 2D or 3D scalr field
#define calcHessS2(f, p, e) (float2x2 m = {	calcDxx2D(f, p, e), calcDxy2D(f, p, e), 	\
											calcDxy2D(f, p, e), calcDyy2D(f, p, e)  })

#define calcHessS3(f, p, e) (float3x3 m = {	calcDxx3D(f, p, e), calcDxy3D(f, p, e), calcDxz3D(f, p, e),	\
											calcDxy3D(f, p, e), calcDyy3D(f, p, e), calcDyz3D(f, p, e), \
											calcDxz3D(f, p, e), calcDyz3D(f, p, e), calcDzz3D(f, p, e)} )

////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//          Divergence
// 
////////////////////////////////////////////////////////////////
#define calcDivV2(f, p, e) ( calcDx2D(f, p, e).x + calcDy2D(f, p, e).y )
#define calcDivV3(f, p, e) ( calcDx3D(f, p, e).x + calcDy3D(f, p, e).y + calcDz3D(f, p, e).z )

// Laplacian aka Divergence of gradient
#define calcLapS2(f, p, e) ( calcDxx2D(f, p, e) + calcDyy2D(f, p, e) )
#define calcLapS3(f, p, e) ( calcDxx3D(f, p, e) + calcDyy3D(f, p, e) + calcDzz3D(f, p, e) )
#define calcLapV2(f, p, e) float2( calcDxx2D(f, p, e) + calcDyy2D(f, p, e) )
#define calcLapV3(f, p, e) float3( calcDxx3D(f, p, e) + calcDyy3D(f, p, e) + calcDzz3D(f, p, e) )

////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//          Curl
// 
////////////////////////////////////////////////////////////////

#define calcCurlS2(f, p, e) (  calcGradS2(f, p, e).yx * float2(-1, 1) )
#define calcCurlV2(f, p, e)  ( float2(calcDx2D(f, p, e).y,  -calcDy2D(f, p, e).x) )
#define calcCurlV3(f, p, e)  ( (calcGradV3(f, p, e)._32_13_21 - calcGradV3(f, p, e)._23_31_12) )

////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
// 			Pre-Curl ops
// see https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph2007-curlnoise.pdf
////////////////////////////////////////////////////////////////

#define PRECURLRAMP(r) r >= 1.0f ? 1.0f : (r <= -1.0f ? -1.0f : 15.0f/8.0f * r - 10.0f / 8.0f * pow(r,3) + 3.0f / 8.0f * pow(r,5) )
// add constant direction to SF2D curl potential
float preCurlDirection(float2 p, float2 dir) 
{
 	return -p.y * dir.x + p.x * dir.y;
}


// add constant direction to VF3D curl potential
float3 preCurlDirection(float3 p, float3 dir) 
{
  	float3 parallel = dot(dir, p) * dir;
 	float3 orthogonal = p - parallel;
 	return -cross(orthogonal, dir); 
}


// vortex point SF2D curl potential
float preCurlVortex(float2 p, float2 vp, float vStrength, float vRadius)
{
	float dist = distance(p, vp);
	float ramp = PRECURLRAMP(dist/vRadius);
	return (1-ramp) * vStrength;
	
}


// vortex point VF3D curl potential
float3 preCurlVortex(float3 p, float3 vp, float3 vDir, float vRadius)
{
	float dist = distance(p, vp);
	p -= vp;
	float3 parallel = dot(vDir, p) * vDir;
 	float3 orthogonal = p - parallel;
	float ramp = PRECURLRAMP(dist/vRadius);
	return vDir * (1 - ramp);
}

//constrain curl potential field around 2D sdf surface
#define calcPreCurlSurfaceS2(f, sdf, p, radius) ( f(p) * ( PRECURLRAMP(sdf(p)/radius)) )

/*
//constrain curl potential field around 3D sdf surface
float3 preCurlSurface()
{	
	float3 pf = FN_INPUT(p);
	float3 normal = calcNormS3(FN_SDF, p, FN_eps);
	float d = FN_SDF(p);
	float ramp = abs(PRECURLRAMP(d/FN_radius));
	return ramp * pf + (1 - ramp) * normal * dot(normal, pf);
}
*/
////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////
//EOF


