#define SDF_FXH

// largley based on hg_sdf GLSL lib by MERCURY (CC BY-NC 2016)  http://mercury.sexy/hg_sdf


// simple operations
float U(float a, float b) {return min(a,b);}
float S(float a, float b) {return max(a,-b);}
float I(float a, float b) {return max(a,b);}


// simple operations w/ mat
float2 U(float2 a, float2 b) {return (a.x<b.x) ? a : b;}
float2 S(float2 a, float2 b) {return (a.x>-b.x) ? a : -b;}
float2 I(float2 a, float2 b) {return (a.x>b.x) ? a : b;}


////////////////////////////////////////////////////////////////
//
//             HELPER FUNCTIONS/MACROS
//
////////////////////////////////////////////////////////////////

#ifndef PI
#define PI 3.1415926535897
#endif

#ifndef TWOPI
#define TWOPI 6.28318531
#endif

#ifndef TAU
#define TAU (2*PI)
#endif

#ifndef PHI
#define PHI (sqrt(5)*0.5 + 0.5)
#endif

// glsl style mod
#ifndef mod
#define mod(x, y) (x - y * floor((x) / y))
#endif

// Clamp to [0,1] - this operation is free under certain circumstances.
// For further information see
// http://www.humus.name/Articles/Persson_LowLevelThinking.pdf and
// http://www.humus.name/Articles/Persson_LowlevelShaderOptimization.pdf
//#define saturate(x) clamp(x, 0, 1)

// Sign function that doesn't return 0
float sgn(float x) {
	return (x<0)?-1:1;
}

float2 sgn(float2 v) {
	return float2((v.x<0)?-1:1, (v.y<0)?-1:1);
}

float square (float x) {
	return x*x;
}

float2 square (float2 x) {
	return x*x;
}

float3 square (float3 x) {
	return x*x;
}

float lengthSqr(float3 x) {
	return dot(x, x);
}


// Maximum/minumum elements of a floattor
float vmax(float2 v) {
	return max(v.x, v.y);
}

float vmax(float3 v) {
	return max(max(v.x, v.y), v.z);
}

float vmax(float4 v) {
	return max(max(v.x, v.y), max(v.z, v.w));
}

float vmin(float2 v) {
	return min(v.x, v.y);
}

float vmin(float3 v) {
	return min(min(v.x, v.y), v.z);
}

float vmin(float4 v) {
	return min(min(v.x, v.y), min(v.z, v.w));
}

float dot2( in float3 v ) { return dot(v,v); }


////////////////////////////////////////////////////////////////
//
//             PRIMITIVE DISTANCE FUNCTIONS
//
////////////////////////////////////////////////////////////////
//
// Conventions:
//
// Everything that is a distance function is called fSomething.
// The first argument is always a point in 2 or 3-space called <p>.
// Unless otherwise noted, (if the object has an intrinsic "up"
// side or direction) the y axis is "up" and the object is
// centered at the origin.
//
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//             2D DISTANCE FUNCTIONS
//
////////////////////////////////////////////////////////////////

float draw2DSDF (float dist, float softness = 0.005)
{
	return smoothstep(softness, 0, dist);
};

float fCircle(float2 p, float radius)
{
	return length(p) - radius;
}

// c is the sin/cos of the angle. r is the radius
float fSector(float2 p, float2 c, float r)
{
    p.x = abs(p.x);
    float l = length(p) - r;
	float m = length(p - c*clamp(dot(p,c),0.0,r) );
    return max(l,m*sign(c.y*p.x-c.x*p.y));
}

float fEclipse(float2 p, float2 r)
{
	float a2 = r.x * r.x;
	float b2 = r.y * r.y;
	return (b2 * p.x * p.x + a2 * p.y * p.y - a2 * b2) / (a2 * b2);
}

// Cheap Box: distance to corners is overestimated
float fBox2Cheap(float2 p, float2 b) 
{
	return vmax(abs(p)-b);
}
// Box: correct distance to corners
float fBox(float2 p, float2 b) 
{
	float2 d = abs(p) - b;
	return length(max(d, 0)) + vmax(min(d, 0));
}

//Rounded Box: 
float fRBox(float2 p,float2 b,float rad ) { return length(max(abs(p)-b+rad,0.0))-rad; }

// Endless "corner"
float fCorner (float2 p) 
{
	return length(max(p, 0)) + vmax(min(p, 0));
}

float fLine(float2 p, float2 a, float2 b, float r)
{
	float l = length(b -a);
	float2 n = normalize(b - a);	
	float2 a_p = p - a;
	return length(a_p - clamp(dot(a_p, n), 0, l)*n) - r;
}

float fTriangle(float2 p, float2 a, float2 b, float2 c)
{
	float2 ab = b-a;
	float2 ac = c-a;
	float2 bc = c-b;
	float2 as = p-a;
	float2 bs = p-b;
	
	float2 nab = normalize(float2(-ab.y, ab.x));
	float2 nac = normalize(float2(ac.y, -ac.x));
	float2 nbc = normalize(float2(-bc.y, bc.x));
	
	float u = dot(as, nab);
	float v = dot(as, nac);
	float w = dot(bs, nbc);
	
	return max(max(u, v), w);
}

float fHexagon(float2 p, float radius) 
{
  float2 q = abs(p);
  return max((q.x * 0.866025 + q.y * 0.5), q.y) - radius;
}

////////////////////////////////////////////////////////////////
// https://github.com/keijiro/ShaderSketches
float fLineTruchet (float2 p, float width = 0.05)
{
    float rnd = frac(sin(dot(floor(p), float2(21.98, 19.37))) * 4231.73);
    rnd = floor(rnd * 2) / 2;
    float phi = PI * (rnd +.25);
	float2 pf = frac(p);
	float2 dir = float2(cos(phi), sin(phi));
    float d1 = abs(dot(pf - float2(0.5, 0), dir)); // line 1
    float d2 = abs(dot(pf - float2(0.5, 1), dir)); // line 2
	return min(d1, d2) - width * 0.5;
}

