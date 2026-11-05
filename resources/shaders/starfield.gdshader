
shader_type canvas_item;
render_mode blend_add;

uniform vec2 camera_position = vec2(0.0);
uniform float zoom = 1.0;

uniform float star_density = 0.0015;
uniform float star_size = 1.2;
uniform float brightness = 1.0;

uniform vec2 world_scale = vec2(1.0);

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
    // Screen coordinates transformed into world coordinates.
    vec2 world_pos =
        camera_position + (SCREEN_UV - vec2(0.5)) * world_scale / zoom;

    // Divide the universe into small cells.
    vec2 cell = floor(world_pos * 0.1);

    float stars = 0.0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 current_cell = cell + vec2(float(x), float(y));

            float random_value = hash21(current_cell);

            if (random_value > 1.0 - star_density) {
                vec2 offset = vec2(
                    hash21(current_cell + 12.3),
                    hash21(current_cell + 45.6)
                );

                vec2 star_pos =
                    (current_cell + offset) * 10.0;

                float dist = distance(world_pos, star_pos);

                float star = 1.0 - smoothstep(
                    0.0,
                    star_size,
                    dist
                );

                stars += star * random_value;
            }
        }
    }

    float star_brightness = clamp(stars * brightness, 0.0, 1.0);
    COLOR = vec4(
        vec3(star_brightness),
        star_brightness
    );
}
