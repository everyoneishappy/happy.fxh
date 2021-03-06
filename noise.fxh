////////////////////////////////////////////////////////////////
//
//          CCBY 2017 everyoneishappy.com
//
////////////////////////////////////////////////////////////////

#define NOISE_FXH


#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh> // used for gradient ops
#endif

/* 

/////////////////////////////////////////////////////////////////////////////
//
//          USAGE
//
/////////////////////////////////////////////////////////////////////////////
	
	basis functions include:

		sine
		valueNoise 
		perlin 
		simplex
		worleyFast 
		worley
			
	they can be used like this:

		float [basis] (float2 p)		// 2D scalar noise
		float [basis] (float3 p)		// 3D scalar noise

		float2 [basis]2 (float2 p)		// 2D vector noise
		float3 [basis]3 (float3 p)		// 3D vector noise

		float3 [basis]DFV float3(p)		// return a divergence-free 3D vector field (DFV) of the noise

		float3 [basis]Grad (float2 p)	// 2D scalar noise as .x and gradient returned as .yz
		float4 [basis]Grad (float3 p)	// 3D scalar noise as .x and gradient returned as .yzw

		float2 [basis]Grad2 (float2 p, out float2 gradX, out float2 gradY) // 2D vector noise and X,Y gradients
		float3 [basis]Grad3 (float3 p, out float3 gradX, out float3 gradY, out float3 gradZ) // 3D vector noise and X,Y,Z gradients


	worley functions can also have thier signature extended for more options
		eg: worley(p, cellDistance, cellFunction)

	distance metrics include:
		EuclideanSquared
		Euclidean
		Chebyshev
		Manhattan
		Minkowski
		Cubes


	Cell functions include:
		F1
		F2
		F2MinusF1
		F1PlusF2
		Average
		Crackle

	instances are already made for each, so you canjust write the name, or use an interface as a selector:
	  	iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski,Cubes";>;
	  	iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,F1PlusF2,Average,Crackle";>;

*/


/////////////////////////////////////////////////////////////////////////////
//
//          Common FBM Parameters helper macro
//
/////////////////////////////////////////////////////////////////////////////
#define FBMPARS(name)           \
float name##Frequency = 1;      \
float name##Persistence = 0.5;  \
float name##Lacunarity  = 2;    \
int name##Octaves = 4;          
#define FBMARGS(name) name##Frequency, name##Persistence, name##Lacunarity, name##Octaves
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
//
//          2D and 3D vector helper macros
//
/////////////////////////////////////////////////////////////////////////////

// domain offset defualts for calling the same function is several places
#ifndef NOISEOFFSETS
#define NOISEOFFSETS float2(67, 197)
#endif

// takes a scalar function FUNCTIONNAME and defines a new function returning 2D vector called [FUNCTIONNAME]2
#define NOISE2DVECTORFUNCTION(FUNCTIONNAME)                                             \
float2 FUNCTIONNAME##2(float2 p)                                                        \
{return float2(FUNCTIONNAME(p), FUNCTIONNAME (p+NOISEOFFSETS.x));};                 
                                                                                        
// takes a scalar function FUNCTIONNAME and defines a new function returning 2D vector & gradients called [FUNCTIONNAME]2
#define NOISE2DVECTORGRADFUNCTION(FUNCTIONNAME)                                         \
float2 FUNCTIONNAME##2(float2 p, out float2 gradX, out float2 gradY)                    \
{                                                                                       \
    float3 nx = FUNCTIONNAME(p);                                                        \
    float3 ny = FUNCTIONNAME(p+NOISEOFFSETS.x);                                         \
    gradX = nx.yz;                                                                      \
    gradY = ny.yz;                                                                      \
    return float2(nx.x, ny.x);                                                          \
};

// takes a scalar function FUNCTIONNAME and defines a new function returning 3D vector called [FUNCTIONNAME]3
#define NOISE3DVECTORFUNCTION(FUNCTIONNAME)                                             \
float3 FUNCTIONNAME##3(float3 p)                                                        \
{return float3(FUNCTIONNAME(p), FUNCTIONNAME (p+NOISEOFFSETS.x), FUNCTIONNAME(p+NOISEOFFSETS.y));};                 
                                                                                        
// takes a scalar function FUNCTIONNAME and defines a new function returning 3D vector & gradients called [FUNCTIONNAME]3
#define NOISE3DVECTORGRADFUNCTION(FUNCTIONNAME)                                         \
float3 FUNCTIONNAME##3(float3 p, out float3 gradX, out float3 gradY, out float3 gradZ)  \
{                                                                                       \
    float4 nx = FUNCTIONNAME(p);                                                        \
    float4 ny = FUNCTIONNAME(p+NOISEOFFSETS.x);                                         \
    float4 nz = FUNCTIONNAME(p+NOISEOFFSETS.y);                                         \
    gradX = nx.yzw;                                                                     \
    gradY = ny.yzw;                                                                     \
    gradZ = nz.yzw;                                                                     \
    return float3(nx.x, ny.x, nz.x);                                                    \
};

//###############################################################################
// Hash without Sine
// Creative Commons Attribution-ShareAlike 4.0 International Public License
// Created by David Hoskins.

// https://www.shadertoy.com/view/4djSRW
//----------------------------------------------------------------------------------------
//  1 out, 1 in...
float hash11(float p)
{
    p = frac(p * .1031);
    p *= p + 19.19;
    p *= p + p;
    return frac(p);
}

