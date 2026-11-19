shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.3, 0.4, 1.0, 1.0);

uniform float glow_radius : hint_range(0.05, 1.0) = 0.65;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float glow_opacity : hint_range(0.0, 1.0) = 0.6;
uniform float glow_softness : hint_range(0.1, 5.0) = 2.0;

uniform float pulse_speed : hint_range(0.1, 5.0) = 1.5;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv);

    float normalized_dist = dist / glow_radius;
    float glow = exp(-pow(normalized_dist * glow_softness, 2.0) * 2.0);
    glow *= 1.0 - smoothstep(0.7, 1.0, normalized_dist);

    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
    
    vec3 glow_rgb = glow_color.rgb * glow_intensity * pulse;
    float glow_alpha = glow * glow_opacity * glow_color.a * pulse;
    
    float alpha = glow_alpha;
    
    COLOR = vec4(glow_rgb, clamp(alpha, 0.0, 1.0));
}