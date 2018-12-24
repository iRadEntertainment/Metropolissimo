shader_type canvas_item;
render_mode unshaded, blend_add;

uniform float ratio : hint_range(0.1,20) = .2;
uniform int count : hint_range(1,15) = 1;

float Hash( vec2 p){
    vec3 p2 = vec3(p.xy,1.0);
    return fract(sin(dot(p2,vec3(37.1,61.7, 12.4)))*758.5453123);
}

float noise(in vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    f *= f * (3.0-2.0*f);

    return mix(mix(Hash(i + vec2(0.0,0.0)), Hash(i + vec2(1.0,0.0)),f.x),
               mix(Hash(i + vec2(0.0,1.0)), Hash(i + vec2(1.0,1.0)),f.x),
               f.y);
}

float fbm(vec2 p){
     float v = 0.0;
     v += noise(p*1.0)*.100;
     v += noise(p*2.0)*.25;
     v += noise(p*4.0)*.125;
     v += noise(p*8.0)*.0625;
     return v;
}

void fragment(){
	vec2 uv = UV * 2.0 -1.0;//( FRAGCOORD.xy / resolution.xy ) * 2.0 - 1.0;
	uv.x *= ratio;
	uv.x -= 0.3;
	
	vec3 finalColor = vec3( 0.0 );
	for( int i=1; i < count+1; ++i ){
		float t = abs(1.0 / ((uv.x + fbm( uv + TIME/float(i)))*50.0));
		finalColor +=  t * vec3( float(i) * 0.1 +0.1, 0.5, 2.0 );
	}
	
	COLOR.rgb = finalColor;
	float narrowing = 50.0;
	float alpha_end = min( mix(narrowing,0.0, UV.y) , UV.y*narrowing);
	COLOR.a   = min(smoothstep(COLOR.b, 0.0 , 0.5),alpha_end);
}