//----------------------------------------------------------------------------------------
//  1 out, 2 in...
float hash12(float2 p)
{
    float3 p3  = frac(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
//  1 out, 3 in...
float hash13(float3 p3)
{
    p3  = frac(p3 * .1031);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
//  2 out, 1 in...
float2 hash21(float p)
{
    float3 p3 = frac(float3(p.xxx) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.xx+p3.yz)*p3.zy);

}

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
float2 hash22(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return frac((p3.xx+p3.yz)*p3.zy);

}

//----------------------------------------------------------------------------------------
///  2 out, 3 in...
float2 hash23(float3 p3)
{
    p3 = frac(p3 * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return frac((p3.xx+p3.yz)*p3.zy);
}

//----------------------------------------------------------------------------------------
//  3 out, 1 in...
float3 hash31(float p)
{
   float3 p3 = frac(float3(p.xxx) * float3(.1031, .1030, .0973));
   p3 += dot(p3, p3.yzx+19.19);
   return frac((p3.xxy+p3.yzz)*p3.zyx); 
}


//----------------------------------------------------------------------------------------
///  3 out, 2 in...
float3 hash32(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+19.19);
    return frac((p3.xxy+p3.yzz)*p3.zyx);
}

//----------------------------------------------------------------------------------------
///  3 out, 3 in...
float3 hash33(float3 p3)
{
    p3 = frac(p3 * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+19.19);
    return frac((p3.xxy + p3.yxx)*p3.zyx);

}

//----------------------------------------------------------------------------------------
// 4 out, 1 in...
float4 hash41(float p)
{
    float4 p4 = frac(float4(p.xxxx) * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy+19.19);
    return frac((p4.xxyz+p4.yzzw)*p4.zywx);
    
}

//----------------------------------------------------------------------------------------
// 4 out, 2 in...
float4 hash42(float2 p)
{
    float4 p4 = frac(float4(p.xyxy) * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy+19.19);
    return frac((p4.xxyz+p4.yzzw)*p4.zywx);

}

//----------------------------------------------------------------------------------------
// 4 out, 3 in...
float4 hash43(float3 p)
{
    float4 p4 = frac(float4(p.xyzx)  * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy+19.19);
    return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}

//----------------------------------------------------------------------------------------
// 4 out, 4 in...
float4 hash44(float4 p4)
{
    p4 = frac(p4  * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy+19.19);
    return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}

//----------------------------------------------------------------------------------------
//###############################################################################


////////////////////////////////////////////////////////////////
//
//             Random Noise Basis 
//
////////////////////////////////////////////////////////////////
#ifndef RANDOM_ITERATIONS
#define RANDOM_ITERATIONS 4
#endif
float random (float2 p)
{
    float a = 0.0;
    for (int t = 0; t < RANDOM_ITERATIONS; t++)
    {
        float v = float(t+1)*.152;
        float2 pos = (p.xy * v * 1500. + 50.);
        
        float3 p3  = frac(float3(pos.xyx) * .1031);
        p3 += dot(p3, p3.yzx + 19.19);
        a += frac((p3.x + p3.y) * p3.z);
        
    }
    return a / float(RANDOM_ITERATIONS);
}

float random (float3 p)
{
    float a = 0.0;
    for (int t = 0; t < RANDOM_ITERATIONS; t++)
    {
        float v = float(t+1)*.132;
        float3 pos = (p * v * 1500.  + 50.0);
        
    float3 p3 = frac(pos * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+19.19);
    a += frac((p3.x + p3.y) * p3.z);
        
    }
    return a / float(RANDOM_ITERATIONS);
}

//gradient functions are just random, for random, man
NOISE2DVECTORFUNCTION(random)
//NOISE2DVECTORGRADFUNCTION(valueNoiseGrad)
NOISE3DVECTORFUNCTION(random)
//NOISE3DVECTORGRADFUNCTION(valueNoiseGrad)


// return a divergence-free 3D vector field (DFV)
float3 randomDFV(float3 p, float offset = 67)
{
    //float4 n1 = valueNoiseGrad(p);
    //float4 n2 = valueNoiseGrad(p+offset);
    //return cross(n1.yzw, n2.yzw);
    return random3(p);
}


////////////////////////////////////////////////////////////////
//
//             Noise Basis Functions
// textureless basis functions below mostly from https://github.com/BrianSharpe/Wombat/
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             Value Noise Basis 
//
////////////////////////////////////////////////////////////////

//2D
float valueNoise(float2 p)
{
    //  establish our grid cell and unit position
    float2 Pi = floor(p);
    float2 Pf = p - Pi;

    //  calculate the hash.
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash = frac( Pt * ( 1.0 / 951.135664 ) );

    //  blend the results and return
    float2 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float4 blend2 = float4( blend, float2( 1.0 - blend ) );
    return dot( hash, blend2.zxzx * blend2.wwyy );
}

//2D w/ gradient
float3 valueNoiseGrad(float2 p)
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Value2D_Deriv.glsl

    //  establish our grid cell and unit position
    float2 Pi = floor(p);
    float2 Pf = p - Pi;

    //  calculate the hash.
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash = frac( Pt * ( 1.0 / 951.135664 ) );

    //  blend the results and return
    float4 blend = Pf.xyxy * Pf.xyxy * ( Pf.xyxy * ( Pf.xyxy * ( Pf.xyxy * float2( 6.0, 0.0 ).xxyy + float2( -15.0, 30.0 ).xxyy ) + float2( 10.0, -60.0 ).xxyy ) + float2( 0.0, 30.0 ).xxyy );
    float4 res0 = lerp( hash.xyxz, hash.zwyw, blend.yyxx );
    return float3( res0.x, 0.0, 0.0 ) + ( res0.yyw - res0.xxz ) * blend.xzw;
}

//3D
float valueNoise(float3 p)
{
    // establish our grid cell and unit position
    float3 Pi = floor(p);
    float3 Pf = p - Pi;
    float3 Pf_min1 = Pf - 1.0;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, ( 69.0 - 1.5 ) ) * ( Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float2 hash_mod = float2( 1.0 / ( 635.298681 + float2( Pi.z, Pi_inc1.z ) * 48.500388 ) );
    float4 hash_lowz = frac( Pt * hash_mod.xxxx );
    float4 hash_highz = frac( Pt * hash_mod.yyyy );

    //  blend the results and return
    float3 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float4 res0 = lerp( hash_lowz, hash_highz, blend.z );
    float4 blend2 = float4( blend.xy, float2( 1.0 - blend.xy ) );
    return dot( res0, blend2.zxzx * blend2.wwyy );
}

//3D w/ gradient
float4 valueNoiseGrad(float3 p)
{
    // establish our grid cell and unit position
    float3 Pi = floor(p);
    float3 Pf = p - Pi;
    float3 Pf_min1 = Pf - 1.0;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, ( 69.0 - 1.5 ) ) * ( Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float2 hash_mod = float2( 1.0 / ( 635.298681 + float2( Pi.z, Pi_inc1.z ) * 48.500388 ) );
    float4 hash_lowz = frac( Pt * hash_mod.xxxx );
    float4 hash_highz = frac( Pt * hash_mod.yyyy );

    //  blend the results and return
    float3 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float3 blendDeriv = Pf * Pf * (Pf * (Pf * 30.0 - 60.0) + 30.0);
    float4 res0 = lerp( hash_lowz, hash_highz, blend.z );
    float4 res1 = lerp( res0.xyxz, res0.zwyw, blend.yyxx );
    float4 res3 = lerp( float4( hash_lowz.xy, hash_highz.xy ), float4( hash_lowz.zw, hash_highz.zw ), blend.y );
    float2 res4 = lerp( res3.xz, res3.yw, blend.x );
    return float4( res1.x, 0.0, 0.0, 0.0 ) + ( float4( res1.yyw, res4.y ) - float4( res1.xxz, res4.x ) ) * float4( blend.x, blendDeriv );
}

NOISE2DVECTORFUNCTION(valueNoise)
NOISE2DVECTORGRADFUNCTION(valueNoiseGrad)
NOISE3DVECTORFUNCTION(valueNoise)
NOISE3DVECTORGRADFUNCTION(valueNoiseGrad)

// return a divergence-free 3D vector field (DFV)
float3 valueNoiseDFV(float3 p, float offset = 67)
{
    float4 n1 = valueNoiseGrad(p);
    float4 n2 = valueNoiseGrad(p+offset);
    return cross(n1.yzw, n2.yzw);
}
////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////
//
//             Perlin Basis 
//
////////////////////////////////////////////////////////////////
#define SOMELARGEFLOATS float3( 635.298681, 682.357502, 668.926525 )
#define ZINC float3( 48.500388, 65.294118, 63.934599 )
//2D
float perlin(float2 p)
{
    // establish our grid cell and unit position
    float2 Pi = floor(p);
    float4 Pf_Pfmin1 = p.xyxy - float4( Pi, Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    // calculate the gradient results
    float4 grad_x = hash_x - 0.49999;
    float4 grad_y = hash_y - 0.49999;
    float4 grad_results = rsqrt( grad_x * grad_x + grad_y * grad_y ) * ( grad_x * Pf_Pfmin1.xzxz + grad_y * Pf_Pfmin1.yyww );

    // Classic Perlin Interpolation
    grad_results *= 1.4142135623730950488016887242097;  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.5)
    float2 blend = Pf_Pfmin1.xy * Pf_Pfmin1.xy * Pf_Pfmin1.xy * (Pf_Pfmin1.xy * (Pf_Pfmin1.xy * 6.0 - 15.0) + 10.0);
    float4 blend2 = float4( blend, float2( 1.0 - blend ) );
    return dot( grad_results, blend2.zxzx * blend2.wwyy );
}


//2D w/ gradient
float3 perlinGrad(float2 p )
{
    // establish our grid cell and unit position
    float2 Pi = floor(p);
    float4 Pf_Pfmin1 = p.xyxy - float4( Pi, Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    // calculate the gradient results
    float4 grad_x = hash_x - 0.49999;
    float4 grad_y = hash_y - 0.49999;
    float4 norm = rsqrt( grad_x * grad_x + grad_y * grad_y );
    grad_x *= norm;
    grad_y *= norm;
    float4 dotval = ( grad_x * Pf_Pfmin1.xzxz + grad_y * Pf_Pfmin1.yyww );

    //  C2 Interpolation
    float4 blend = Pf_Pfmin1.xyxy * Pf_Pfmin1.xyxy * ( Pf_Pfmin1.xyxy * ( Pf_Pfmin1.xyxy * ( Pf_Pfmin1.xyxy * float2( 6.0, 0.0 ).xxyy + float2( -15.0, 30.0 ).xxyy ) + float2( 10.0, -60.0 ).xxyy ) + float2( 0.0, 30.0 ).xxyy );

    //  Convert our data to a more parallel format
    float3 dotval0_grad0 = float3( dotval.x, grad_x.x, grad_y.x );
    float3 dotval1_grad1 = float3( dotval.y, grad_x.y, grad_y.y );
    float3 dotval2_grad2 = float3( dotval.z, grad_x.z, grad_y.z );
    float3 dotval3_grad3 = float3( dotval.w, grad_x.w, grad_y.w );

    //  evaluate common constants
    float3 k0_gk0 = dotval1_grad1 - dotval0_grad0;
    float3 k1_gk1 = dotval2_grad2 - dotval0_grad0;
    float3 k2_gk2 = dotval3_grad3 - dotval2_grad2 - k0_gk0;

    //  calculate final noise + deriv
    float3 results = dotval0_grad0
                    + blend.x * k0_gk0
                    + blend.y * ( k1_gk1 + blend.x * k2_gk2 );
    results.yz += blend.zw * ( float2( k0_gk0.x, k1_gk1.x ) + blend.yx * k2_gk2.xx );
    return results * 1.4142135623730950488016887242097;  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.5)
}

// 3D
float perlin(float3 p)
{
    // establish our grid cell and unit position
    float3 Pi = floor(p);
    float3 Pf = p - Pi;
    float3 Pf_min1 = Pf - 1.0;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hashx0 = frac( Pt * lowz_mod.xxxx );
    float4 hashx1 = frac( Pt * highz_mod.xxxx );
    float4 hashy0 = frac( Pt * lowz_mod.yyyy );
    float4 hashy1 = frac( Pt * highz_mod.yyyy );
    float4 hashz0 = frac( Pt * lowz_mod.zzzz );
    float4 hashz1 = frac( Pt * highz_mod.zzzz );

    // calculate the gradients
    float4 grad_x0 = hashx0 - 0.49999;
    float4 grad_y0 = hashy0 - 0.49999;
    float4 grad_z0 = hashz0 - 0.49999;
    float4 grad_x1 = hashx1 - 0.49999;
    float4 grad_y1 = hashy1 - 0.49999;
    float4 grad_z1 = hashz1 - 0.49999;
    float4 grad_results_0 = rsqrt( grad_x0 * grad_x0 + grad_y0 * grad_y0 + grad_z0 * grad_z0 ) * ( float2( Pf.x, Pf_min1.x ).xyxy * grad_x0 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y0 + Pf.zzzz * grad_z0 );
    float4 grad_results_1 = rsqrt( grad_x1 * grad_x1 + grad_y1 * grad_y1 + grad_z1 * grad_z1 ) * ( float2( Pf.x, Pf_min1.x ).xyxy * grad_x1 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y1 + Pf_min1.zzzz * grad_z1 );

    // Classic Perlin Interpolation
    float3 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float4 res0 = lerp( grad_results_0, grad_results_1, blend.z );
    float4 blend2 = float4( blend.xy, float2( 1.0 - blend.xy ) );
    float final = dot( res0, blend2.zxzx * blend2.wwyy );
    
    return ( final * 1.1547005383792515290182975610039);  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.75)
}

