shader_type canvas_item;

uniform int arms = 8;
uniform int squares_per_arm = 12;
uniform float swirl_speed = 1.0;
uniform float square_size = 0.01;
uniform float min_brightness = 0.3; // Dim stars
uniform float max_brightness = 1.0; // Bright stars
uniform float arm_jitter = 0.03;    // Random offset from arm

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5);
    float t = TIME * swirl_speed;
    float intensity = 0.0;

    for (int a = 0; a < arms; a++) {
        float base_angle = float(a) * 6.2831 / float(arms); // 2π/arms

        for (int s = 0; s < squares_per_arm; s++) {
            float fi = float(s);
            float radius = (fi + 1.0) / float(squares_per_arm);
            float spiral_twist = radius * 2.0;
            float angle = base_angle + spiral_twist + t;

            vec2 pos = center + vec2(cos(angle), sin(angle)) * radius * 0.5;

            // Offset randomly
            vec2 offset = vec2(
                rand(vec2(float(a), fi * 2.123)) - 0.5,
                rand(vec2(float(a), fi * 3.456)) - 0.5
            ) * arm_jitter;
            pos += offset;

            // Static brightness per star
            float brightness_seed = rand(vec2(float(a), fi));
            float brightness = mix(min_brightness, max_brightness, brightness_seed);

            // Draw square
            if (abs(uv.x - pos.x) < square_size && abs(uv.y - pos.y) < square_size) {
                intensity += brightness;
            }
        }
    }

    COLOR = vec4(vec3(intensity), intensity);
}
