// SimulationMark Fragment Shader 
// Shader Test 4: Advanced world geometry
// Version 1.0
// Copyright 2007 Futuremark Corporation. All rights reserved.

#define ECSH (1.0 / 3.1415926535897932384626433832795)

const lowp int          Li = 2;                            // constant 'Light count'

uniform mediump float   fm_delta_specular_roughness;       // constant 'Surface roughness'
//uniform mediump float fm_delta_specular_isotropy;        // constant 'Surface isotropy'
uniform mediump vec4    fm_light_specular_color;           // constant 'Specular color'
uniform mediump vec4    Cvn;                               // constant 'Fresnel color'

uniform sampler2D       fm_diffuse_reflectance_texture;    // 'Surface diffuse reflectance texture'
uniform sampler2D       fm_specular_reflectance_texture;   // 'Surface specular reflectance texture'
uniform sampler2D       fm_normal_map_texture;             // 'Surface normal texture'
uniform samplerCube     fm_ambient_specular_cube_texture;  // 'Surface ambient specular texture'
uniform mediump vec3    fm_light_diffuse_color[Li];        // 'Light color (array)'
uniform mediump vec4    fm_ambient_diffuse_color;


varying mediump vec2  v_T2d;     // 'Surface texture coordinate'
varying mediump vec3  v_N0w;     // 'Normal direction, before normalization and bump'
varying mediump vec3  v_Tw;      // 'Tangent direction'
varying mediump vec3  v_L0w[Li]; // 'Light direction, before normalization'
varying mediump vec3  v_V0w;     // 'View direction, before normalization'

void main(void)
{
    mediump vec3  Vw  = normalize(v_V0w);                                         // view_direction
    mediump vec3  Ns  = texture2D(fm_normal_map_texture, v_T2d).xyz * 2.0 - 1.0;  // sample_normal 
    mediump vec3  Bw  = normalize(cross(v_N0w, v_Tw));                            // bitangent
    mediump vec3  Nw  = normalize(Ns.x * v_Tw + Ns.y * Bw + Ns.z * v_N0w);        // normal_direction

    mediump float Vn  = clamp(dot(Vw,  Nw), 0.0, 1.0);                            // v_dot_n
    mediump vec3  R   = 2.0 * Vn * Nw - Vw;                                       // reflection_vector 
    mediump vec4  Svn = fm_light_specular_color + Cvn * vec4(pow(1.0 - Vn, 5.0)); // spectral_specular_factor

    mediump vec4  Crd  = texture2D  (fm_diffuse_reflectance_texture, v_T2d);      // diffuse_surface_factor
    mediump vec4  Crs  = texture2D  (fm_specular_reflectance_texture, v_T2d);     // specular_surface_factor
    mediump vec4  Casc = textureCube(fm_ambient_specular_cube_texture, R);        // specular_ambient_factor
    mediump vec4  Cas  = Crs * Casc * Svn;                                        // ambient_specular_color

    // Light loop 
    mediump vec4  Cdd  = vec4(0.0, 0.0, 0.0, 0.0);
    mediump vec4  Cds  = vec4(0.0, 0.0, 0.0, 0.0);
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    for(lowp int i = 0; i < Li; ++i)
    {
        mediump vec3 v_L0wi = v_L0w[i];

        // Triangle must face the light in order to get light shading
        if(dot(v_L0wi, v_N0w) >= 0.0)
        {
            mediump vec3  Lw   = normalize(v_L0wi);                // light_direction
            mediump vec3  Hw   = normalize(Lw + Vw);               // half_direction
            mediump float Ln   = clamp(dot(Lw, Nw), 0.0, 1.0);     // l_dot_n
            mediump float Hn   = dot(Hw, Nw);                      // h_dot_n
            mediump float Ht   = dot(Hw - dot(Hw, Nw) * Nw, v_Tw); // h_dot_t
            mediump float Gvn  = 1.0 / (fm_delta_specular_roughness - (fm_delta_specular_roughness * Vn) + Vn);      // geometric_v_dot_n
            mediump float Gln  = Ln  / (fm_delta_specular_roughness - (fm_delta_specular_roughness * Ln) + Ln);      // geometric_l_dot_n
            mediump float Hn2  = Hn * Hn;                                           // \
            mediump float Zhn0 = (1.0 + (fm_delta_specular_roughness * Hn2) - Hn2); //  > directional_zenith
            mediump float Zhn  = fm_delta_specular_roughness / (Zhn0 * Zhn0);       // /
            mediump vec4  D    = vec4(Gvn * Gln * Zhn);                             // specular_directional 
            Cdd               += fm_ambient_diffuse_color * Crd * vec4(Ln);                 // delta_diffuse_color
            Cds               += vec4(fm_light_diffuse_color[i], 1.0) * Crs * Svn * D;      // delta_specular_color 
            gl_FragColor      += vec4(fm_light_diffuse_color[i], 1.0) * Crs * Svn * D;  //vec3(Ln) * fm_light_diffuse_color[i];
        }
    }
    gl_FragColor = Cas + Cdd + ECSH * Cds;
}