float fCircleTruchet (float2 p, float width = 0.05)
{
    float rnd = frac(sin(dot(floor(p), float2(21.98, 19.37))) * 4231.73);
    rnd = floor(rnd * 2) / 2;
    float phi = PI * (rnd +.25);
	float2 pf = frac(p);
	float2 offs = float2(cos(phi), sin(phi)) * sqrt(2) / 2;
	float d1 = abs(0.5 - distance(pf, float2(0.5 - offs))); // arc 1
	float d2 = abs(0.5 - distance(pf, float2(0.5 + offs))); // arc 2
	return min(d1, d2) - width * 0.5;
}

float fOctoTruchet (float2 p, float width = 0.05)
{
	float rnd = frac(sin(dot(floor(p), float2(21.98, 19.37))) * 4231.73);
	float flip = frac(rnd * 13.8273) > 0.5 ? 1 : -1;
    rnd = floor(rnd * 2)  * flip / 2;
	float phi = PI * rnd;
	float2 pf = frac(p) -.5;
	
	float2 a1 = float2(cos(phi), sin(phi));
    float2 a2 = float2(-a1.y, a1.x);
    float2 a3 = float2(cos(phi + PI / 4), sin(phi + PI / 4));
    float d1 = abs(min(min(dot( pf, a1), dot( pf, a2)), dot( pf, a3) - 0.2));
    float d2 = abs(min(min(dot(-pf, a1), dot(-pf, a2)), dot(-pf, a3) - 0.2));
	return min(d1, d2) - width * 0.5;
}
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             3D DISTANCE FUNCTIONS
//
////////////////////////////////////////////////////////////////


float fSphere(float3 p, float r) 
{
	return length(p) - r;
}

// Plane with normal n (n is normalized) at some distance from the origin
float fPlane(float3 p,  float distanceFromOrigin = 0, float3 n = float3(0,1,0)) 
{
	return dot(p, n) + distanceFromOrigin;
}

//Unsigned
float fTriangle( float3 p, float3 a, float3 b, float3 c )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 ac = a - c; float3 pc = p - c;
    float3 nor = cross( ba, ac );

    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(ac,nor),pc))<2.0)
     ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

// Cheap Box: distance to corners is overestimated
float fBoxCheap(float3 p, float3 b) 
{ //cheap box
	return vmax(abs(p) - b);
}

// Box: correct distance to corners
float fBox(float3 p, float3 b) 
{
	float3 d = abs(p) - b;
	return length(max(d, 0)) + vmax(min(d, 0));
}

// Rounded Cubes: 
float fRBox(float3 p,float3 b,float rad ) { return length(max(abs(p)-b+rad,0.0))-rad; }

