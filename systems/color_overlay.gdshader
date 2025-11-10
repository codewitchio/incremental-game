shader_type canvas_item;

// Color 1: Maps to black (low luminance) pixels
uniform vec4 background_color : source_color;
// Color 2: Maps to white (high luminance) pixels
uniform vec4 foreground_color : source_color;

// Threshold for determining if a pixel is black or white
uniform float threshold : hint_range(0.0, 1.0, 0.01) = 0.10;

uniform bool is_enabled = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// vec4 tex_color = texture(TEXTURE, UV);
	
	// Check if pixel is within 95% of black (all channels < 0.05)
	float min_channel = min(min(COLOR.r, COLOR.g), COLOR.b);
	bool is_black = min_channel < threshold;
	
	// Check if pixel is within 95% of white (all channels > 0.95)
	float max_channel = max(max(COLOR.r, COLOR.g), COLOR.b);
	bool is_white = max_channel > (1.0 - threshold);
	
	vec3 mapped_rgb;
	if (!is_enabled) {
		mapped_rgb = COLOR.rgb;
	} else if (is_black) {
		// Near-black → background_color
		mapped_rgb = background_color.rgb;
	} else if (is_white) {
		// Near-white → foreground_color
		mapped_rgb = foreground_color.rgb;
	} else {
		// Everything else → leave unchanged
		mapped_rgb = COLOR.rgb;
	}
	
	// Always preserve the original texture's alpha channel
	COLOR = vec4(mapped_rgb, COLOR.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
