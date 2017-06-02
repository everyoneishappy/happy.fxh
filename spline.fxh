#define SPLINE_FXH

float BSplineCubic(float p1, float p2, float p3, float p4, float range) 
{
    float mu = frac(range);
    float a0 = p4 - p3*3 + p2*3 - p1;
    float a1 = p3*3 - p2*6 + p1*3.;
  float a2 = p3*3 - p1*3;
    float a3 = p3 + p2*4 + p1;
  
  return (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
}

float2 BSplineCubic(float2 p1, float2 p2, float2 p3, float2 p4, float range) 
{
    float mu = frac(range);
    float2 a0 = p4 - p3*3 + p2*3 - p1;
    float2 a1 = p3*3 - p2*6 + p1*3.;
  float2 a2 = p3*3 - p1*3;
    float2 a3 = p3 + p2*4 + p1;
  
  return (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
}

float3 BSplineCubic(float3 p1, float3 p2, float3 p3, float3 p4, float range) 
{
    float mu = frac(range);
    float3 a0 = p4 - p3*3 + p2*3 - p1;
    float3 a1 = p3*3 - p2*6 + p1*3.;
  float3 a2 = p3*3 - p1*3;
    float3 a3 = p3 + p2*4 + p1;
  
  return (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
}

struct SplinePosTan3
{
  float3 Pos;
  float3 Tang;
};

SplinePosTan3 BSplineCubic3PT(float3 p1, float3 p2, float3 p3, float3 p4, float range) 
{
  SplinePosTan3 Out = (SplinePosTan3)0;

    float mu = frac(range);
    float3 a0 = p4 - p3*3 + p2*3 - p1;
    float3 a1 = p3*3 - p2*6 + p1*3.;
  float3 a2 = p3*3 - p1*3;
    float3 a3 = p3 + p2*4 + p1;
  
  Out.Pos = (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
  Out.Tang = normalize((mu*(2*a0*mu+a1)+mu*(a0*mu+a1)+a2)/6.);
  return Out;
}