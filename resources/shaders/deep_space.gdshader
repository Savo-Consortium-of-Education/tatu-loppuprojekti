
shader_type canvas_item;

uniform vec2 camera_position = vec2(0.0);
uniform float zoom = 1.0;
uniform vec2 world_scale = vec2(1920.0, 1080.0);

// Base palette
uniform vec4 space_color : source_color =
    vec4(0.008, 0.012, 0.035, 1.0);

uniform vec4 blue_glow : source_color =
    vec4(0.025, 0.055, 0.16, 1.0);

uniform vec4 purple_glow : source_color =
    vec4(0.09, 0.025, 0.14, 1.0);

uniform vec4 cyan_glow : source_color =
    vec4(0.015, 0.09, 0.14, 1.0);

// Pixel art controls
uniform float pixel_size : hint_range(1.0, 16.0) = 5.0;
uniform float glow_strength : hint_range(0.0, 2.0) = 0.65;
uniform float dust_strength : hint_range(0.0, 1.0) = 0.12;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.55;

// Animation
uniform float animation_speed : hint_range(0.0, 0.1) = 0.008;

// Dithering
uniform float dither_strength : hint_range(0.0, 0.1) = 0.018;

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

void fragment() {
    // Pixelated screen coordinates
    vec2 pixel_uv = floor(SCREEN_UV * world_scale / pixel_size)
        * pixel_size / world_scale;

    vec2 uv = pixel_uv;

    // Camera-relative world coordinates
    vec2 world_pos = camera_position +
        (uv - vec2(0.5)) * world_scale / zoom;

    float t = TIME * animation_speed;

    // Pixelated atmospheric formations
    float n1 = noise(floor(world_pos * 0.012 + vec2(t, 0.0)));
    float n2 = noise(floor(world_pos * 0.020 + vec2(0.0, -t)));

    // Large color regions
    float blue = exp(
        -length((uv - vec2(0.25, 0.42)) *
        vec2(1.0, 1.3)) * 3.0
    );

    float purple = exp(
        -length((uv - vec2(0.78, 0.68)) *
        vec2(1.2, 1.0)) * 3.5
    );

    float cyan = exp(
        -length((uv - vec2(0.55, 0.22)) *
        vec2(1.4, 1.2)) * 4.0
    );

    // Quantized cloud variation
    float cloud = floor((n1 * 0.65 + n2 * 0.35) * 5.0) / 5.0;

    vec3 col = space_color.rgb;

    col += blue_glow.rgb * blue * glow_strength;
    col += purple_glow.rgb * purple * glow_strength;
    col += cyan_glow.rgb * cyan * glow_strength;

    col += blue_glow.rgb * cloud * 0.12;

    // Pixelated distant dust
    vec2 dust_cell = floor(world_pos * 0.035);

    float dust = hash21(dust_cell);

    if (dust > 0.94) {
        col += vec3(0.08, 0.12, 0.22) * dust_strength;
    }

    // Subtle pixel dithering
    float dither = hash21(floor(SCREEN_UV * world_scale / pixel_size));

    col += (dither - 0.5) * dither_strength;

    // Vignette
    float vignette = smoothstep(
        0.15,
        0.95,
        distance(uv, vec2(0.5))
    );

    col *= mix(
        1.0 - vignette_strength,
        1.0,
        vignette
    );

    COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), 1.0);
}