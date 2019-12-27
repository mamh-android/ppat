uniform mediump vec4 fm_light_diffuse_color;
uniform mediump vec4 fm_delta_diffuse_color;

uniform sampler2D fm_diffuse_reflectance_texture; // specular roughness in alpha
uniform sampler2D fm_normal_map_texture;
uniform sampler2D fm_detail_map_texture;
uniform samplerCube fm_ambient_specular_cube_texture;
uniform mediump vec4 fm_delta_specular_scale;
uniform mediump vec4 fm_normal_map_scale;
uniform mediump vec4 fm_texture_scale;

varying mediump vec3 v_normal;
varying mediump vec3 v_tangent;
varying mediump vec3 v_binormal;
varying mediump vec3 v_view_direction;
varying mediump vec3 v_light_direction;
varying mediump vec2 v_texcoord;

void main(void)
{
    mediump vec3 normal = normalize(v_normal);
    mediump vec3 tangent = normalize(v_tangent);
    mediump vec3 binormal = normalize(v_binormal);
    mediump vec3 view_direction = normalize(v_view_direction);
    mediump vec3 light_direction = normalize(v_light_direction);

    mediump vec4 normal_sample = texture2D(fm_normal_map_texture,  v_texcoord);
    mediump vec4 micro_sample = texture2D(fm_detail_map_texture,  v_texcoord * fm_texture_scale.x);
    mediump vec3 texnormal = (normal_sample.xyz * 2.0 - 1.0) + (micro_sample.xyz * 2.0 - 1.0);

    normal = normalize(
       (texnormal.z * normal) +
       (fm_normal_map_scale.x * texnormal.y * binormal) +
       (fm_normal_map_scale.x * texnormal.x * tangent));

    mediump vec3 reflect_direction = normalize(reflect(-view_direction, normal));
    mediump vec4 diffuse_color  = texture2D(fm_diffuse_reflectance_texture,  v_texcoord);
    mediump vec4 specular_color = textureCube(fm_ambient_specular_cube_texture, reflect_direction);
    mediump float dotln = dot(light_direction, normal);

    mediump float specular_percent = diffuse_color.a * fm_delta_specular_scale.x * clamp(dotln, 0.8, 1.0);

    // Add lighting to base color and mix
    mediump vec4 env_color = diffuse_color * fm_delta_diffuse_color;
    mediump vec4 ambient = env_color * fm_light_diffuse_color;
    gl_FragColor.rgb = (env_color.rgb + (specular_color.rgb * specular_percent)) * clamp(dotln, 0.4, 1.0) + ambient.rgb;
    gl_FragColor.a  = 1.0;
}
 