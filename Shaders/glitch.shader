shader_type canvas_item;
render_mode unshaded;

uniform sampler2D displace : hint_albedo;
uniform float displ_amount : hint_range( 0 , 0.1 );
uniform float displ_size   : hint_range( 0.1 , 5 );
uniform float aberrationX  : hint_range( -0.03 , 0.03 );
uniform float aberrationY  : hint_range( -0.03 , 0.03 );
uniform float mov_speed    : hint_range( -3 , 3 );
uniform float mov_magnitude: hint_range( 0 , 3);
uniform float transparency : hint_range( 0.01 , 1 );

void fragment() {
	vec4 disp = texture(displace , UV * displ_size + sin(TIME* mov_speed) * mov_magnitude );
	vec2 new_uv = SCREEN_UV + disp.rg * displ_amount;
	vec2 aberration = vec2(aberrationX,aberrationY);
	
	COLOR.r = texture(SCREEN_TEXTURE,new_uv - aberration).r;
	COLOR.g = texture(SCREEN_TEXTURE,new_uv             ).g;
	COLOR.b = texture(SCREEN_TEXTURE,new_uv + aberration).b;
	COLOR.a = texture(SCREEN_TEXTURE,new_uv             ).a * transparency;
	//COLOR.a = texture(TEXTURE , UV).a;
}