// 3D w/ gradient
float4 perlinGrad(float3 p)
{
    // establish our grid cell and unit position
    float3 Pi = floor(p);
    float3 Pf = p - Pi;
    float3 Pf_min1 = Pf - 1.0;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;

    
    
    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hashx0 = frac( Pt * lowz_mod.xxxx );
    float4 hashx1 = frac( Pt * highz_mod.xxxx );
    float4 hashy0 = frac( Pt * lowz_mod.yyyy );
    float4 hashy1 = frac( Pt * highz_mod.yyyy );
    float4 hashz0 = frac( Pt * lowz_mod.zzzz );
    float4 hashz1 = frac( Pt * highz_mod.zzzz );

    //  calculate the gradients
    float4 grad_x0 = hashx0 - 0.49999;
    float4 grad_y0 = hashy0 - 0.49999;
    float4 grad_z0 = hashz0 - 0.49999;
    float4 grad_x1 = hashx1 - 0.49999;
    float4 grad_y1 = hashy1 - 0.49999;
    float4 grad_z1 = hashz1 - 0.49999;
    float4 norm_0 = rsqrt( grad_x0 * grad_x0 + grad_y0 * grad_y0 + grad_z0 * grad_z0 );
    float4 norm_1 = rsqrt( grad_x1 * grad_x1 + grad_y1 * grad_y1 + grad_z1 * grad_z1 );
    grad_x0 *= norm_0;
    grad_y0 *= norm_0;
    grad_z0 *= norm_0;
    grad_x1 *= norm_1;
    grad_y1 *= norm_1;
    grad_z1 *= norm_1;

    //  calculate the dot products
    float4 dotval_0 = float2( Pf.x, Pf_min1.x ).xyxy * grad_x0 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y0 + Pf.zzzz * grad_z0;
    float4 dotval_1 = float2( Pf.x, Pf_min1.x ).xyxy * grad_x1 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y1 + Pf_min1.zzzz * grad_z1;

    //  C2 Interpolation
    float3 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float3 blendDeriv = Pf * Pf * (Pf * (Pf * 30.0 - 60.0) + 30.0);

    //  the following is based off Milo Yips derivation, but modified for parallel execution
    //  http://stackoverflow.com/a/14141774

    //  Convert our data to a more parallel format
    float4 dotval0_grad0 = float4( dotval_0.x, grad_x0.x, grad_y0.x, grad_z0.x );
    float4 dotval1_grad1 = float4( dotval_0.y, grad_x0.y, grad_y0.y, grad_z0.y );
    float4 dotval2_grad2 = float4( dotval_0.z, grad_x0.z, grad_y0.z, grad_z0.z );
    float4 dotval3_grad3 = float4( dotval_0.w, grad_x0.w, grad_y0.w, grad_z0.w );
    float4 dotval4_grad4 = float4( dotval_1.x, grad_x1.x, grad_y1.x, grad_z1.x );
    float4 dotval5_grad5 = float4( dotval_1.y, grad_x1.y, grad_y1.y, grad_z1.y );
    float4 dotval6_grad6 = float4( dotval_1.z, grad_x1.z, grad_y1.z, grad_z1.z );
    float4 dotval7_grad7 = float4( dotval_1.w, grad_x1.w, grad_y1.w, grad_z1.w );

    //  evaluate common constants
    float4 k0_gk0 = dotval1_grad1 - dotval0_grad0;
    float4 k1_gk1 = dotval2_grad2 - dotval0_grad0;
    float4 k2_gk2 = dotval4_grad4 - dotval0_grad0;
    float4 k3_gk3 = dotval3_grad3 - dotval2_grad2 - k0_gk0;
    float4 k4_gk4 = dotval5_grad5 - dotval4_grad4 - k0_gk0;
    float4 k5_gk5 = dotval6_grad6 - dotval4_grad4 - k1_gk1;
    float4 k6_gk6 = (dotval7_grad7 - dotval6_grad6) - (dotval5_grad5 - dotval4_grad4) - k3_gk3;

    //  calculate final noise + deriv
    float u = blend.x;
    float v = blend.y;
    float w = blend.z;
    float4 result = dotval0_grad0
        + u * ( k0_gk0 + v * k3_gk3 )
        + v * ( k1_gk1 + w * k5_gk5 )
        + w * ( k2_gk2 + u * ( k4_gk4 + v * k6_gk6 ) );
    result.y += dot( float4( k0_gk0.x, k3_gk3.x * v, float2( k4_gk4.x, k6_gk6.x * v ) * w ), float4( blendDeriv.xxxx ) );
    result.z += dot( float4( k1_gk1.x, k3_gk3.x * u, float2( k5_gk5.x, k6_gk6.x * u ) * w ), float4( blendDeriv.yyyy ) );
    result.w += dot( float4( k2_gk2.x, k4_gk4.x * u, float2( k5_gk5.x, k6_gk6.x * u ) * v ), float4( blendDeriv.zzzz ) );
    return result * 1.1547005383792515290182975610039;  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.75)
}


