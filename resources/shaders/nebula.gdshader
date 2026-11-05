
shader_type canvas_item;

uniform vec2 camera_position = vec2(0.0);
uniform float zoom = 1.0;
uniform vec2 world_scale = vec2(1920.0, 1080.0);

// Environment colors
uniform vec4 color_a : source_color = vec4(0.08, 0.02, 0.2, 1.0);
uniform vec4 color_b : source_color = vec4(0.02, 0.12, 0.3, 1.0);
uniform vec4 color_c : source_color = vec4(0.3, 0.03, 0.15, 1.0);
uniform vec4 color_d : source_color = vec4(0.02, 0.2, 0.15, 1.0);

uniform float time = 0.0;
uniform vec2 nebula_drift = vec2(0.5, 0.2);

uniform float noise_scale = 0.00035;
uniform float nebula_strength = 0.7;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;

    for (int i = 0; i < 5; i++) {
        value += noise(p) * amplitude;
        p *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

vec3 get_palette(float t) {
    if (t < 0.33) {
        return mix(color_a.rgb, color_b.rgb,
            smoothstep(0.0, 0.33, t));
    }

    if (t < 0.66) {
        return mix(color_b.rgb, color_c.rgb,
            smoothstep(0.33, 0.66, t));
    }

    return mix(color_c.rgb, color_d.rgb,
        smoothstep(0.66, 1.0, t));
}

void fragment() {
    vec2 world_pos =
        camera_position +
        (SCREEN_UV - vec2(0.5)) * world_scale / zoom;

    // Large-scale environmental variation
    vec2 p = (world_pos + nebula_drift * time) * noise_scale;

    float region = fbm(p * 0.35);

    // Smooth color transitions across the universe
    float palette_position = clamp(
        region * 0.75 + fbm(p * 0.12) * 0.25,
        0.0,
        1.0
    );

    vec3 base_color = get_palette(palette_position);

    // Smaller nebula structures
    float clouds = fbm(p * 2.0);
    float detail = fbm(p * 5.0);

    float nebula = smoothstep(
        0.35,
        0.75,
        clouds + detail * 0.2
    );

    // Add subtle dark areas and colorful clouds
    vec3 final_color = base_color * 0.25;
    final_color += base_color * nebula * nebula_strength;

    COLOR = vec4(final_color, 1.0);
}
