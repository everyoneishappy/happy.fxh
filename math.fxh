#define MATH_FXH

////////////////////////////////////////////////////////////////
//
//             Constants
//
////////////////////////////////////////////////////////////////



#ifndef PI
#define PI 3.1415926535897
#endif

#ifndef INVPI
#define INVPI 0.31830988618
#endif

#ifndef HALFPI
#define HALFPI 1.57079632679
#endif

#ifndef TWOPI
#define TWOPI 6.28318531
#endif

#ifndef TAU
#define TAU (2*PI)
#endif

#ifndef FOURPI
#define FOUR_PI 12.56637061436
#endif


#ifndef FLOATMIN
#define FLOATMIN 1.175494351e-38 
// Minimum representable positive floating-point number
#endif

#ifndef FLOATMAX
#define FLOATMAX 3.402823466e+38 
// Maximum representable floating-point number
#endif


////////////////////////////////////////////////////////////////
//
//             Safe pow functions
//
////////////////////////////////////////////////////////////////

float pows(float a, float b) {return pow(abs(a),b)*sign(a);}
float2 pows(float a, float2 b) {return pow(abs(a),b)*sign(a);}
float3 pows(float a, float3 b) {return pow(abs(a),b)*sign(a);}
float4 pows(float a, float4 b) {return pow(abs(a),b)*sign(a);}

float2 pows(float2 a, float b) {return pow(abs(a),b)*sign(a);}
float2 pows(float2 a, float2 b) {return pow(abs(a),b)*sign(a);}

float3 pows(float3 a, float b) {return pow(abs(a),b)*sign(a);}
float3 pows(float3 a, float3 b) {return pow(abs(a),b)*sign(a);}

float4 pows(float4 a, float b) {return pow(abs(a),b)*sign(a);}
float4 pows(float4 a, float4 b) {return pow(abs(a),b)*sign(a);}

////////////////////////////////////////////////////////////////
//
//             Vector Min/Max
//
////////////////////////////////////////////////////////////////

float vmax(float2 v) 
{
	return max(v.x, v.y);
}

float vmax(float3 v) 
{
	return max(max(v.x, v.y), v.z);
}

float vmax(float4 v) 
{
	return max(max(v.x, v.y), max(v.z, v.w));
}

float vmin(float2 v) 
{
	return min(v.x, v.y);
}

float vmin(float3 v) 
{
	return min(min(v.x, v.y), v.z);
}

float vmin(float4 v) {
	return min(min(v.x, v.y), min(v.z, v.w));
}


////////////////////////////////////////////////////////////////
//
//             HELPER FUNCTIONS
//
////////////////////////////////////////////////////////////////

// Sign function that doesn't return 0
float sgn(float x) 
{
	return (x<0)?-1:1;
}

float2 sgn(float2 v) 
{
	return float2((v.x<0)?-1:1, (v.y<0)?-1:1);
}

float square (float x) 
{
	return x*x;
}

float2 square (float2 x) 
{
	return x*x;
}

float3 square (float3 x) 
{
	return x*x;
}

float lengthSqr(float3 x) 
{
	return dot(x, x);
}

// glsl style mod
#ifndef mod
#define mod(x, y) (x - y * floor((x) / y))
#endif


//EOF


/////////////////////////////////////////////////////////////////////////////////////////