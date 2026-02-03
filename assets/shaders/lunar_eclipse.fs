#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define MY_HIGHP_OR_MEDIUMP highp
#else
    #define MY_HIGHP_OR_MEDIUMP mediump
#endif

// Uniforms obligatorios
extern MY_HIGHP_OR_MEDIUMP float dissolve;
extern MY_HIGHP_OR_MEDIUMP float time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;
extern MY_HIGHP_OR_MEDIUMP float lunar_suit_id;

// Agregamos el uniform que falta para evitar el crash
extern MY_HIGHP_OR_MEDIUMP vec2 lunar_eclipse;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) { return vec4(shadow ? vec3(0.0,0.0,0.0) : tex.xyz, shadow ? tex.a*0.3: tex.a); }
    float adjusted_dissolve = (dissolve*dissolve*(3.0-2.0*dissolve))*1.02 - 0.01;
    float t = time * 10.0 + 2003.0;
    vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
    vec2 field_part1 = uv_scaled_centered + 50.0*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50.0*vec2(cos( t / 53.1532),  cos( t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50.0*vec2(sin(-t / 87.53218), sin(-t / 49.0000));
    float field = (1.0+ ( cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) + cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.0;
    vec2 borders = vec2(0.2, 0.8);
    float res = (0.5 + 0.5* cos( (adjusted_dissolve) / 82.612 + ( field + -0.5 ) *3.14159)) - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5.0 + 5.0*dissolve) : 0.0)*(dissolve) - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5.0 + 5.0*dissolve) : 0.0)*(dissolve) - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5.0 + 5.0*dissolve) : 0.0)*(dissolve) - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5.0 + 5.0*dissolve) : 0.0)*(dissolve);
    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) { tex.rgba = burn_colour_1.rgba; }
        else if (burn_colour_2.a > 0.01) { tex.rgba = burn_colour_2.rgba; }
    }
    return vec4(shadow ? vec3(0.0,0.0,0.0) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : 0.0);
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

    vec3 suit_color;
    if (abs(lunar_suit_id - 1.0) < 0.1)      suit_color = vec3(0.8, 0.1, 0.2);
    else if (abs(lunar_suit_id - 2.0) < 0.1) suit_color = vec3(0.1, 0.5, 0.2);
    else if (abs(lunar_suit_id - 3.0) < 0.1) suit_color = vec3(0.1, 0.4, 0.7);
    else if (abs(lunar_suit_id - 4.0) < 0.1) suit_color = vec3(0.4, 0.2, 0.5);
    else                                     suit_color = vec3(0.8, 0.6, 0.2);

    float brightness = (tex.r + tex.g + tex.b) / 3.0;

    if (brightness > 0.6) {
        float dist = length(uv - vec2(0.5));
        float moon_mask = smoothstep(0.25, 0.24, dist);
        float shadow_mask = smoothstep(0.21, 0.22, dist); 
        vec3 eclipse_rim = vec3(0.5, 0.2, 0.7); 
        vec3 eclipse_shadow = vec3(0.1, 0.05, 0.15); 
        vec3 final_moon = mix(eclipse_shadow, eclipse_rim, shadow_mask);
        tex.rgb = mix(tex.rgb, final_moon, moon_mask * 0.5);
    } else {
        tex.rgb = suit_color;
    }

    // --- ANTI-OPTIMIZACIÓN (Uso forzado de lunar_eclipse) ---
    float dummy = lunar_eclipse.x * 0.000001;
    return dissolve_mask(tex * colour + dummy, texture_coords, uv);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.0) { return transform_projection * vertex_position; }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale_val = 0.2*(-0.03 - 0.3*max(0.0, 0.3-mid_dist)) *hovering*(length(mouse_offset)*length(mouse_offset))/(2.0 -mid_dist);
    return transform_projection * vertex_position + vec4(0.0,0.0,0.0,scale_val);
}
#endif