NOISE2DVECTORFUNCTION(perlin)
NOISE2DVECTORGRADFUNCTION(perlinGrad)
NOISE3DVECTORFUNCTION(perlin)
NOISE3DVECTORGRADFUNCTION(perlinGrad)

// return a divergence-free vector field (DFV) in 3D
float3 perlinDFV(float3 p, float offset = 67)
{
    float4 n1 = perlinGrad(p);
    float4 n2 = perlinGrad(p+offset);
    return cross(n1.yzw, n2.yzw);
}
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//             Simplex Basis 
//
////////////////////////////////////////////////////////////////
//2D
float simplex(float2 p)
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/SimplexPerlin2D.glsl

    //  simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;            // 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;          // (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;    // sqrt( 0.5 )  height of simplex triangle
    const float3 SIMPLEX_POINTS = float3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );  //  simplex triangle geo

    //  establish our grid cell.
    p *= SIMPLEX_TRI_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float2 Pi = floor( p + dot( p, float2( SKEWFACTOR.xx ) ) );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  establish floattors to the 3 corners of our simplex triangle
    float2 v0 = Pi - dot( Pi, float2( UNSKEWFACTOR.xx ) ) - p;
    float4 v1pos_v1hash = (v0.x < v0.y) ? float4(SIMPLEX_POINTS.xy, hash_x.y, hash_y.y) : float4(SIMPLEX_POINTS.yx, hash_x.z, hash_y.z);
    float4 v12 = float4( v1pos_v1hash.xy, SIMPLEX_POINTS.zz ) + v0.xyxy;

    //  calculate the dotproduct of our 3 corner floattors with 3 random normalized floattors
    float3 grad_x = float3( hash_x.x, v1pos_v1hash.z, hash_x.w ) - 0.49999;
    float3 grad_y = float3( hash_y.x, v1pos_v1hash.w, hash_y.w ) - 0.49999;
    float3 grad_results = rsqrt( grad_x * grad_x + grad_y * grad_y ) * ( grad_x * float3( v0.x, v12.xz ) + grad_y * float3( v0.y, v12.yw ) );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    const float FINAL_NORMALIZATION = 99.204334582718712976990005025589;

    //  evaluate and return
    float3 m = float3( v0.x, v12.xz ) * float3( v0.x, v12.xz ) + float3( v0.y, v12.yw ) * float3( v0.y, v12.yw );
    m = max(0.5 - m, 0.0);
    m = m*m;
    return dot(m*m, grad_results) * FINAL_NORMALIZATION;
}

//3D
float simplex(float3 p)
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/SimplexPerlin3D.glsl

    //  simplex math constants
    const float SKEWFACTOR = 1.0/3.0;
    const float UNSKEWFACTOR = 1.0/6.0;
    const float SIMPLEX_CORNER_POS = 0.5;
    const float SIMPLEX_TETRAHADRON_HEIGHT = 0.70710678118654752440084436210485 ;  // sqrt( 0.5 )

    //  establish our grid cell.
    p *= SIMPLEX_TETRAHADRON_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float3 Pi = floor( p + dot( p, SKEWFACTOR) );

    //  Find the vectors to the corners of our simplex tetrahedron
    float3 x0 = p - Pi + dot(Pi, UNSKEWFACTOR);
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 Pi_1 = min( g.xyz, l.zxy );
    float3 Pi_2 = max( g.xyz, l.zxy );
    float3 x1 = x0 - Pi_1 + UNSKEWFACTOR;
    float3 x2 = x0 - Pi_2 + SKEWFACTOR;
    float3 x3 = x0 - SIMPLEX_CORNER_POS;

    //  pack them into a parallel-friendly arrangement
    float4 v1234_x = float4( x0.x, x1.x, x2.x, x3.x );
    float4 v1234_y = float4( x0.y, x1.y, x2.y, x3.y );
    float4 v1234_z = float4( x0.z, x1.z, x2.z, x3.z );

    // clamp the domain of our grid cell
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    //  generate the random vectors
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    float4 V1xy_V2xy = lerp( Pt.xyxy, Pt.zwzw, float4( Pi_1.xy, Pi_2.xy ) );
    Pt = float4( Pt.x, V1xy_V2xy.xz, Pt.z ) * float4( Pt.y, V1xy_V2xy.yw, Pt.w );

    float3 lowz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi.zzz * ZINC.xyz ) );
    float3 highz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi_inc1.zzz * ZINC.xyz ) );
    Pi_1 = ( Pi_1.z < 0.5 ) ? lowz_mods : highz_mods;
    Pi_2 = ( Pi_2.z < 0.5 ) ? lowz_mods : highz_mods;
    float4 hash_0 = frac( Pt * float4( lowz_mods.x, Pi_1.x, Pi_2.x, highz_mods.x ) ) - 0.49999;
    float4 hash_1 = frac( Pt * float4( lowz_mods.y, Pi_1.y, Pi_2.y, highz_mods.y ) ) - 0.49999;
    float4 hash_2 = frac( Pt * float4( lowz_mods.z, Pi_1.z, Pi_2.z, highz_mods.z ) ) - 0.49999;

    //  evaluate gradients
    float4 grad_results = rsqrt( hash_0 * hash_0 + hash_1 * hash_1 + hash_2 * hash_2 ) * ( hash_0 * v1234_x + hash_1 * v1234_y + hash_2 * v1234_z );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
     const float  FINAL_NORMALIZATION =  37.837227241611314102871574478976;

    //  evaulate the kernel weights ( use (0.5-x*x)^3 instead of (0.6-x*x)^4 to fix discontinuities )
    float4 kernel_weights = v1234_x * v1234_x + v1234_y * v1234_y + v1234_z * v1234_z;
    kernel_weights = max(0.5 - kernel_weights, 0.0);
    kernel_weights = kernel_weights*kernel_weights*kernel_weights;

    //  sum with the kernel and return
    return dot( kernel_weights, grad_results ) * FINAL_NORMALIZATION;
}

//2D w/ gradient
float3 simplexGrad(float2 p)
{
    //  simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;            // 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;          // (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;    // sqrt( 0.5 )  height of simplex triangle
    const float3 SIMPLEX_POINTS = float3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );  //  simplex triangle geo

    //  establish our grid cell.
    p *= SIMPLEX_TRI_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float2 Pi = floor( p + dot( p, float2( SKEWFACTOR.xx ) ) );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  establish floattors to the 3 corners of our simplex triangle
    float2 v0 = Pi - dot( Pi, float2( UNSKEWFACTOR.xx ) ) - p;
    float4 v1pos_v1hash = (v0.x < v0.y) ? float4(SIMPLEX_POINTS.xy, hash_x.y, hash_y.y) : float4(SIMPLEX_POINTS.yx, hash_x.z, hash_y.z);
    float4 v12 = float4( v1pos_v1hash.xy, SIMPLEX_POINTS.zz ) + v0.xyxy;

    //  calculate the dotproduct of our 3 corner floattors with 3 random normalized floattors
    float3 grad_x = float3( hash_x.x, v1pos_v1hash.z, hash_x.w ) - 0.49999;
    float3 grad_y = float3( hash_y.x, v1pos_v1hash.w, hash_y.w ) - 0.49999;
    float3 norm = rsqrt( grad_x * grad_x + grad_y * grad_y );
    grad_x *= norm;
    grad_y *= norm;
    float3 grad_results = grad_x * float3( v0.x, v12.xz ) + grad_y * float3( v0.y, v12.yw );

    //  evaluate the kernel
    float3 m = float3( v0.x, v12.xz ) * float3( v0.x, v12.xz ) + float3( v0.y, v12.yw ) * float3( v0.y, v12.yw );
    m = max(0.5 - m, 0.0);
    float3 m2 = m*m;
    float3 m4 = m2*m2;

    //  calc the derivatives
    float3 temp = 8.0 * m2 * m * grad_results;
    float xderiv = dot( temp, float3( v0.x, v12.xz ) ) - dot( m4, grad_x );
    float yderiv = dot( temp, float3( v0.y, v12.yw ) ) - dot( m4, grad_y );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    const float FINAL_NORMALIZATION = 99.204334582718712976990005025589;

    //  sum and return all results as a float3
    return float3( dot( m4, grad_results ), xderiv, yderiv ) * FINAL_NORMALIZATION;
}

