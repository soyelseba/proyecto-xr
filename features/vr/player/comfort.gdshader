shader_type spatial;
render_mode unshaded, cull_front, depth_test_disabled, depth_draw_never, shadows_disabled;
uniform float vignette = 0.0;
uniform float blackout = 0.0;
void fragment() {
	float edge = smoothstep(0.2, 0.65, 1.0 + normalize(VERTEX).z);
	ALBEDO = vec3(0.0);
	ALPHA = max(blackout, edge * vignette);
}
