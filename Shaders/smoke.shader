shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float ratio       : hint_range( 0.1 , 20 , 0.1 ) = 1.0;
uniform float resolution  : hint_range( 0.5 , 5 , 0.1 ) = 10.0;
uniform float trasparency : hint_range( 0 , 1 , 0.1 ) = 0.7;
uniform float color_add   : hint_range( 0 , 1 , 0.1 ) = 0;
uniform bool side_fade = true;
uniform float side_mul    : hint_range( 1 , 5 , 0.1 ) = 2.0;
uniform float displ       : hint_range( 0.0 , 0.1 , 0.002 ) = 0.05;

mat3 rotX(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat3(
		vec3(1, 0, 0),
		vec3(0, c, -s),
		vec3(0, s, c)
		);
}
mat3 rotY(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat3(
		vec3(c, 0, -s),
		vec3(0, 1, 0),
		vec3(s, 0, c)
	);
}

float random(vec2 pos) {
	return fract(sin(dot(pos.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 pos) {
	vec2 i = floor(pos);
	vec2 f = fract(pos);
	float a = random(i + vec2(0.0, 0.0));
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 pos) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100.0);
	mat2 rot = mat2(vec2(cos(0.5), sin(0.5)),
	                vec2( -sin(0.5), cos(0.5))
					);
	for (int i=0; i<16; i++) {
		v += a * noise(pos);
		pos = rot * pos * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	//vec2 p = (FRAGCOORD.xy * 2.0 - resolution.xy) / resolution.x;
	vec2 p = UV * resolution;
	p.x *= ratio;
	float t = 0.0, d;
	
	float time2 = 3.0 * TIME / 2.0;
	
	vec2 q = vec2(0.0);
	q.x = fbm(p + 0.00 * time2);
	q.y = fbm(p + vec2(1.0));
	vec2 r = vec2(0.0);
	r.x = fbm(p + 1.0 * q + vec2(1.7, 9.2) + 0.15 * time2);
	r.y = fbm(p + 1.0 * q + vec2(8.3, 2.8) + 0.126 * time2);
	float f = fbm(p + r);
	vec3 color = mix(
		vec3(0.101961, 0.619608, 1.666667),
		vec3(0.666667, 0.666667, 1.498039),
		clamp((f * f) * 4.0, 0.0, 1.0)
	);

	color = mix(
		color,
		vec3(0, 0, 0.164706),
		clamp(length(q), 0.0, 1.0)
	);


	color = mix(
		color,
		vec3(1.17, 1.3, 1.3),
		clamp(r.x, 0.0, 1.0)
	);

	color = (f *f * f + 0.6 * f * f + 0.5 * f) * color;
	
	vec2 new_uv = SCREEN_UV + color.rb * displ;
	COLOR = mix(texture(SCREEN_TEXTURE , new_uv), vec4(color, 1.0), vec4(color_add));
	
	if (side_fade) {
		COLOR.a = min (COLOR.a , min( min(UV.y*side_mul, side_mul - UV.y*side_mul), min( UV.x*side_mul, side_mul - UV.x*side_mul) ) );
		}
	COLOR.a = COLOR.a * trasparency;
}