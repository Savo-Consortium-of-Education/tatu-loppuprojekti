
shader_type canvas_item;
render_mode blend_mix;

uniform vec4 line_color : source_color = vec4(0.18, 0.28, 0.55, 1.0);
uniform vec4 glow_color : source_color = vec4(0.2, 0.4, 1.0, 1.0);

// World-space grid
uniform float grid_size = 180.0;
uniform float line_thickness : hint_range(0.5, 5.0) = 1.5;

uniform vec2 viewport_size = vec2(1920.0, 1080.0);
uniform vec2 camera_position = vec2(0.0);
uniform float zoom = 1.0;

// Animation
uniform float animation_speed = 0.15;
uniform float scroll_speed = 0.06;

uniform float motion_strength = 0.007;
uniform float motion_speed1 = 0.03;
uniform float motion_speed2 = 0.015;

// Glow
uniform float glow_strength = 1.2;
uniform float glow_radius = 0.5;
uniform float glow_pulse_speed = 0.4;

// Camera exclusion
uniform float camera_exclusion_radius = 0.12;
uniform float camera_fade_softness = 0.08;

void fragment() {

    vec2 uv = UV;

    float anim_time = TIME * animation_speed;

    // --------------------------------
    // WORLD POSITION
    // --------------------------------

    vec2 screen_world = (
        (uv - vec2(0.5)) *
        viewport_size /
        max(zoom, 0.001)
    );

    vec2 world_pos = camera_position + screen_world;

    // --------------------------------
    // DISTORTION
    // --------------------------------

    float wave1 = sin(
        (uv.x + uv.y) * 10.0 +
        anim_time * motion_speed1
    );

    float wave2 = sin(
        (uv.x - uv.y) * 50.0 +
        anim_time * motion_speed2
    );

    float distortion = (
        wave1 + wave2
    ) * 0.5 * motion_strength;

    world_pos += vec2(distortion * grid_size);

    // --------------------------------
    // GRID
    // --------------------------------

    world_pos += vec2(
        anim_time * scroll_speed * grid_size
    );

    float safe_grid_size = max(grid_size, 1.0);

    vec2 cell = fract(world_pos / safe_grid_size);

    // Distance to nearest grid line in world units.
    vec2 line_distance = min(
        cell,
        1.0 - cell
    ) * safe_grid_size;

    // Convert world distance to screen pixels.
    vec2 pixel_distance = line_distance * zoom;

    float nearest_line = min(
        pixel_distance.x,
        pixel_distance.y
    );

    // Anti-aliased lines.
    float aa = max(fwidth(nearest_line), 0.5);

    float lines = 1.0 - smoothstep(
        line_thickness,
        line_thickness + aa,
        nearest_line
    );

    // Grid intersections.
    float intersection = (
        1.0 - smoothstep(
            line_thickness,
            line_thickness + aa,
            pixel_distance.x
        )
    ) * (
        1.0 - smoothstep(
            line_thickness,
            line_thickness + aa,
            pixel_distance.y
        )
    );

    // --------------------------------
    // GLOW
    // --------------------------------

    vec2 centered = uv - vec2(0.5);

    float aspect = viewport_size.x / max(
        viewport_size.y,
        1.0
    );

    float dist = length(
        centered * vec2(aspect, 1.0)
    );

    float pulse = sin(
        anim_time * glow_pulse_speed
    ) * 0.5 + 0.5;

    float central_glow = (
        1.0 - smoothstep(
            0.0,
            glow_radius,
            dist
        )
    ) * glow_strength * (
        0.5 + pulse * 0.5
    );

    float grid_glow = (
        intersection * glow_strength
    );

    // --------------------------------
    // COLOR
    // --------------------------------

    vec3 col = vec3(0.0);

    col += line_color.rgb * lines;
    col += glow_color.rgb * central_glow;
    col += glow_color.rgb * grid_glow;

    // --------------------------------
    // CAMERA EXCLUSION
    // --------------------------------

    float camera_dist = length(
        centered * vec2(aspect, 1.0)
    );

    float camera_mask = smoothstep(
        camera_exclusion_radius,
        camera_exclusion_radius + camera_fade_softness,
        camera_dist
    );

    // --------------------------------
    // FINAL
    // --------------------------------

    float alpha = max(
        lines * line_color.a,
        max(
            central_glow * 0.25,
            grid_glow
        )
    );

    alpha *= camera_mask;

    COLOR = vec4(col, alpha);
}
