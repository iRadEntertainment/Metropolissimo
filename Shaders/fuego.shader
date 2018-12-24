shader_type canvas_item;
render_mode unshaded;

uniform float offset_Y    : hint_range(-1 , 1 , 0.1) = 0.0;
uniform float brightness  : hint_range(0.8 , 2.0 , 0.1) = 1.5;
uniform float thrust      : hint_range(1.0 , 3.0 , 0.1) = 2.0;
uniform float speed       : hint_range(0.1 , 5.0 , 0.1) = 1.0;
uniform float consistency : hint_range(0.05 , 0.75 , 0.05) = 0.5;
uniform float res         : hint_range(0.5 , 8.0 , 0.25) = 1.5;
uniform float base        : hint_range(0.0 , 1.5 , 0.25) = 0.0;
uniform float thickness   : hint_range(0.8 , 8.0 , 0.2) = 1.0;

vec2 hash( vec2 p ){
	p = vec2( dot(p,vec2(127.1,311.7)),
			 dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ){
	float K1 = 0.366025404; // (sqrt(3)-1)/2;
	float K2 = 0.211324865; // (3-sqrt(3))/6;
	
	vec2 i = floor( p + (p.x+p.y)*K1 );
	
	vec2 a = p - i + (i.x+i.y)*K2;
	vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0);
	vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
	
	vec3 h = max( 0.51-vec3(dot(a,a), dot(b,b), dot(c,c) ), vec3(0.0) );
	
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
	
	return dot( n, vec3(70.0) );
}

float fbm(vec2 uv){
	float f;
	mat2 m = mat2( vec2( 1.8,  1.2) , vec2( -1.2,  1.6 ) );
	f  = 0.5000*noise( uv ); uv = m*uv;
	f += 0.2500*noise( uv ); uv = m*uv;
	f += 0.1250*noise( uv ); uv = m*uv;
	f += 0.0625*noise( uv ); uv = m*uv;
	f = consistency + 0.5*f;
	return f;
}

void fragment() {
	vec2 uv = UV;
	vec2 q = uv;
	//q.x *= 1.0;
	q.y *= thrust;
	float strength = floor(q.x+1.0)*res;
	float T3 = max(3.0,1.25*strength)*TIME*speed;
	q.x = mod(q.x,1.0)-0.5;
	q.y -= offset_Y;
	float n = fbm(strength*q - vec2(0,T3));
	float c = 1.0 - 16.0 * pow( max( 0.01, length(q*vec2(1.8+q.y*1.5,.75) ) - n * max( base, q.y+.25 ) ),1.2*thickness );
//	float c1 = n * c * (1.5-pow(1.25*uv.y,4.));
	float c1 = n * c * (1.5-pow(1.25*uv.y,4.0))*brightness;
	c1=clamp(c1,0.0,1.0);

	vec3 col = vec3(1.5*c1, 1.5*pow(c1,3.0), pow(c1,6.0));
	
//#ifdef BLUE_FLAME
	//col = col.zyx;

//#ifdef GREEN_FLAME
	//col = 0.85*col.yxz;
	
	float a = c * (1.0-pow(uv.y,8.0));
	COLOR.rgb = mix(vec3(0.0),col,a);
	COLOR.a = clamp(COLOR.r, .0, 1.0);
}