//3D w/ gradient
float4 simplexGrad(float3 p)
{
    const float SKEWFACTOR = 1.0/3.0;
    const float UNSKEWFACTOR = 1.0/6.0;
    const float SIMPLEX_CORNER_POS = 0.5;
    const float SIMPLEX_TETRAHADRON_HEIGHT = 0.70710678118654752440084436210485 ;  // sqrt( 0.5 )
    
    //  establish our grid cell.
    p *= SIMPLEX_TETRAHADRON_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float3 Pi = floor( p + dot( p, SKEWFACTOR) );

    //  Find the vectors to the corners of our simplex tetrahedron
    float3 x0 = p - Pi + dot(Pi, UNSKEWFACTOR);
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 Pi_1 = min( g.xyz, l.zxy );
    float3 Pi_2 = max( g.xyz, l.zxy );
    float3 x1 = x0 - Pi_1 + UNSKEWFACTOR;
    float3 x2 = x0 - Pi_2 + SKEWFACTOR;
    float3 x3 = x0 - SIMPLEX_CORNER_POS;

    //  pack them into a parallel-friendly arrangement
    float4 v1234_x = float4( x0.x, x1.x, x2.x, x3.x );
    float4 v1234_y = float4( x0.y, x1.y, x2.y, x3.y );
    float4 v1234_z = float4( x0.z, x1.z, x2.z, x3.z );

    // clamp the domain of our grid cell
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step(Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    //  generate the random vectors
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    float4 V1xy_V2xy = lerp( Pt.xyxy, Pt.zwzw, float4( Pi_1.xy, Pi_2.xy ) );
    Pt = float4( Pt.x, V1xy_V2xy.xz, Pt.z ) * float4( Pt.y, V1xy_V2xy.yw, Pt.w );
    float3 lowz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi.zzz * ZINC.xyz ) );
    float3 highz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi_inc1.zzz * ZINC.xyz ) );
    Pi_1 = ( Pi_1.z < 0.5 ) ? lowz_mods : highz_mods;
    Pi_2 = ( Pi_2.z < 0.5 ) ? lowz_mods : highz_mods;
    float4 hash_0 = frac( Pt * float4( lowz_mods.x, Pi_1.x, Pi_2.x, highz_mods.x ) ) - 0.49999;
    float4 hash_1 = frac( Pt * float4( lowz_mods.y, Pi_1.y, Pi_2.y, highz_mods.y ) ) - 0.49999;
    float4 hash_2 = frac( Pt * float4( lowz_mods.z, Pi_1.z, Pi_2.z, highz_mods.z ) ) - 0.49999;

    //  normalize random gradient vectors
    float4 norm = rsqrt( hash_0 * hash_0 + hash_1 * hash_1 + hash_2 * hash_2 );
    hash_0 *= norm;
    hash_1 *= norm;
    hash_2 *= norm;

    //  evaluate gradients
    float4 grad_results = hash_0 * v1234_x + hash_1 * v1234_y + hash_2 * v1234_z;

    //  evaulate the kernel weights ( use (0.5-x*x)^3 instead of (0.6-x*x)^4 to fix discontinuities )
    float4 m = v1234_x * v1234_x + v1234_y * v1234_y + v1234_z * v1234_z;
    m = max(0.5 - m, 0.0);
    float4 m2 = m*m;
    float4 m3 = m*m2;

    //  calc the derivatives
    float4 temp = -6.0 * m2 * grad_results;
    float xderiv = dot( temp, v1234_x ) + dot( m3, hash_0 );
    float yderiv = dot( temp, v1234_y ) + dot( m3, hash_1 );
    float zderiv = dot( temp, v1234_z ) + dot( m3, hash_2 );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    const float  FINAL_NORMALIZATION =  37.837227241611314102871574478976;

    //  sum and return all results as a float3
    return float4( dot( m3, grad_results ), xderiv, yderiv, zderiv ) * FINAL_NORMALIZATION;
}

NOISE2DVECTORFUNCTION(simplex)
NOISE2DVECTORGRADFUNCTION(simplexGrad)
NOISE3DVECTORFUNCTION(simplex)
NOISE3DVECTORGRADFUNCTION(simplexGrad)

