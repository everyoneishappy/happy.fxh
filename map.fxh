////////////////////////////////////////////////////////////////
//
//          Handy Mapping Functions
// 			
////////////////////////////////////////////////////////////////

#define MAP_FXH

////////////////////////////////////////////////////////////////
//
//             Bias & Gain
//
////////////////////////////////////////////////////////////////


// Schlick's version of Bias & Gain w/ inversion on 0 to -1 for bias/gain values
// these functions expect an input in 0 - 1 range

float bias(float x, float control = 0.5)
{
 	float result = control > 0 ?  (x / ((((1.0/control) - 2.0)*(1.0 - x))+1.0)) :  1-(x / ((((1.0/abs(control)) - 2.0)*(1.0 - x))+1.0));
 	return result;
}

float2 bias(float2 x, float control = 0.5)
{

 	return float2(bias(x.x, control), bias(x.y, control));
}

float3 bias(float3 x, float control = 0.5)
{

 	return float3(bias(x.x, control), bias(x.y, control), bias(x.z, control));
}



float gain(float x, float control = 0.5)
{
	if (control > 0)
	{if(x < 0.5)     return bias(x * 2.0,control)/2.0;   else  return bias(x * 2.0 - 1.0,1.0 - control)/2.0 + 0.5; }
	else if(x < 0.5)     return 1-(bias(x * 2.0,-control)/2.0);   else  return 1-(bias(x * 2.0 - 1.0,1.0 + control)/2.0 + 0.5); 
} 

float2 gain(float2 x, float control = 0.5)
{

 	return float2(gain(x.x, control), gain(x.y, control));
}

float3 gain(float3 x, float control = 0.5)
{

 	return float3(gain(x.x, control), gain(x.y, control), gain(x.z, control));
}
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             Bandpass Functions
//
////////////////////////////////////////////////////////////////

 float smoothstep2 (float onMin, float onMax, float offMin, float offMax, float input)
 {
 	input = smoothstep(onMin, onMax, input) * (1 - smoothstep(offMin, offMax, input));
 	return input;
 }


float cubicPulse(float input, float center, float width)
{
    input = abs(input - center);
    if(input > width) return 0.0f;
    input /= width;
    return 1.0f - input*input*(3.0f-2.0f*input);
}
//
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             Map Functions
//
////////////////////////////////////////////////////////////////

float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
{
	float range = InMax - InMin;
	float normalized = (Input - InMin) / range;	
	   return OutMin + normalized * (OutMax - OutMin);
}
	

float mapClamp(float Input, float InMin, float InMax, float OutMin, float OutMax)
{
	float range = InMax - InMin;
	float normalized = (Input - InMin) / range;	
	float output = OutMin + normalized * (OutMax - OutMin);
	float minV = min(OutMin,OutMax);
	float maxV = max(OutMin, OutMax);
	output = min(max(output, minV), maxV);
	return output ;
}


float mapWrap(float Input, float InMin, float InMax, float OutMin, float OutMax)
{
	float range = InMax - InMin;
	float normalized = (Input - InMin) / range;	
	float output = OutMin + normalized * (OutMax - OutMin);
    if (normalized < 0) normalized = 1 + normalized;
	return  OutMin + (normalized % 1) * (OutMax - OutMin);
}


float mapMirror(float Input, float InMin, float InMax, float OutMin, float OutMax)
{
	float range = InMax - InMin;
	float normalized = (Input - InMin) / range;	
	normalized = 1-2*abs(frac(normalized*.5)-.5);
	float output = OutMin + (normalized % 1) * (OutMax - OutMin);
	return output;
}


float2 map(float2 Input, float2 InMin, float2 InMax, float2 OutMin, float2 OutMax)
{
	float2 vec;
	vec.x = map( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = map( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	return vec;
}

float3 map(float3 Input, float3 InMin, float3 InMax, float3 OutMin, float3 OutMax)
{
	float3 vec;
	vec.x = map( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = map( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	vec.z = map( Input.z,  InMin.z,  InMax.z,  OutMin.z,  OutMax.z);
	return vec;
}

float2 mapClamp(float2 Input, float2 InMin, float2 InMax, float2 OutMin, float2 OutMax)
{
	float2 vec;
	vec.x = mapClamp( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = mapClamp( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	return vec;
}

float3 mapClamp(float3 Input, float3 InMin, float3 InMax, float3 OutMin, float3 OutMax)
{
	float3 vec;
	vec.x = mapClamp( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = mapClamp( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	vec.z = mapClamp( Input.z,  InMin.z,  InMax.z,  OutMin.z,  OutMax.z);
	return vec;
}

float2 mapWrap(float2 Input, float2 InMin, float2 InMax, float2 OutMin, float2 OutMax)
{
	float2 vec;
	vec.x = mapWrap( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = mapWrap( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	return vec;
}

float3 mapWrap(float3 Input, float3 InMin, float3 InMax, float3 OutMin, float3 OutMax)
{
	float3 vec;
	vec.x = mapWrap( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = mapWrap( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	vec.z = mapWrap( Input.z,  InMin.z,  InMax.z,  OutMin.z,  OutMax.z);
	return vec;
}

float2 mapMirror(float2 Input, float2 InMin, float2 InMax, float2 OutMin, float2 OutMax)
{
	float2 vec;
	vec.x = mapMirror( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = mapMirror( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	return vec;
}

float3 mapMirror(float3 Input, float3 InMin, float3 InMax, float3 OutMin, float3 OutMax)
{
	float3 vec;
	vec.x = mapMirror( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = mapMirror( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	vec.z = mapMirror( Input.z,  InMin.z,  InMax.z,  OutMin.z,  OutMax.z);
	return vec;
}
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//EOF