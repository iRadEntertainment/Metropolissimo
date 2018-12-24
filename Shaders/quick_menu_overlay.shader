shader_type canvas_item;

void fragment() {
	float speed = .5;
	float scale = 2.0;
	vec2 new_uv = UV;
	new_uv.x = new_uv.x + (sin(TIME*speed) *scale);
	new_uv.y = new_uv.y + (cos(TIME*speed) *scale);
	vec4 color = texture(SCREEN_TEXTURE,SCREEN_UV,0.0).gggg + texture(TEXTURE,new_uv) * ((sin(TIME)+2.0)/2.0)*.05;
	COLOR.rgb = color.rgb;
	COLOR.a = 0.95;
}