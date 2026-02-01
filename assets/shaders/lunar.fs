#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define MY_HIGHP_OR_MEDIUMP highp
#else
    #define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP vec4 lunar_color;
extern MY_HIGHP_OR_MEDIUMP number amount;

extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) { return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a); }
    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01;
    float t = time * 10.0 + 2003.;
    vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
    vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));
    float field = (1.+ ( cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) + cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
    vec2 borders = vec2(0.2, 0.8);
    float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14)) - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve) - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve) - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve) - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);
    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) { tex.rgba = burn_colour_1.rgba; }
        else if (burn_colour_2.a > 0.01) { tex.rgba = burn_colour_2.rgba; }
    }
    return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}

// Helper for Glitch effect
extern MY_HIGHP_OR_MEDIUMP vec2 glitched; 

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;
    vec2 pixel_size = 1.0 / image_details;
    
    // --- 1. Find Distance to Nearest Edge (from glitched.fs) ---
    float distance_to_edge = 1000.0;
    vec4 original_pixel = Texel(texture, texture_coords);
    float sprite_alpha = original_pixel.a;
    int search_radius = 3; // Reduced radius for optimization if needed

    for (int x = -search_radius; x <= search_radius; x++) {
        for (int y = -search_radius; y <= search_radius; y++) {
            if (Texel(texture, texture_coords + vec2(x,y) * pixel_size).a != sprite_alpha) {
                distance_to_edge = min(distance_to_edge, length(vec2(x,y)));
            }
        }
    }

    // --- 2. Build the Effect based on Distance ---
    // Use lunar_color for the "Neon" pulse
    float pulse = 0.9 + 0.1 * sin(time * 5.0);
    vec3 glow_color = lunar_color.rgb * 1.5 * pulse; 

    vec4 final_pixel = vec4(0.0);

    if (sprite_alpha > 0.5) {
        // --- INSIDE CARD ---
        // Invert the original sprite's color for that "Dark Mode" look
        // Blend between Original and Inverted based on 'amount' maybe? 
        // For now, let's do partial invert + tint
        vec3 inverted_color = 1.0 - original_pixel.rgb;
        vec3 tinted_center = mix(original_pixel.rgb, inverted_color, 0.7); // 70% Invert
        
        // Add a sweeping "shine" effect
        float shine = smoothstep(0.0, 0.2, 1.0 - abs(uv.x + uv.y - mod(time * 0.5, 2.0)));
        tinted_center += shine * 0.25; 
        
        // Tilt towards lunar color slightly
        tinted_center = mix(tinted_center, lunar_color.rgb, 0.2);

        final_pixel = vec4(tinted_center, 1.0); 

    } else {
        // --- OUTSIDE CARD (Glow) ---
        float glow = 1.0 - (distance_to_edge / float(search_radius));
        glow = pow(max(0.0, glow), 2.0); // Sharper glow falloff
        final_pixel = vec4(glow_color * glow, glow * lunar_color.a); // Use alpha from uniform
    }

    return dissolve_mask(final_pixel * colour, texture_coords, uv);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;
#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){ return transform_projection * vertex_position; }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist)) *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);
    return transform_projection * vertex_position + vec4(0.,0.,0.,scale);
}
#endif