// return a divergence-free vector field (DFV)
float3 simplexDFV(float3 p, float offset = 67)
{
    float4 n1 = simplexGrad(p);
    float4 n2 = simplexGrad(p+offset);
    return cross(n1.yzw, n2.yzw);
}
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//             Worley Basis (fast version, only gets F1
//
////////////////////////////////////////////////////////////////
//2D
float worleyFast(float2 p)
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Cellular2D.glsl

    const float JITTER_WINDOW = 0.25;   // 0.25 will guarentee no artifacts
    
    //  establish our grid cell and unit position
    float2 Pi = floor(p);
    float2 Pf = p - Pi;

    //  calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  generate the 4 points
    hash_x = hash_x * 2.0 - 1.0;
    hash_y = hash_y * 2.0 - 1.0;
 
    hash_x = ( ( hash_x * hash_x * hash_x ) - sign( hash_x ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y = ( ( hash_y * hash_y * hash_y ) - sign( hash_y ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );

    //  return the closest squared distance
    float4 dx = Pf.xxxx - hash_x;
    float4 dy = Pf.yyyy - hash_y;
    float4 d = dx * dx + dy * dy;
    
    d.xy = min(d.xy, d.zw);
    return min(d.x, d.y) * ( 1.0 / 1.125 ); // return a value scaled to 0.0->1.0
}

//3D
float worleyFast(float3 p)
{
    //  establish our grid cell and unit position
    float3 Pi = floor(p);
    float3 Pf = p - Pi;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5 ) * ( Pi + 1.0 );

    // calculate the hash ( over -1.0->1.0 range )
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hash_x0 = frac( Pt * lowz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_x1 = frac( Pt * highz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_y0 = frac( Pt * lowz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_y1 = frac( Pt * highz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_z0 = frac( Pt * lowz_mod.zzzz ) * 2.0 - 1.0;
    float4 hash_z1 = frac( Pt * highz_mod.zzzz ) * 2.0 - 1.0;

    //  generate the 8 point positions
    const float JITTER_WINDOW3 = 0.166666666;   // 0.166666666 will guarentee no artifacts.
    hash_x0 = ( ( hash_x0 * hash_x0 * hash_x0 ) - sign( hash_x0 ) ) * JITTER_WINDOW3 + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y0 = ( ( hash_y0 * hash_y0 * hash_y0 ) - sign( hash_y0 ) ) * JITTER_WINDOW3 + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_x1 = ( ( hash_x1 * hash_x1 * hash_x1 ) - sign( hash_x1 ) ) * JITTER_WINDOW3 + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y1 = ( ( hash_y1 * hash_y1 * hash_y1 ) - sign( hash_y1 ) ) * JITTER_WINDOW3 + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_z0 = ( ( hash_z0 * hash_z0 * hash_z0 ) - sign( hash_z0 ) ) * JITTER_WINDOW3 + float4( 0.0, 0.0, 0.0, 0.0 );
    hash_z1 = ( ( hash_z1 * hash_z1 * hash_z1 ) - sign( hash_z1 ) ) * JITTER_WINDOW3 + float4( 1.0, 1.0, 1.0, 1.0 );

    //  return the closest squared distance
    float4 dx1 = Pf.xxxx - hash_x0;
    float4 dy1 = Pf.yyyy - hash_y0;
    float4 dz1 = Pf.zzzz - hash_z0;
    float4 dx2 = Pf.xxxx - hash_x1;
    float4 dy2 = Pf.yyyy - hash_y1;
    float4 dz2 = Pf.zzzz - hash_z1;
    float4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1;
    float4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2;
    d1 = min(d1, d2);
    d1.xy = min(d1.xy, d1.wz);
    return min(d1.x, d1.y) * ( 9.0 / 12.0 ); // return a value scaled to 0.0->1.0
}


//2D with gradient
float3 worleyFastGrad(float2 p)
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Cellular2D_Deriv.glsl

    const float JITTER_WINDOW = 0.25;   // 0.25 will guarentee no artifacts
    //  establish our grid cell and unit position
    float2 Pi = floor(p);
    float2 Pf = p - Pi;

    //  calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  generate the 4 points
    hash_x = hash_x * 2.0 - 1.0;
    hash_y = hash_y * 2.0 - 1.0;
    hash_x = ( ( hash_x * hash_x * hash_x ) - sign( hash_x ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y = ( ( hash_y * hash_y * hash_y ) - sign( hash_y ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );

    //  return the closest squared distance + derivatives ( thanks to Jonathan Dupuy )
    float4 dx = Pf.xxxx - hash_x;
    float4 dy = Pf.yyyy - hash_y;
    float4 d = dx * dx + dy * dy;
    float3 t1 = d.x < d.y ? float3( d.x, dx.x, dy.x ) : float3( d.y, dx.y, dy.y );
    float3 t2 = d.z < d.w ? float3( d.z, dx.z, dy.z ) : float3( d.w, dx.w, dy.w );
    return ( t1.x < t2.x ? t1 : t2 ) * float3( 1.0, 2.0, 2.0 ) * ( 1.0 / 1.125 ); // return a value scaled to 0.0->1.0
}

//3D with gradient
float4 worleyFastGrad(float3 p)
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Cellular3D_Deriv.glsl

    //  establish our grid cell and unit position
    float3 Pi = floor(p);
    float3 Pf = p - Pi;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    // calculate the hash ( over -1.0->1.0 range )
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;

    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hash_x0 = frac( Pt * lowz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_x1 = frac( Pt * highz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_y0 = frac( Pt * lowz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_y1 = frac( Pt * highz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_z0 = frac( Pt * lowz_mod.zzzz ) * 2.0 - 1.0;
    float4 hash_z1 = frac( Pt * highz_mod.zzzz ) * 2.0 - 1.0;

    //  generate the 8 point positions
    const float JITTER_WINDOW = 0.166666666;    // 0.166666666 will guarentee no artifacts.
    hash_x0 = ( ( hash_x0 * hash_x0 * hash_x0 ) - sign( hash_x0 ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y0 = ( ( hash_y0 * hash_y0 * hash_y0 ) - sign( hash_y0 ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_x1 = ( ( hash_x1 * hash_x1 * hash_x1 ) - sign( hash_x1 ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y1 = ( ( hash_y1 * hash_y1 * hash_y1 ) - sign( hash_y1 ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_z0 = ( ( hash_z0 * hash_z0 * hash_z0 ) - sign( hash_z0 ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 0.0, 0.0 );
    hash_z1 = ( ( hash_z1 * hash_z1 * hash_z1 ) - sign( hash_z1 ) ) * JITTER_WINDOW + float4( 1.0, 1.0, 1.0, 1.0 );

    //  return the closest squared distance + derivatives ( thanks to Jonathan Dupuy )
    float4 dx1 = Pf.xxxx - hash_x0;
    float4 dy1 = Pf.yyyy - hash_y0;
    float4 dz1 = Pf.zzzz - hash_z0;
    float4 dx2 = Pf.xxxx - hash_x1;
    float4 dy2 = Pf.yyyy - hash_y1;
    float4 dz2 = Pf.zzzz - hash_z1;
    float4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1;
    float4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2;
    float4 r1 = d1.x < d1.y ? float4( d1.x, dx1.x, dy1.x, dz1.x ) : float4( d1.y, dx1.y, dy1.y, dz1.y );
    float4 r2 = d1.z < d1.w ? float4( d1.z, dx1.z, dy1.z, dz1.z ) : float4( d1.w, dx1.w, dy1.w, dz1.w );
    float4 r3 = d2.x < d2.y ? float4( d2.x, dx2.x, dy2.x, dz2.x ) : float4( d2.y, dx2.y, dy2.y, dz2.y );
    float4 r4 = d2.z < d2.w ? float4( d2.z, dx2.z, dy2.z, dz2.z ) : float4( d2.w, dx2.w, dy2.w, dz2.w );
    float4 t1 = r1.x < r2.x ? r1 : r2;
    float4 t2 = r3.x < r4.x ? r3 : r4;
    return ( t1.x < t2.x ? t1 : t2 ) * float4( 1.0, 2.0, 2.0, 2.0  ) * ( 9.0 / 12.0 ); // return a value scaled to 0.0->1.0
}

NOISE2DVECTORFUNCTION(worleyFast)
NOISE2DVECTORGRADFUNCTION(worleyFastGrad)
NOISE3DVECTORFUNCTION(worleyFast)
NOISE3DVECTORGRADFUNCTION(worleyFastGrad)

// return a divergence-free vector field (DFV)
float3 worleyFastDFV(float3 p, float offset = 67)
{
    float4 n1 = worleyFastGrad(p);
    float4 n2 = worleyFastGrad(p+offset);
    return cross(n1.yzw, n2.yzw);
}
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//             Worley Basis Distance & Cell Function Classes
//
////////////////////////////////////////////////////////////////
interface iCellDist 
{
float get(float3 offset);
float get(float2 offset);
};

class cEuclidean : iCellDist
{
    float get(float3 offset)
    {
        return  sqrt(dot( offset, offset ));
    }
    float get(float2 offset)
    {
        return  sqrt(dot( offset, offset ));
    }
};
class cEuclideanSquared : iCellDist
{
    float get(float3 offset)
    {
        return  dot( offset, offset );
    }
    
    float get(float2 offset)
    {
        return  dot( offset, offset );
    }
};
class cChebyshev : iCellDist
{
    float get(float3 offset)
    {
        offset = abs(offset);
        return max(offset.x,max(offset.y, offset.z));     
    }
    
    float get(float2 offset)
    {
        offset = abs(offset);
        return max(offset.x,offset.y);    
    }
};
class cManhattan : iCellDist
{
    float get(float3 offset)
    {
        offset = abs(offset);
        return offset.x + offset.y + offset.z;  
    }
    
    float get(float2 offset)
    {
        offset = abs(offset);
        return offset.x + offset.y;  
    }
};
class cMinkowski : iCellDist
{
    float get(float3 offset)
    {
        offset = abs(offset);
        float p = 4;
        return pow(pow(offset.x, p) + pow(offset.y, p) + pow(offset.z, p), 1.0/p);  
    }
    
    float get(float2 offset)
    {
        offset = abs(offset);
        float p = 4;
        return pow(pow(offset.x, p) + pow(offset.y, p), 1.0/p);  
    }
};

class cCubes : iCellDist {
	float get(float3 off) {
		return max( abs(off.x) *0.866025 + abs(off.z)*0.5 + off.y*0.5, abs(off.z) - off.y );
	}
	float get(float2 off) {
		return max( abs(off.x) *0.866025 + off.y *0.5, -off.y );
	}
};




cEuclidean Euclidean;
cEuclideanSquared EuclideanSquared;
cChebyshev Chebyshev;
cManhattan Manhattan;
cMinkowski Minkowski;
cCubes Cubes;







interface iCellFunc {float result(float2 dist); };
class cF1 : iCellFunc
{
    float result(float2 dist)
    {
        return dist.x;
    }
};
class cF2 : iCellFunc
{
    float result(float2 dist)
    {
        return dist.y;
    }
};
class cF2MinusF1 : iCellFunc
{
    float result(float2 dist)
    {
        return dist.y - dist.x;
    }
};
class cF1PlusF2 : iCellFunc
{
    float result(float2 dist)
    {
        return dist.x + dist.y;
    }
};
class cAverage: iCellFunc
{
    float result(float2 dist)
    {
        return (dist.x + dist.y) / 2;
    }
};
class cCrackle: iCellFunc
{
    float result(float2 dist)
    {
        return max(dist.x, dist.y) * dist.y - dist.x;
    }
};
cF1 F1;
cF2 F2;
cF2MinusF1 F2MinusF1;
cF1PlusF2 F1PlusF2;
cAverage Average;
cCrackle Crackle;


////////////////////////////////////////////////////////////////
//
//             Worley Basis 
//
////////////////////////////////////////////////////////////////


float2 w2dHash( float2 p )
{
    return hash22(p);

    p = float2( dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)) );
    return frac(sin(p)*43758.5453);
}

float3 w3dHash( float3 x )
{
    return hash33 (x);

    x = float3( dot(x,float3(127.1,311.7, 74.7)),
              dot(x,float3(269.5,183.3,246.1)),
              dot(x,float3(113.5,271.9,124.6)));

    return frac(sin(x)*43758.5453123);
}


//2D
float worley(float2 p, iCellDist cellDistance, iCellFunc cellFunction)
{
    float2 n = floor( p );
    float2 f = frac( p );

    float f1 = 8.0;
    float f2 = 8.0;
    
    
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 g = float2(i,j);
        float2 o = w2dHash( n + g );
        float2 r = g - f + o;

        //float d = dot(r,r);           // euclidean^2
        float d = cellDistance.get(r);

        if( d<f1 ) 
        { 
            f2 = f1; 
            f1 = d; 
        }
        else if( d<f2 ) 
        {
            f2 = d;
        }
    }
    
    float c = cellFunction.result(float2(f1, f2));
    return c;
}

//3D
float worley(float3 p, iCellDist cellDistance, iCellFunc cellFunction)
{
    
    float3 whole = floor(p);
    float3 fraction = frac(p);

    float id = 0.0;
    float2 func = 100;
    for( int k=-1; k<=1; k++ )
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float3 b = float3( float(i), float(j), float(k) );
        float3 r = float3( b ) - fraction + w3dHash( whole + b );
      
        float dist = cellDistance.get(r);
        
        if( dist < func.x )
        {
            func = float2( dist, func.x );          
        }
        else if( dist < func.y )
        {
            func.y = dist;
        }
    }

    return  cellFunction.result(func);
}

//2D with gradient
float3 worleyGrad(float2 p, iCellDist cellDistance, iCellFunc cellFunction)
{
    float eps = 0.001;
    float f0 = worley(p, cellDistance, cellFunction);
    float fx = worley(p + float2(eps, 0), cellDistance, cellFunction);
    float fy = worley(p + float2(0, eps),cellDistance, cellFunction);
    float2 d = float2(fx - f0, fy - f0) / eps;
    return float3 (f0, d);
}

//3D with graadient
float4 worleyGrad(float3 p, iCellDist cellDistance, iCellFunc cellFunction)
{
    float eps = 0.001;
    float f0 = worley(p, cellDistance, cellFunction);
    float fx = worley(p + float3(eps, 0, 0), cellDistance, cellFunction);
    float fy = worley(p + float3(0, eps, 0), cellDistance, cellFunction);
    float fz = worley(p + float3(0, 0, eps), cellDistance, cellFunction);
    float3 d = float3(fx - f0, fy - f0, fz - f0) / eps;
    return float4 (f0, d);
}

// return two noises from 2D domain
float2 worley2(float2 p, iCellDist cellDistance, iCellFunc cellFunction, float offset = 67)
{ return float2(worley(p, cellDistance, cellFunction), worley(p+offset, cellDistance, cellFunction)); };

// return two noises from 2D domain along with thier gradients
float2 worley2Grad(float2 p, iCellDist cellDistance, iCellFunc cellFunction, out float2 gradX, out float2 gradY, float offset = 67)
{ 
    float3 nx = worleyGrad(p, cellDistance, cellFunction);
    float3 ny = worleyGrad(p+offset, cellDistance, cellFunction);
    gradX = nx.yz;
    gradY = ny.yz;
    return float2(nx.x, ny.x); 
};

// return three noises from 3D domain
float3 worley3(float3 p, iCellDist cellDistance, iCellFunc cellFunction,  float2 offset = float2(67, 197))
{ return float3(worley(p, cellDistance, cellFunction), worley(p+offset.x, cellDistance, cellFunction), worley( p+offset.y, cellDistance, cellFunction)); };

// return three noises from 3D domain along with thier gradients
float3 worley3Grad(float3 p, iCellDist cellDistance, iCellFunc cellFunction, out float3 gradX, out float3 gradY, out float3 gradZ, float2 offset = float2(67, 197))
{ 
    float4 nx = worleyGrad(p, cellDistance, cellFunction);
    float4 ny = worleyGrad(p+offset.x, cellDistance, cellFunction);
    float4 nz = worleyGrad(p+offset.y, cellDistance, cellFunction);
    gradX = nx.yzw;
    gradY = ny.yzw;
    gradZ = nz.yzw;
    return float3(nx.x, ny.x, nz.x); 
};

// return a divergence-free vector field (DFV)
float3 worleyDFV(float3 p, iCellDist cellDistance, iCellFunc cellFunction, float offset = 67)
{
    float4 n1 = worleyGrad(p, cellDistance, cellFunction);
    float4 n2 = worleyGrad(p+offset, cellDistance, cellFunction);
    return cross(n1.yzw, n2.yzw);
};

// default worley behaviour when no distance & cell functions supplied
#ifndef CELLDISTANCE
    #define CELLDISTANCE EuclideanSquared
#endif
#ifndef CELLFUNCTION
    #define CELLFUNCTION F2MinusF1
#endif
float worley(float2 p) { return worley(p, CELLDISTANCE, CELLFUNCTION); }
float worley(float3 p) { return worley(p, CELLDISTANCE, CELLFUNCTION); }
float3 worleyGrad(float2 p) { return worleyGrad(p, CELLDISTANCE, CELLFUNCTION); }
float4 worleyGrad(float3 p) { return worleyGrad(p, CELLDISTANCE, CELLFUNCTION); }
float2 worley2(float2 p, float offset = 67){ return worley2(p, CELLDISTANCE, CELLFUNCTION); }
float2 worley2Grad(float2 p, out float2 gradX, out float2 gradY, float offset = 67){ return worley2Grad(p, CELLDISTANCE, CELLFUNCTION, gradX, gradY);};
float3 worley3(float3 p, float2 offset = float2(67, 197)) { return worley3(p, CELLDISTANCE, CELLFUNCTION); }
float3 worley3Grad(float3 p, out float3 gradX, out float3 gradY, out float3 gradZ, float2 offset = float2(67, 197)){return worley3Grad(p, CELLDISTANCE, CELLFUNCTION, gradX, gradY, gradZ);};
float3 worleyDFV(float3 p, float offset = 67)
{
    float4 n1 = worleyGrad(p, CELLDISTANCE, CELLFUNCTION);
    float4 n2 = worleyGrad(p+offset, CELLDISTANCE, CELLFUNCTION);
    return cross(n1.yzw, n2.yzw);
};

////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             Sine Basis (not really noise but meh)
//
////////////////////////////////////////////////////////////////
//2D
float sine(float2 p)
{
    return dot(sin(p.x),sin(p.y));
}

//3D
float sine(float3 p)
{
    return dot(dot(sin(p.x),sin(p.y)), sin(p.z));
}

//2D w/ gradient
float3 sineGrad(float2 p)
{
    float sx = sin(p.x);
    float cx = cos(p.x);
    float sy = sin(p.y);
    float cy = cos(p.y);
    return float3(dot(sx, sy), dot(cx, sy), dot(cy, sx));
}

//3D w/ gradient
float4 sineGrad(float3 p)
{
    float sx = sin(p.x);
    float cx = cos(p.x);
    float sy = sin(p.y);
    float cy = cos(p.y);
    float sz = sin(p.z);
    float cz = cos(p.z);

    return float4(
    dot(dot(sx,sy), sz),
    dot(dot(cx,sy), sz),
    dot(dot(sx,cy), sz),
    dot(dot(sx,sy), cz));
}
NOISE2DVECTORFUNCTION(sine)
NOISE2DVECTORGRADFUNCTION(sineGrad)
NOISE3DVECTORFUNCTION(sine)
NOISE3DVECTORGRADFUNCTION(sineGrad)

// return a divergence-free vector field (DFV)
float3 sineDFV(float3 p, float offset = 67)
{
    float4 n1 = sineGrad(p);
    float4 n2 = sineGrad(p+offset);
    return cross(n1.yzw, n2.yzw);
};


////////////////////////////////////////////////////////////////
//
//             Fractal Sum Macros
//
////////////////////////////////////////////////////////////////
// TODO:
//      -add fractional octaves for LOD fading
//      -gradient dependient macros need to have version for both 2D & 3D domain

// Standerd Fractal Sum fBm
#define FBM(name, basis, p, persistence, lacunarity, octaves)               \
    float sum##name = 0.0;                                                  \
    float amp##name = 1.0;                                                  \
    float totalAmp##name = 0.0;                                             \
    float freq##name = 1.0;                                                 \
    for(int i##name=0; i##name <= octaves; i##name++)                       \
    {                                                                       \
        sum##name += basis((p+i##name*27.3) * freq##name) * amp##name;      \
        totalAmp##name += abs(amp##name);                                   \
        amp##name *= persistence;                                           \
        freq##name *= lacunarity;                                           \
    }                                                                       \
    float name = sum##name/totalAmp##name

    // 2D vector Fractal Sum fBm
#define FBM2(name, basis, p, persistence, lacunarity, octaves)              \
    float2 sum##name = 0.0;                                                 \
    float amp##name = 1.0;                                                  \
    float totalAmp##name = 0.0;                                             \
    float2 freq##name = 1.0;                                                \
    for(int i##name=0; i##name <= octaves; i##name++)                       \
    {                                                                       \
        sum##name += basis((p+i##name*27.3) * freq##name) * amp##name;      \
        totalAmp##name += abs(amp##name);                                   \
        amp##name *= persistence;                                           \
        freq##name *= lacunarity;                                           \
    }                                                                       \
    float2 name = sum##name/totalAmp##name

        // 3D vector Fractal Sum fBm
#define FBM3(name, basis, p, persistence, lacunarity, octaves)              \
    float3 sum##name = 0.0;                                                 \
    float amp##name = 1.0;                                                  \
    float totalAmp##name = 0.0;                                             \
    float3 freq##name = 1.0;                                                \
    for(int i##name=0; i##name <= octaves; i##name++)                       \
    {                                                                       \
        sum##name += basis((p+i##name*27.3) * freq##name) * amp##name;      \
        totalAmp##name += abs(amp##name);                                   \
        amp##name *= persistence;                                           \
        freq##name *= lacunarity;                                           \
    }                                                                       \
    float3 name = sum##name/totalAmp##name

// Multi Fractal fBm (good for ridged noise)
#define MFBM(name, basis, p, persistence, lacunarity, octaves)              \
    float sum##name = 0.0;                                                  \
    float amp##name = 1.0;                                                  \
    float totalAmp##name = 0.0;                                             \
    float weight##name = 1.0;                                               \
    float freq##name = 1.0;                                                 \
    for(int i##name=0; i##name <= octaves; i##name++)                       \
    {                                                                       \
        float basis##name = basis((p+i##name*27.3) * freq##name) * amp##name;\
        basis##name *= weight##name;                                        \
        weight##name = saturate(basis##name * amp##name);                   \
        sum##name += basis##name;                                           \
        totalAmp##name += abs(amp##name);                                   \
        amp##name *= persistence;                                           \
        freq##name *= lacunarity;                                           \
    }                                                                       \
    float name = sum##name/totalAmp##name

// IQ fBm
// http://www.iquilezles.org/www/articles/morenoise/morenoise.htm

#define IQFBM2D(name, basis, p, persistence, lacunarity, octaves)               \
    float2 dsum##name = 0.0;                                                    \
    float amp##name = 1.0;                                                      \
    float totalAmp##name = 0.0;                                                 \
    float2 p##name = p;                                                         \
    float freq##name = 1.0;                                                     \
                                                                                \
    float basis##name = basis(p##name * freq##name);                            \
    float sum##name = basis##name;                                              \
                                                                                \
    for(int i##name=0; i##name <= octaves; i##name++)                           \
    {                                                                           \
        p##name += i##name*27.3;                                                \
        basis##name = basis(p##name * freq##name);                        \
        dsum##name += calcGradS2(basis, p##name * freq##name, 0.1/ freq##name); \
        sum##name += amp##name * basis##name / (1 + dot(dsum##name, dsum##name));\
        totalAmp##name += abs(amp##name);                                       \
        amp##name *= persistence;                                               \
        freq##name *= lacunarity;                                               \
   }                                                                             \
    float name = sum##name/totalAmp##name

#define IQFBM3D(name, basis, p, persistence, lacunarity, octaves)               \
    float3 dsum##name = 0.0;                                                    \
    float amp##name = 1.0;                                                      \
    float totalAmp##name = 0.0;                                                 \
    float3 p##name = p;                                                         \
    float freq##name = 1.0;                                                     \
    float basis##name = basis(p##name * freq##name);                            \
    float sum##name = basis##name;                                              \
    for(int i##name=0; i##name <= octaves; i##name++)                           \
    {                                                                           \
        p##name += i##name*27.3;                                                \
        basis##name = basis(p##name * freq##name);                        \
        dsum##name += calcGradS3(basis, p##name * freq##name, 0.1/ freq##name); \
        sum##name += amp##name * basis##name / (1 + dot(dsum##name, dsum##name));\
        totalAmp##name += abs(amp##name);                                       \
        amp##name *= persistence;                                               \
        freq##name *= lacunarity;                                               \
    }                                                                           \
    float name = sum##name/totalAmp##name


// 'Swiss' fBm
// http://www.decarpentier.nl/scape-procedural-extensions/ for more info
// use small value for warp: eg 0.0015

#define SWISSFBM2D(name, basis, p, persistence, lacunarity, octaves, warp)      \
    float sum##name = 0.0;                                                      \
    float2 dsum##name = 0.0;                                                    \
    float amp##name = 1.0;                                                      \
    float totalAmp##name = 0.0;                                                 \
    float2 p##name = p;                                                         \
    float freq##name = 1.0;                                                     \
    for(int i##name=0; i##name <= octaves; i##name++)                           \
    {                                                                           \
        p##name += i##name*27.3 + warp * dsum##name;                            \
        float basis##name = basis(p##name * freq##name);                        \
        dsum##name += -calcGradS2(basis, p##name * freq##name, 0.1/ freq##name); \
        sum##name += basis##name * amp##name;                                   \
        totalAmp##name += abs(amp##name);                                       \
        amp##name *= persistence;                                               \
        freq##name *= lacunarity;                                               \
    }                                                                           \
    float name = sum##name/totalAmp##name

#define SWISSFBM3D(name, basis, p, persistence, lacunarity, octaves, warp)      \
    float sum##name = 0.0;                                                      \
    float3 dsum##name = 0.0;                                                    \
    float amp##name = 1.0;                                                      \
    float totalAmp##name = 0.0;                                                 \
    float3 p##name = p;                                                         \
    float freq##name = 1.0;                                                     \
    for(int i##name=0; i##name <= octaves; i##name++)                           \
    {                                                                           \
        p##name += i##name*27.3 + warp * dsum##name;                            \
        float basis##name = basis(p##name * freq##name);                        \
        dsum##name += -calcGradS3(basis, p##name * freq##name, 0.1/ freq##name); \
        sum##name += basis##name * amp##name;                                   \
        totalAmp##name += abs(amp##name);                                       \
        amp##name *= persistence;                                               \
        freq##name *= lacunarity;                                               \
    }                                                                           \
    float name = sum##name/totalAmp##name


// WIP

////////////////////////////////////////////////////////////////
//EOF