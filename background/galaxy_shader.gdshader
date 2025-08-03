shader_type canvas_item;

uniform vec3 star_color = vec3(0.0, 0.1, 0.2);
uniform float scale = 150.0;
uniform float rot_speed = -0.1;
uniform float alpha = 0.2;
uniform float shine = 2.0;

#define ENABLE_SHINE true
#define ENABLE_SPIRAL true

float rand(in vec2 st) {
  vec2 r = fract(sin(st) * 2.7644437);
  return fract(r.y * 276.44437 + r.x);
}

float particles(in vec2 st) {
  float r = rand(floor(st));
  return smoothstep(0.995, 1.0, r) * max(0.0, sin(r * 34433.0 + TIME));
}

vec3 avg(in vec2 st, in float a) {
  #define p(st) particles(st)
  vec2 A = vec2(0.0, a);
  return star_color * (p(st) + p(st + A) + p(st + A.yx) + p(st - A) + p(st - A.yx));
}

vec3 stars(in vec2 st) {
  vec3 color = vec3(0.0);

  if (ENABLE_SHINE) {
	for (float i = 5.0; i > 0.0; --i) {
		color += mix(color, avg(st, i), 1.5);
  	}
  }

  return shine * color + p(st);
}

void fragment() {
	// Normalize uv
	vec2 uv = SCREEN_UV.xy;
	float aspect_ratio = (SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y);
	uv.x /= aspect_ratio;

	// Center it
	vec2 st_unscaled = (uv - vec2(0.5 / aspect_ratio, 0.5));
	vec2 st = st_unscaled * scale;
	float norm_dist = length(st_unscaled);

	// Star effect
	vec3 color;
    if (ENABLE_SPIRAL) {
		// --- Spiral Transformation Begin ---
	  	float r = length(st);
	  	float angle = atan(st.y, st.x);

	  	// Per-star angular velocity based on random seed and distance
	  	float starRand = rand(floor(st));
	  	float distFactor = mix(0.5, 1.5, norm_dist);
		float rotSpeed = rot_speed * distFactor;
	  	float theta = TIME * distFactor;

	  	// Spiral by rotating position
	  	angle -= rotSpeed * theta;

	  	// New UV after spiral rotation
	  	st = r * vec2(cos(angle), sin(angle));
	  	// --- Spiral Transformation End ---

		color = stars(st);
	} else {
  		color = stars(st);
	}

    COLOR = vec4(color, alpha);
}
