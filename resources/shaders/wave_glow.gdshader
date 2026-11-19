shader_type canvas_item;
render_mode blend_mix;

uniform vec4 glow_color : source_color = vec4(0.35, 1.0, 0.2, 1.0);
uniform float glow_strength : hint_range(0.0, 5.0) = 2.0;
uniform float glow_opacity : hint_range(0.0, 1.0) = 0.8;
uniform float glow_size : hint_range(0.0, 8.0) = 4.0;
uniform float inner_glow_strength : hint_range(0.0, 2.0) = 0.35;

// Spritesheet grid dimensions
uniform vec2 sheet_grid = vec2(8.0, 6.0);

float get_alpha(sampler2D tex, vec2 uv, vec2 frame_min, vec2 frame_max) {
    vec2 safe_uv = clamp(uv, frame_min, frame_max);
    return textureLod(tex, safe_uv, 0.0).a;
}

void fragment() {
    vec2 frame_size = 1.0 / sheet_grid;
    vec2 frame_index = floor(UV / frame_size);

    vec2 frame_min = frame_index * frame_size;
    vec2 frame_max = frame_min + frame_size;

    vec4 sprite_color = texture(TEXTURE, UV);
    float sprite_alpha = sprite_color.a;

    float glow_alpha = 0.0;

    // Calculate outer glow
    for (int i = 0; i < 24; i++) {
        float angle = float(i) * 0.2617994;
        vec2 direction = vec2(cos(angle), sin(angle));

        for (int radius = 1; radius <= 5; radius++) {
            float distance = float(radius) * 0.2;

            vec2 sample_uv = UV +
                direction * TEXTURE_PIXEL_SIZE * glow_size * distance;

            float sample_alpha = get_alpha(
                TEXTURE, sample_uv, frame_min, frame_max
            );

            glow_alpha += sample_alpha * (1.0 - distance);
        }
    }

    glow_alpha /= 60.0;
    glow_alpha *= 1.0 - sprite_alpha;

    // Inner glow
    vec3 inner_color = sprite_color.rgb +
        glow_color.rgb * glow_strength * inner_glow_strength;

    // Combine inner and outer glow
    vec3 final_color = mix(
        inner_color,
        glow_color.rgb * glow_strength,
        glow_alpha * glow_opacity
    );

    float outer_alpha = glow_alpha * glow_opacity * glow_color.a;

    vec3 output_color = mix(
        sprite_color.rgb,
        final_color,
        glow_opacity
    );

    float output_alpha = max(sprite_alpha, outer_alpha);

    COLOR = vec4(output_color, output_alpha);
}