// Box Frame
float fBoxFrame( float3 p, float3 b, float e)
{
  
	p = abs(p  )-b;
  float3 q = abs(p+e)-e;

  return min(min(
      length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}


// Blobby ball object. You've probably seen it somewhere. This is not a correct distance bound, beware.
float fBlob(float3 p) 
{
	p = abs(p);
	if (p.x < max(p.y, p.z)) p = p.yzx;
	if (p.x < max(p.y, p.z)) p = p.yzx;
	float b = max(max(max(
		dot(p, normalize(float3(1, 1, 1))),
		dot(p.xz, normalize(float2(PHI+1, 1)))),
		dot(p.yx, normalize(float2(1, PHI)))),
		dot(p.xz, normalize(float2(1, PHI))));
	float l = length(p);
	return l - 1.5 - 0.2 * (1.5 / 2)* cos(min(sqrt(1.01 - b / l)*(PI / 0.25), PI));
}

// Cylinder standing upright on the xz plane
float fCylinder(float3 p, float r, float height) 
{
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}

// Capsule: A Cylinder with round caps on both sides
float fCapsule(float3 p, float r, float c) 
{
	return lerp(length(p.xz) - r, length(float3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}

// Distance to line segment between <a> and <b>, used for fCapsule() version 2below
float fLine(float3 p, float3 a, float3 b) 
{
	float3 ab = b - a;
	float t = saturate(dot(p - a, ab) / dot(ab, ab));
	return length((ab*t + a) - p);
}

// Capsule version 2: between two end points <a> and <b> with radius r 
float fCapsule(float3 p, float3 a, float3 b, float r) 
{
	return fLine(p, a, b) - r;
}

// Torus in the XZ-plane
float fTorus(float3 p, float smallRadius, float largeRadius) 
{
	return length(float2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}

// A circle line. Can also be used to make a torus by subtracting the smaller radius of the torus.
float fCircle(float3 p, float r) 
{
	float l = length(p.xz) - r;
	return length(float2(p.y, l));
}

// A circular disc with no thickness (i.e. a cylinder with no height).
// Subtract some value to make a flat disc with rounded edge.
float fDisc(float3 p, float r) 
{
	float l = length(p.xz) - r;
	return l < 0 ? abs(p.y) : length(float2(p.y, l));
}

float fTriPrism( float3 p, float2 h )
{
    float3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float fPyramid(float3 p, float3 h ) 
{
    float box = fBox( p - float3(0,-2.0*h.z,0),2.0*h.z); 
    float d = 0.0;
    d = max( d, abs( dot(p, float3( -h.x, h.y, 0 )) ));
    d = max( d, abs( dot(p, float3(  h.x, h.y, 0 )) ));
    d = max( d, abs( dot(p, float3(  0, h.y, h.x )) ));
    d = max( d, abs( dot(p, float3(  0, h.y,-h.x )) ));
    float octa = d - h.z;
    return max(-box,octa);
 }

// Hexagonal prism, circumcircle variant
float fHexagonCircumcircle(float3 p, float2 h) 
{
	float3 q = abs(p);
	return max(q.y - h.y, max(q.x*sqrt(3)*0.5 + q.z*0.5, q.z) - h.x);
	//this is mathematically equivalent to this line, but less efficient:
	//return max(q.y - h.y, max(dot(float2(cos(PI/3), sin(PI/3)), q.zx), q.z) - h.x);
}

// Hexagonal prism, incircle variant
float fHexagonIncircle(float3 p, float2 h) 
{
	return fHexagonCircumcircle(p, float2(h.x*sqrt(3)*0.5, h.y));
}

// Cone with correct distances to tip and base circle. Y is up, 0 is in the middle of the base.
float fCone(float3 p, float radius, float height) 
{
	float2 q = float2(length(p.xz), p.y);
	float2 tip = q - float2(0, height);
	float2 mantleDir = normalize(float2(height, radius));
	float mantle = dot(tip, mantleDir);
	float d = max(mantle, -q.y);
	float projected = dot(tip, float2(mantleDir.y, -mantleDir.x));
	
	// distance to tip
	if ((q.y > height) && (projected < 0)) {
		d = max(d, length(tip));
	}
	
	// distance to base ring
	if ((q.x > radius) && (projected > length(float2(height, radius)))) {
		d = max(d, length(q - float2(radius, 0)));
	}
	return d;
}

/////////////////////////////////////////////////////////////////////
// 3 point Bezier
// http://research.microsoft.com/en-us/um/people/hoppe/ravg.pdf
// https://www.shadertoy.com/view/ldj3Wh
// TODO add 2D versions
/////////////////////////////////////////////////////////////////////
float det( float2 a, float2 b ) { return a.x*b.y-b.x*a.y; }
float3 getClosest( float2 b0, float2 b1, float2 b2 )
{
	
	float a = det(b0,b2);
	float b = 2.0*det(b1,b0);
	float d = 2.0*det(b2,b1);
	float f = b*d - a*a;
	float2  d21 = b2-b1;
	float2  d10 = b1-b0;
	float2  d20 = b2-b0;
	float2  gf = 2.0*(b*d21+d*d10+a*d20); gf = float2(gf.y,-gf.x);
	float2  pp = -f*gf/dot(gf,gf);
	float2  d0p = b0-pp;
	float ap = det(d0p,d20);
	float bp = 2.0*det(d10,d0p);
	float t = clamp( (ap+bp)/(2.0*a+b+d), 0.0 ,1.0 );
	return float3( lerp(lerp(b0,b1,t), lerp(b1,b2,t),t), t );
}

//returns distance, phase
float2 fBezier(float3 p,  float3 a, float3 b, float3 c) 
{
	float3 w = normalize( cross( c-b, a-b ) );
	float3 u = normalize( c-b );
	float3 v = normalize( cross( w, u ) );
	
	float2 a2 = float2( dot(a-b,u), dot(a-b,v) );
	float2 b2 = 0.0 ;
	float2 c2 = float2( dot(c-b,u), dot(c-b,v) );
	float3 p3 = float3( dot(p-b,u), dot(p-b,v), dot(p-b,w) );
	
	float3 cp = getClosest( a2-p3.xy, b2-p3.xy, c2-p3.xy );
	
	return float2( sqrt(dot(cp.xy,cp.xy)+p3.z*p3.z), cp.z);
}

//returns distance, phase
float2 fBezierBuffer(float3 p, StructuredBuffer<float3> controlBuffer, int controlCount)
{
	uint segCount = controlCount / (uint)2;
	if(controlCount % (uint)2 == 0) segCount --; // check if even or odd and truncate if needed
	float segSize = 1/(float)segCount;
	
	float2 result = 999999;
	float2 bezSegment = fBezier(p, controlBuffer[0], controlBuffer[1], controlBuffer[2]);
	bezSegment.y *= segSize;
	if(result.x > bezSegment.x) result = bezSegment; //Union operation

	for (uint i = 1; i < segCount; i++)
		{
			uint c0 = 2*i;
			uint c1 = 2*i+1;
			uint c2 = 2*i+2;
			bezSegment = fBezier(p, controlBuffer[c0], controlBuffer[c1], controlBuffer[c2]);
			bezSegment.y = bezSegment.y * segSize + segSize * i; // need to fix phase per segment
			if(result.x > bezSegment.x) result = bezSegment; //Union operation
		}
	return result;
}

//returns distance, tangent
float4 fBezierTang(float3 p,  float3 a, float3 b, float3 c) 
{
	float3 w = normalize( cross( c-b, a-b ) );
	float3 u = normalize( c-b );
	float3 v = normalize( cross( w, u ) );
	
	float2 a2 = float2( dot(a-b,u), dot(a-b,v) );
	float2 b2 = 0.0 ;
	float2 c2 = float2( dot(c-b,u), dot(c-b,v) );
	float3 p3 = float3( dot(p-b,u), dot(p-b,v), dot(p-b,w) );
	
	float3 cp = getClosest( a2-p3.xy, b2-p3.xy, c2-p3.xy );
	float3 tangent = lerp(b-a, c-b, c.z);
	return float4( sqrt(dot(cp.xy,cp.xy)+p3.z*p3.z), tangent);
}

//returns distance, tangent
float4 fBezierBufferTang(float3 p, StructuredBuffer<float3> controlBuffer, int controlCount)
{
	uint segCount = controlCount / (uint)2;
	if(controlCount % (uint)2 == 0) segCount --; // check if even or odd and truncate if needed
	float4 result = 999999;
	float4 bezSegment = fBezierTang(p, controlBuffer[0], controlBuffer[1], controlBuffer[2]);
	if(result.x > bezSegment.x) result = bezSegment;
	for (uint i = 1; i < segCount; i++)
		{
			uint c0 = 2*i;
			uint c1 = 2*i+1;
			uint c2 = 2*i+2;
			float4 bezSegment = fBezierTang(p, controlBuffer[c0], controlBuffer[c1], controlBuffer[c2]);
			if(result.x > bezSegment.x) result = bezSegment; //Union operation
		}
	return result;
}

// 2D version

// quadratic bezier 2D curve evaluation
// posted by Trisomie21

//Helpers
float fBezierCuberoot( float x )
{
	if( x<0.0 ) return -pow(-x,1.0/3.0);
	return pow(x,1.0/3.0);
}

int fBezierSolveCubic(in float a, in float b, in float c, out float r[3])
{
	float  p = b - a*a / 3.0;
	float  q = a * (2.0*a*a - 9.0*b) / 27.0 + c;
	float p3 = p*p*p;
	float  d = q*q + 4.0*p3 / 27.0;
	float offset = -a / 3.0;
	if(d >= 0.0) { // Single solution
		float z = sqrt(d);
		float u = (-q + z) / 2.0;
		float v = (-q - z) / 2.0;
		u = fBezierCuberoot(u);
		v = fBezierCuberoot(v);
		r[0] = offset + u + v;
		return 1;
	}
	float u = sqrt(-p / 3.0);
	float v = acos(-sqrt( -27.0 / p3) * q / 2.0) / 3.0;
	float m = cos(v), n = sin(v)*1.732050808;
	r[0] = offset + u * (m + m);
	r[1] = offset - u * (n + m);
	r[2] = offset + u * (n - m);
	return 3;
}


// Here's the function
float fBezier(float2 p, float2 P0, float2 P1, float2 P2)
{
	float dis = 1e20;
	float2  sb = (P1 - P0) * 2.0;
	float2  sc = P0 - P1 * 2.0 + P2;
	float2  sd = P1 - P0;
	float sA = 1.0 / dot(sc, sc);
	float sB = 3.0 * dot(sd, sc);
	float sC = 2.0 * dot(sd, sd);
	
	float2  D = P0 - p;

	float a = sA;
	float b = sB;
	float c = sC + dot(D, sc);
	float d = dot(D, sd);

    float res[3];
	int n = fBezierSolveCubic(b*a, c*a, d*a, res);

	float t = clamp(res[0],0.0, 1.0);
	float2 pos = P0 + (sb + sc*t)*t;
	dis = min(dis, length(pos - p));
	
    if(n>1) 
	{
		t = clamp(res[1],0.0, 1.0);
		pos = P0 + (sb + sc*t)*t;
		dis = min(dis, length(pos - p));
		    
		t = clamp(res[2],0.0, 1.0);
		pos = P0 + (sb + sc*t)*t;
		dis = min(dis, length(pos - p));	    
    }

    return dis;
}
/////////////////////////////////////////////////////////////////////

//
// "Generalized Distance Functions" by Akleman and Chen.
// see the Paper at https://www.viz.tamu.edu/faculty/ergun/research/implicitmodeling/papers/sm99.pdf
//
// This set of constants is used to construct a large variety of geometric primitives.
// Indices are shifted by 1 compared to the paper because we start counting at Zero.
// Some of those are slow whenever a driver decides to not unroll the loop,
// which seems to happen for fIcosahedron und fTruncatedIcosahedron on nvidia 350.12 at least.
// Specialized implementations can well be faster in all cases.
//

static const float3 GDFVectors[19] = 
{
	normalize(float3(1, 0, 0)),
	normalize(float3(0, 1, 0)),
	normalize(float3(0, 0, 1)),

	normalize(float3(1, 1, 1 )),
	normalize(float3(-1, 1, 1)),
	normalize(float3(1, -1, 1)),
	normalize(float3(1, 1, -1)),

	normalize(float3(0, 1, PHI+1)),
	normalize(float3(0, -1, PHI+1)),
	normalize(float3(PHI+1, 0, 1)),
	normalize(float3(-PHI-1, 0, 1)),
	normalize(float3(1, PHI+1, 0)),
	normalize(float3(-1, PHI+1, 0)),

	normalize(float3(0, PHI, 1)),
	normalize(float3(0, -PHI, 1)),
	normalize(float3(1, 0, PHI)),
	normalize(float3(-1, 0, PHI)),
	normalize(float3(PHI, 1, 0)),
	normalize(float3(-PHI, 1, 0))
};

// Version with variable exponent.
// This is slow and does not produce correct distances, but allows for bulging of objects.
float fGDF(float3 p, float r, float e, int begin, int end) 
{
	float d = 0;
	for (int i = begin; i <= end; ++i)
		d += pow(abs(dot(p, GDFVectors[i])), e);
	return pow(d, 1/e) - r;
}

// Version with without exponent, creates objects with sharp edges and flat faces
float fGDF(float3 p, float r, int begin, int end) 
{
	float d = 0;
	for (int i = begin; i <= end; ++i)
		d = max(d, abs(dot(p, GDFVectors[i])));
	return d - r;
}

// Primitives follow:

float fOctahedron(float3 p, float r, float e) 
{
	return fGDF(p, r, e, 3, 6);
}

float fDodecahedron(float3 p, float r, float e) 
{
	return fGDF(p, r, e, 13, 18);
}

float fIcosahedron(float3 p, float r, float e) 
{
	return fGDF(p, r, e, 3, 12);
}

float fTruncatedOctahedron(float3 p, float r, float e) 
{
	return fGDF(p, r, e, 0, 6);
}

float fTruncatedIcosahedron(float3 p, float r, float e) 
{
	return fGDF(p, r, e, 3, 18);
}

float fOctahedron(float3 p, float r) 
{
	return fGDF(p, r, 3, 6);
}

float fDodecahedron(float3 p, float r) 
{
	return fGDF(p, r, 13, 18);
}

float fIcosahedron(float3 p, float r) 
{
	return fGDF(p, r, 3, 12);
}

float fTruncatedOctahedron(float3 p, float r) 
{
	return fGDF(p, r, 0, 6);
}

float fTruncatedIcosahedron(float3 p, float r) 
{
	return fGDF(p, r, 3, 18);
}

// some fractal novelties 

float fJulia(float3 p, float4 pars = float4(.5, 0, .75, 0), uint iter = 11)
{	
    //float4 c = 0.4*cos( float4(0.5,3.9,1.4,1.1) + time*float4(1.2,1.7,1.3,2.5) ) - float4(0.3,0.0,0.0,0.0);

	float4 z = float4(p,0.0);
    float md2 = 1.0;
    float mz2 = dot(z,z);

    float4 trap = float4(abs(z.xyz),dot(z,z));

    for( uint i=0; i<iter; i++ )
    {
        // |dz|^2 -> 4*|dz|^2
        md2 *= 4.0*mz2;
        
        // z -> z2 + c
        z = float4( z.x*z.x-dot(z.yzw,z.yzw),
                  2.0*z.x*z.yzw ) + pars;

        trap = min( trap, float4(abs(z.xyz),dot(z,z)) );

        mz2 = dot(z,z);
        if(mz2>4.0) break;
    }
    //return length(pos) -.25;
     return 0.25*sqrt(mz2/md2)*log(mz2);
}

float fMandelbulb(float3 p, float3 pars = float3(64, 16, 8), uint iter = 32)
{	
	float a = 1;
    float3 w = p;
    float m = dot(w,w);
    float4 trap = float4(abs(w),m);
   	float dz = a;
    
	for( uint i=0; i<iter; i++ )
    {
        float m2 = m*m;
        float m4 = m2*m2;
		dz = 8.0*sqrt(m4*m2*m)*dz + 1.0;

        float x = w.x; float x2 = x*x; float x4 = x2*x2;
        float y = w.y; float y2 = y*y; float y4 = y2*y2;
        float z = w.z; float z2 = z*z; float z4 = z2*z2;

        float k3 = x2 + z2;
        float k2 = rsqrt( k3*k3*k3*k3*k3*k3*k3 );
        float k1 = x4 + y4 + z4 - 6.0*y2*z2 - 6.0*x2*y2 + 2.0*z2*x2;
        float k4 = x2 - y2 + z2;

        w.x = p.x +  pars.x *x*y*z*(x2-z2)*k4*(x4-6.0*x2*z2+z4)*k1*k2;
        w.y = p.y + -pars.y *y2*k3*k4*k4 + k1*k1;
        w.z = p.z +  -pars.z*y*k4*(x4*x4 - 28.0*x4*x2*z2 + 70.0*x4*z4 - 28.0*x2*z2*z4 + z4*z4)*k1*k2;

        trap = min( trap, float4(abs(w),m) );

        m = dot(w,w);
		if( m > 4.0 )
        break;
    }
    return abs(0.25*log(m)*sqrt(m)/dz);
}

float fKali(float3 pos, float3 pars = float3 (.2, 1.6, 0.5), uint iter = 3)
{	
	float minRad2 = clamp(pars.x, 1.0e-9, 1.0);
	float4 p = float4(pos,1);
	float4 p0 = p;  // p.w is the distance estimate
	for (uint i = 0; i < iter; i++)
	{
		p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;

		// sphere folding: 
		float r2 = dot(p.xyz, p.xyz);
		
		if (r2 < minRad2) p /= minRad2; 
			else if (r2 < 1.0) p /= r2;

		p *= clamp(max(minRad2/r2, minRad2), 0.0, 1.0);

		// scale, translate
		p = p*float4(pars.xxx, abs(pars.x)) / minRad2 + p0;
	}
	return abs((length(p.xyz) - pars.y) / p.w - pars.z);
}

float fKaliThorns(float3 p, float width=.12, float rotation = 1.8)
{	
	float dotp=dot(p,p);
	p=p/dotp;
	p=sin(p.xyz+float3(sin(1.+rotation)*2.,-rotation,-rotation*2.));
	float d=length(p.yz)-width;
	d=min(d,length(p.xz)-width);
	d=min(d,length(p.xy)-width);
	d=min(d,length(p*p*p)-width);
	return d*dotp;
}


///////////////////////////////////////////////////////////////////////////////////////
// Mandelbox Distance Estimator (Rrrola's version).
///////////////////////////////////////////////////////////////////////////////////////
#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif
float fMandelbox(float3 pos, float MinRad2, float Scale, float3 Trans, float3 Julia, float3 PYR, int Iterations = 16) 
{
	float4 p = float4(pos,1); 
	float4 p0 = float4(Julia,1);  // p.w is the distance estimate
	float4 scale = float4(Scale, Scale, Scale, abs(Scale)) / MinRad2;
	float absScalem1 = abs(Scale - 1.0);
	float AbsScaleRaisedTo1mIters = pow(abs(Scale), float(1-Iterations));
	float3x3 rot = rot3x3(PYR);
	
	for (int i=0; i<Iterations; i++) {
		p.xyz = mul(p.xyz, rot);
		p.xyz=abs(p.xyz)+Trans;
		float r2 = dot(p.xyz, p.xyz);
		p *= clamp(max(MinRad2/r2, MinRad2), 0.0, 1.0);  // dp3,div,max.sat,mul
		p = p*scale + p0;
	
	}
	return ((length(p.xyz) - absScalem1) / p.w - AbsScaleRaisedTo1mIters);
}
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Fractal Qube Ported from Fragmentarium 'BioCube' example by Darkbeam
///////////////////////////////////////////////////////////////////////////////////////
#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif
float fFractalQube(float3 p, float Scale, float3 Offset, float3 Offset2, float3 Rot, float Qube, int Iterations)
{
	float3x3 fracRotation1 = Scale * rot3x3(Rot);
	float t; 
	int n = 0;
    float scalep = 1;
	float3 z0 = p;
	p = abs(p);
       //z -= (1,1,1);
	if (p.y>p.x) p.xy = p.yx;
	if (p.z>p.x) p.xz = p.zx;
	if (p.y>p.x) p.xy = p.yx;
    float d = 1.0- p.x;
    p = z0;
	// Folds.
	//Dodecahedral
	while (n < Iterations) 
	{
		p = mul(p, fracRotation1);
		p = abs(p);
	    p -= Offset;
		if (p.y>p.x) p.xy = p.yx;
		if (p.z>p.x) p.xz = p.zx;
		if (p.y>p.x) p.xy = p.yx;
	    p -= Offset2;
		if (p.y>p.x) p.xy = p.yx;
		if (p.z>p.x) p.xz = p.zx;
		if (p.y>p.x) p.xy = p.yx;
	
		n++;  scalep *= Scale;
	    d = abs(min(Qube/n-d,(+p.x)/scalep));
	}
	return d;
}
///////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//                DOMAIN MANIPULATION OPERATORS
//
////////////////////////////////////////////////////////////////
//
// Conventions:
//
// Everything that modifies the domain is named pSomething.
//
// Many operate only on a subset of the three dimensions. For those,
// you must choose the dimensions that you want manipulated
// by supplying e.g. <p.x> or <p.zx>
//
// <inout p> is always the first argument and modified in place.
//
// Many of the operators partition space into cells. An identifier
// or cell index is returned, if possible. This return value is
// intended to be optionally used e.g. as a random seed to change
// parameters of the distance functions inside the cells.
//
// Unless stated otherwise, for cell index 0, <p> is unchanged and cells
// are centered on the origin so objects don't have to be moved to fit.
//
//
////////////////////////////////////////////////////////////////



// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout float2 p, float a) 
{
	p = cos(a)*p + sin(a)*float2(p.y, -p.x);
}

// Shortcut for 45-degrees rotation
void pR45(inout float2 p) 
{
	p = (p + float2(p.y, -p.x))*sqrt(0.5);
}

// Repeat space along one axis. Use like this to repeat along the x axis:
// <float cell = pMod1(p.x,5);> - using the return value is optional.
float pMod1(inout float p, float size) 
{
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	return c;
}

// Same, but mirror every second cell so they match at the boundaries
float pModMirror1(inout float p, float size) 
{
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize,size) - halfsize;
	p *= mod(c, 2.0)*2 - 1;
	return c;
}

// Repeat the domain only in positive direction. Everything in the negative half-space is unchanged.
float pModSingle1(inout float p, float size) 
{
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	if (p >= 0)
		p = mod(p + halfsize, size) - halfsize;
	return c;
}

// Repeat only a few times: from indices <start> to <stop> (similar to above, but more flexible)
float pModInterval1(inout float p, float size, float start, float stop) 
{
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p+halfsize, size) - halfsize;
	if (c > stop) { //yes, this might not be the best thing numerically.
		p += size*(c - stop);
		c = stop;
	}
	if (c <start) {
		p += size*(c - start);
		c = start;
	}
	return c;
}


// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout float2 p, float repetitions) 
{
	float angle = 2*PI/repetitions;
	float a = atan2(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = abs(a%angle) - angle/2.;
	p = float2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}

// Repeat in two dimensions
float2 pMod2(inout float2 p, float2 size) 
{
	float2 halfsize = size * 0.5;
	float2 c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	return c;
}

// Same, but mirror every second cell so all boundaries match
float2 pModMirror2(inout float2 p, float2 size) 
{
	float2 halfsize = size*0.5;
	float2 c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	p *= mod(c, 2) * 2 - 1;
	return c;
}

// Same, but mirror every second cell at the diagonal as well
float2 pModGrid2(inout float2 p, float2 size) 
{
	float2 halfsize = size*0.5;
	float2 c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	p *= mod(c, 2) * 2 - 1;
	p -= size/2;
	if (p.x > p.y) p.xy = p.yx;
	return floor(c/2);
}

// Repeat in three dimensions
float3 pMod3(inout float3 p, float3 size) 
{
	float3 halfsize = size*0.5;
	float3 c = floor((p + halfsize)/size);
	p = mod(p + size * 0.5, size) - size * 0.5;
	return c;
}

// Mirror at an axis-aligned plane which is at a specified distance <dist> from the origin.
float pMirror (inout float p, float dist) 
{
	float s = sgn(p);
	p = abs(p)-dist;
	return s;
}

// Mirror in both dimensions and at the diagonal, yielding one eighth of the space.
// translate by dist before mirroring.
float2 pMirrorOctant (inout float2 p, float2 dist) 
{
	float2 s = sgn(p);
	pMirror(p.x, dist.x);
	pMirror(p.y, dist.y);
	if (p.y > p.x)
		p.xy = p.yx;
	return s;
}

// Reflect space at a plane

float pReflect(inout float2 p, float2 planeNormal, float offset) 
{
	float t = dot(p, planeNormal)+offset;
	if (t < 0) {
		p = p - (2*t)*planeNormal;
	}
	return sgn(t);
}

float pReflect(inout float3 p, float3 planeNormal, float offset) 
{
	float t = dot(p, planeNormal)+offset;
	if (t < 0) {
		p = p - (2*t)*planeNormal;
	}
	return sgn(t);
}

// Convert to spherical coordinates.  Does not maintain correct distance!
float3 pCart2Polar (float3 p)
{
	float r = p.x * p.x + p.y * p.y + p.z * p.z;
	if (r > 0)
	{
		r = (sqrt(r));
		float pitch, yaw;
		pitch = asin(p.y/r) / TWOPI;
		yaw = 0;
		if (p.z != 0) yaw = atan2(-p.x, -p.z);
		else if (p.x > 0) yaw = -PI / 2;
        else yaw = PI / 2;
		yaw /=  TWOPI;
		return float3(yaw,pitch,r);		
	}
	else return 0;
};

// Convert to polar coordinates.  Does not maintain correct distance!
float2 pCart2Polar (float2 p)
{
	float r = p.x * p.x + p.y * p.y;
	if (r > 0)
	{
		r = sqrt(r);
		float yaw = 0;
		if (p.y != 0) yaw = atan2(-p.x, -p.y);
		else if (p.x > 0) yaw = -PI / 2;
        else yaw = PI / 2;
		yaw /=  TWOPI;
		return float2(yaw, r);		
	}
	else return 0;	
};


float3 pTwist(float3 p, float strength)
{
    float c = cos(strength * p.y);
    float s = sin(strength * p.y);
    float2x2  m = float2x2(c, s, -s, c);
    float3  q = float3(mul(p.xz, m), p.y);
    return q;
}


// Revolve a 2D signed distance field in to a third dimension
float2 pRevolution( in float3 p, float w )
{
    return float2( length(p.xz) - w, p.y );
}

// 	Elongate- strech a SDF primitive.  Should be used like so: 
//	float4 w = pElongate(p);
//	float Distance = SDF(w.xyz) + w.w;
float4 pElongate( in float3 p, in float3 h )
{
    //return float3( p-clamp(p,-h,h)); // faster, but produces zero in the interior elongated box
    float3 q = abs(p)-h;
    return float4( max(q,0.0), min(max(q.x,max(q.y,q.z)),0.0) );
}
////////////////////////////////////////////////////////////////
//
//             OBJECT COMBINATION OPERATORS
//
////////////////////////////////////////////////////////////////




// Create double sided surface at boundry
float fOpOutline(float d, float radius)
{
	return abs(d) - radius;
}

// The "Chamfer" flavour makes a 45-degree chamfered edge (the diagonal of a square of size <r>):
float fOpUnionChamfer(float a, float b, float r) 
{
	return min(min(a, b), (a - r + b)*sqrt(0.5));
}

// Intersection has to deal with what is normally the inside of the resulting object
// when using union, which we normally don't care about too much. Thus, intersection
// implementations sometimes differ from union implementations.
float fOpIntersectionChamfer(float a, float b, float r) 
{
	return max(max(a, b), (a + r + b)*sqrt(0.5));
}

// Difference can be built from Intersection or Union:
float fOpDifferenceChamfer (float a, float b, float r) 
{
	return fOpIntersectionChamfer(a, -b, r);
}

// The "Round" variant uses a quarter-circle to join the two objects smoothly:
float fOpUnionRound(float a, float b, float r) 
{
	float2 u = max(float2(r - a,r - b), 0);
	return max(r, min (a, b)) - length(u);
}

float fOpIntersectionRound(float a, float b, float r) 
{
	float2 u = max(float2(r + a,r + b), 0);
	return min(-r, max (a, b)) + length(u);
}

float fOpDifferenceRound (float a, float b, float r) 
{
	return fOpIntersectionRound(a, -b, r);
}
// extrude (aka limit) 2D distance field in third dimension
float fOpExtrude(float p, float d, float depth)
{
	return I(abs(p-depth*.5)-depth, d);
}

float fOpExtrudeChamfer(float p, float d, float depth, float r)
{
	return fOpIntersectionChamfer(abs(p)-depth, d, r);
}

float fOpExtrudeRound(float p, float d, float depth, float r)
{
	return fOpIntersectionRound(abs(p)-depth, d, r);
}





// The "Columns" flavour makes n-1 circular columns at a 45 degree angle:
float fOpUnionColumns(float a, float b, float r, float n) 
{
	if ((a < r) && (b < r)) {
		float2 p = float2(a, b);
		float columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));
		pR45(p);
		p.x -= sqrt(2)/2*r;
		p.x += columnradius*sqrt(2);
		if (abs(n%2) == 1) {
			p.y += columnradius;
		}
		// At this point, we have turned 45 degrees and moved at a point on the
		// diagonal that we want to place the columns on.
		// Now, repeat the domain along this direction and place a circle.
		pMod1(p.y, columnradius*2);
		float result = length(p) - columnradius;
		result = min(result, p.x);
		result = min(result, a);
		return min(result, b);
	} else {
		return min(a, b);
	}
}

float fOpDifferenceColumns(float a, float b, float r, float n) 
{
	a = -a;
	float m = min(a, b);
	//avoid the expensive computation where not needed (produces discontinuity though)
	if ((a < r) && (b < r)) {
		float2 p = float2(a, b);
		float columnradius = r*sqrt(2)/n/2.0;
		columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));

		pR45(p);
		p.y += columnradius;
		p.x -= sqrt(2)/2*r;
		p.x += -columnradius*sqrt(2)/2;

		if (abs(n%2) == 1) {
			p.y += columnradius;
		}
		pMod1(p.y,columnradius*2);

		float result = -length(p) + columnradius;
		result = max(result, p.x);
		result = min(result, a);
		return -min(result, b);
	} else {
		return -m;
	}
}

float fOpIntersectionColumns(float a, float b, float r, float n) 
{
	return fOpDifferenceColumns(a,-b,r, n);
}

// The "Stairs" flavour produces n-1 steps of a staircase:
// much less stupid version by paniq
float fOpUnionStairs(float a, float b, float r, float n) 
{
	float s = r/n;
	float u = b-r;
	return min(min(a,b), 0.5 * (u + a + abs (( abs((u - a + s) % (2 * s))) - s)));
}

// We can just call Union since stairs are symmetric.
float fOpIntersectionStairs(float a, float b, float r, float n) 
{
	return -fOpUnionStairs(-a, -b, r, n);
}

float fOpDifferenceStairs(float a, float b, float r, float n) 
{
	return -fOpUnionStairs(-a, b, r, n);
}


// Similar to fOpUnionRound, but more lipschitz-y at acute angles
// (and less so at 90 degrees). Useful when fudging around too much
// by MediaMolecule, from Alex Evans' siggraph slides
float fOpUnionSoft(float a, float b, float r) 
{
	float e = max(r - abs(a - b), 0);
	return min(a, b) - e*e*0.25/r;
}


// produces a cylindical pipe that runs along the intersection.
// No objects remain, only the pipe. This is not a boolean operator.
float fOpPipe(float a, float b, float r) 
{
	return length(float2(a, b)) - r;
}

// first object gets a v-shaped engraving where it intersect the second
float fOpEngrave(float a, float b, float r)
 {
	return max(a, (a + r - abs(b))*sqrt(0.5));
}

// first object gets a capenter-style groove cut out
float fOpGroove(float a, float b, float ra, float rb)
{
	return max(a, min(a + ra, rb - abs(b)));
}

// first object gets a capenter-style tongue attached
float fOpTongue(float a, float b, float ra, float rb) 
{
	return min(a, max(a - ra, abs(b) - rb));
}

////////////////////////////////////////////////////////////////
//
//             COMPOUND OBJECTS 
//
////////////////////////////////////////////////////////////////


float fBoxGrid (float2 p, float r, float spacing = 1)
{
	float2 cell = pMod2(p, spacing);
	return min(abs(p.x)-r,  abs(p.y)-r);
	//return min(fBox(p.yx, float2(r,spacing/2)),  fBox(p.xy, float2(r,spacing/2)));
	
}

float fBoxGrid (float3 p, float r, float spacing)
{
	float3 bCell = pMod3(p, spacing);
	float b = fBox(p, float3(r,2000,r));
	b = min(b,  fBox(p.xzy, float3(r,2000,r)));
	b = min(b,  fBox(p.yxz, float3(r,2000,r)));
	return b;
}

float fTriangleGrid (float2 p, float r, float spacing = 1)
{
	p.x *= 5./3.; // slightly breaking the distance, but makes nice triangles
	pR45(p);
	p+=500;  // just hack to avoid artifacts at 0
	float2 cell = pMod2(p, spacing);
	float t1 = fTriangle(p, float2(-.5,-.5), float2(-.5,.5), float2(.5,-.5) );
	float t2 = fTriangle(p, float2(-.5,.5), float2(.5,.5), float2(.5,-.5) ) ;
	return fOpOutline(min(t1,  t2), r);
	
}

// IQ's hexagon code, with a bit of Fabrice's lerped in. Not optimized yet.
//distance to border, distance to nearest center, 2d cell id.
float4 fHexGrid( float2 p, float r ) 
{
	p = abs(p);
	float2 h = float2(p.x + p.y*.57735, p.y*1.1547);

	float2 pi = floor(h);
	float2 pf = h - pi;

    // Determining the nearest hexagonal border distance.
	float v = frac((pi.x + pi.y)/3.)*3.;
	float ca = step(1., v);
	float cb = step(2., v);
	float2  ma = step(pf, pf.yx);
	
    // Distance to border. Point to a line tends to involve a dot product.
	float e = dot( ma, 1.0-pf.yx + ca*(pf.x+pf.y-1.0) + cb*(pf.yx-2.0*pf.xy) );
    
    // Closest hexagon center.
    float2 f = frac(h); h -= f;
    float m = frac((h.x + h.y)/3.);
    h = m<.666 ?   m<.333 ?  h  :  h + 1.  :  h  + step(f.yx, f); 
    p -= float2(h.x - h.y*.5, h.y*.866);
	
    //distance to border, distance to nearest center, 2d cell id.
	return float4(e-r, length(p)-r, pi + ca - cb*ma);
}


// sample 3D distance field texture
float fDistVolume (float3 p, Texture3D dfTex, SamplerState s, float4x4 invMat ={ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 }, bool repeat = false)
{
	float margin = 0.05;
	//float scale = length(float3(invMat._11, invMat._12, invMat._13)) ;   // just get the X scale, scaling must be uniform
	// max scale component
	float scale = vmax(float3(length(float3(invMat._11, invMat._12, invMat._13)), length(float3(invMat._21, invMat._22, invMat._23)), length(float3(invMat._31, invMat._32, invMat._33)))) ;

	float3 pos = mul(float4(p,1), invMat).xyz;
	
	if(repeat) return dfTex.SampleLevel(s, pos+.5, 0).x / scale;
	
	float bounds = .5;
	float boundsCheck = vmax(abs(pos)) - bounds + margin;
	if (boundsCheck < margin) return dfTex.SampleLevel(s, pos+.5, 0).x / scale;
	return (boundsCheck + margin) / scale;
}


// sample 2D distance field texture
float fDistTexture (float2 p, Texture2D dfTex, SamplerState s, float4x4 invMat ={ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 })
{
	float margin = 0.05;
	//float scale = length(float2(invMat._11, invMat._12)) ;   // just get the X scale, scaling must be uniform
	// max scale component
	float scale = vmax(float2(length(float2(invMat._11, invMat._12)), length(float2(invMat._21, invMat._22))));
	float bounds = .5; // for scaled test box
	float2 pos = mul(float4(p, 0, 1), invMat).xy;
	float boundsCheck = vmax(abs(pos)) - bounds + margin;
	if (boundsCheck < margin) return dfTex.SampleLevel(s, pos * float2(1,-1) +.5, 0).x / scale;
	return boundsCheck + margin / scale;
}


////////////////////////////////////////////////////////////////
//EOF
