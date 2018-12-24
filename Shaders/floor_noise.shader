shader_type canvas_item;
//render_mode unshaded;

// Author @patriciogv - 2015
// Title: Mosaic

uniform int x_count : hint_range(1,100) = 10;
uniform int y_count : hint_range(1,100) = 10;
uniform float displ : hint_range(0.005, 0.05, 0.005) = 0.03;

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
						*43758.5453123);
}

void fragment() {
    vec2 st = UV;//gl_FragCoord.xy/u_resolution.xy;

    st.x *= float(x_count); // Scale the coordinate system by 10
	st.y *= float(y_count);
    vec2 ipos = floor(st);  // get the integer coords
    vec2 fpos = fract(st);  // get the fractional coords

    // Assign a random value based on the integer coord
    vec3 color = vec3(random( ipos ));

    // Uncomment to see the subdivided grid
    color = vec3(fpos,0.0);
	
	vec2 new_uv = SCREEN_UV + color.rg*displ;
    COLOR.rgb = texture(SCREEN_TEXTURE, new_uv).rgb;
}