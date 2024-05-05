shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
uniform sampler2D texture_1;
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
uniform sampler2D texture_2;
uniform sampler2D texture_3;
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
const vec4 p_o5962_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o5962_metallic = 0.000000000;
const float p_o5962_roughness = 1.000000000;
const float p_o5962_emission_energy = 1.000000000;
const float p_o5962_normal = 1.000000000;
const float p_o5962_ao = 1.000000000;
const float p_o5962_depth_scale = 0.500000000;
float o5962_input_depth_tex(vec2 uv, float _seed_variation_) {
return 0.0;
}
const float p_o9563_amount1 = 0.500000000;
const float p_o93297_translate_x = 0.000000000;
const float p_o93297_translate_y = 0.000000000;
const float p_o93297_rotate = 0.000000000;
const float p_o93297_scale_x = 0.100000001;
const float p_o93297_scale_y = 0.100000001;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o32602_0 = textureLod(texture_1, fract(transform2((uv), vec2(p_o93297_translate_x*(2.0*1.0-1.0), p_o93297_translate_y*(2.0*1.0-1.0)), p_o93297_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o93297_scale_x*(2.0*1.0-1.0), p_o93297_scale_y*(2.0*1.0-1.0)))), 0.0);
vec4 o93297_0_1_rgba = o32602_0;
vec4 o33482_0 = textureLod(texture_2, (uv), 0.0);
vec4 o35367_0 = textureLod(texture_3, (uv), 0.0);
vec4 o9563_0_b = o93297_0_1_rgba;
vec4 o9563_0_l;
float o9563_0_a;

o9563_0_l = o33482_0;
o9563_0_a = p_o9563_amount1*(dot((o35367_0).rgb, vec3(1.0))/3.0);
o9563_0_b = vec4(blend_burn((uv), o9563_0_l.rgb, o9563_0_b.rgb, o9563_0_a*o9563_0_l.a), min(1.0, o9563_0_b.a+o9563_0_a*o9563_0_l.a));

vec4 o9563_0_1_rgba = o9563_0_b;

	vec3 albedo_tex = ((o9563_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o5962_albedo_color.rgb;
	METALLIC = 1.0*p_o5962_metallic;
	ROUGHNESS = 1.0*p_o5962_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o5962_emission_energy;

}



