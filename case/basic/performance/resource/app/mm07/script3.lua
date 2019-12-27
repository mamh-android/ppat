--[[
  script.lua -- 3DMarkMobile ES 2.0 main configuration and control script

  Most options needed by users are in table 'config' at the beginning of the file.
  Feel free to customize this script for your needs. This script should allow
  creating custom 3DMarkMobile runs with different combinations of tests and settings as well as looping
  for demo and stress testing purposes.

  Conventions:
    - 3DMarkMobile subsystems are wrapped in Lua objects and are called with convention: subsystem_name.function_name
    - C functions that do not belong to any 3DMarkMobile subsystem wrapped in Lua object are prefixed with c_ 
    - Most lua functions and variables are placed in tables.

  LUA tables in this script:
    - Config                    Most common 3DMarkMobile configuration variables
    - Game tests                Game test parameters
    - Advanced world test       Advanced world test parameters
    - Batch test                Batch test parameters
    - Texture filtering test    Texture filtering test parameters
    - Unified shader test       Unified shader test parameters
    - Post processing test      Post processing test parameters
    - Menu                      Menu routines, structure and variables
    - Application               create, resume, wait, configure, init, deinit, exit, coroutine_src (high level control of application)
--]]


game_tests = {
    {
        title     = "Intro";
        hud_color = { 1.0, 1.0, 1.0 };
        fms_file  = "/sdcard/mm07/intro.fms";

        cuts = {
            { "intro", "simple_composer",       "Camera",      1,    165, 0.66}
        };
    };
    {
        title     = "Taiji";
        hud_color = { 1.0, 1.0, 1.0 };
        fms_file  = "/sdcard/mm07/taiji.fms";

        cuts = {
            { "taiji", "bloom_composer",        "Camera1",     70,   132, 1.0 },
            { "taiji", "bloom_dof_composer",    "Camera2",    128,   183, 1.0 },
            { "taiji", "bloom_composer",        "Camera3",    180,   297, 1.0 },
            { "taiji", "bloom_dof_composer",    "Camera4",    290,   337, 1.0 },
            { "taiji", "bloom_composer",        "Camera5",    333,   452, 1.0 },
            { "taiji", "bloom_composer",        "Camera6",    448,   512, 1.0 },
            { "taiji", "bloom_composer",        "Camera7",    508,   577, 1.0 },
            { "taiji", "bloom_composer",        "Camera8",    573,   782, 1.0 },
            { "taiji", "bloom_composer",        "Camera9",    778,   952, 1.0 },
            { "taiji", "bloom_composer",        "Camera10",   948,  1092, 1.0 },
            { "taiji", "bloom_composer",        "Camera11",  1088,  1162, 1.0 },
            { "taiji", "bloom_composer",        "Camera12",  1158,  1414, 1.0 }
        };
    };
    {
        title     = "Hoverjet";
        hud_color = { 1, 1, 1 };
        fms_file  = "/sdcard/mm07/hover.fms";

        cuts = 
        {
            { "hover", "simple_composer", "Camera2",     0,    75,  1.0 },
            { "hover", "simple_composer", "Camera3",    92,   145,  1.0 },
            { "hover", "simple_composer", "Camera15",   140,   210,  1.0 },
            { "hover", "simple_composer", "Camera4",   206,   261,  1.0 },
            { "hover", "motionblur",        "Camera1",   257,   310,  1.0 },
            { "hover", "simple_composer", "Camera5",   307,   341,  1.0 },
            { "hover", "motionblur",        "Camera1",   336,   402,  1.0 },
            { "hover", "simple_composer", "Camera6",   398,   447,  1.0 },
            { "hover", "simple_composer", "Camera7",   482,   548,  1.0 },
            { "hover", "motionblur",        "Camera1",   542,   645,  1.0 },
            { "hover", "simple_composer", "Camera9",   640,   704,  1.0 },
            { "hover", "motionblur",        "Camera1",   700,   840,  1.0 },
            { "hover", "simple_composer", "Camera10",  836,   908,  1.0 },
            { "hover", "motionblur",        "Camera1",   901,  1091,  1.5 },
            { "hover", "simple_composer", "Camera12", 1085,  1174,  1.0 },
            { "hover", "simple_composer", "Camera11", 1170,  1221,  1.0 },
            { "hover", "simple_composer", "Camera13", 1217,  1285,  1.0 },
            { "hover", "motionblur",        "Camera17",  1280,  1395,  1.0 },
            { "hover", "simple_composer", "Camera14", 1390,  1430,  1.0 },
            { "hover", "motionblur",        "Camera1",  1420,  1500,  1.0 }
        };
    };
}

config = 
{
    -- Screen configuration
    posx          =    0;
    posy          =    0;
    
    width         =  320;
    height        =  480;
    orientation   =    0;

    vp_width      =    0;
    vp_height     =    0;
    fullscreen    =    1;
    swap_control  =    0;

    red_size      =   8;
    green_size    =   8;
    blue_size     =   8;
    alpha_size    =   0;
    stencil_size  =   0;
    depth_size    =  24;
    fsaa_samples  =   0;
    anisotropy    =   1;

    -- Amount of memory for oes engine. Not much.
    -- Shader sources must fit here.
    oes_res_stack_size = 1 * 1024 * 1024;

    -- Amount of memory for application.
    -- If frames are saved to files, frame buffer must fit here.
    app_res_stack_size =  2 * 1024 * 1024;

    -- Amount of memory for data file loading.
    -- Index and vertex buffers must fit here is VBO is not supported.
    -- Animation data
    -- Batches
    -- Materials
    -- Scenes: objects, lights, cameras, bones, nulls, ....
    -- One mipmap level of texture must fit here.
    io_res_stack_size  = 14 * 1024 * 1024;

    featuretest_res_stack_size = 4 * 1024 * 1024;

    allow_seek         =    1; -- for benchmarking this should be 0
    camera_speed       = 20.0;
    max_texture_size   = 4096;

    show_intro         = true;
    show_menu          = false; -- TODO MUSTFIX Known issue: false does not work quite properly yet
    show_fm_logo       = false;
    use_postprocessing =  true;

    --frames_per_second = 5; -- Default setting for benchmarking is 5
    --write_frames = 4;
}

-- --------------------------------------------------------------------------

app =
{
    xsi             = 0;
    running         = true;
    game_test_index = -1;
    cut_index       = -1;
    intro_showed    = false;
    loaded_fms      = nil;
    phase           = nil;

    convert = function()
        c_load_image("Pictures/font2.png",      "alpha", "GL_TEXTURE_2D", "GL_TEXTURE_2D");
        c_load_image("Pictures/futuremark.tga", "rgb",   "GL_TEXTURE_2D", "GL_TEXTURE_2D");
    end;

    create = function()
        local system_interface_id        = c_si_get_system_interface_id()
        local system_interface_id_last_4 = string.sub(system_interface_id, -4)

        if(system_interface_id_last_4 == "/XSI") then
            app.xsi = 1;
        end

        app.coroutine = coroutine.create(
            function()
                while(app.running)
                do
                    if(app.intro_showed == false) then
                        if(config.show_intro == true) then
                            app.run_intro()
                        end
                        app.intro_showed = true
                    end

                    if(config.show_menu == true) then
                        c_enter_menu()
                        app.wait()
                        if app.phase ~= nil then
                            app.phase()
                            app.phase = nil
                        end
                    else
                        app.run_all_test()
                        c_exit()
                    end
                end
            end
        )
    end;

    resume = function()
        coroutine.resume(app.coroutine)
    end;

    wait = function()
        coroutine.yield()
    end;

    configure = function()
    end;

    init = function()
        if(app.xsi == 1) then
            c_load_xsi()
            config.show_intro = false
            config.show_menu = false
            app.preprocess_cuts()
        else
            if(config.show_intro) then
                app.load_fms(game_tests[1].fms_file)
            else
                app.load_fms(game_tests[2].fms_file)
            end
        end
    end;

    deinit = function()
        app.unload_fms()
    end;

    exit = function() 
        app.running = false
        c_exit()
    end;

    load_fms = function(fms_filename)
        if(app.loaded_fms == fms_filename) then
            return
        end
        app.unload_fms()

        c_msg("Loading " .. fms_filename .. "\n")
        c_load_fms(fms_filename)
        c_init_fonts()
        app.loaded_fms = fms_filename
    end;

    unload_fms = function()
        if app.loaded_fms ~= nil then
            c_msg("Unloading " .. app.loaded_fms .. "\n")
            c_deinit_fonts()
            c_unload_fms()
            app.loaded_fms = nil
        end
    end;

    preprocess_cuts = function()
        local gt_cuts = app.game_test.cuts
        for j, w in ipairs(gt_cuts) do
            w.scene_index = c_name_to_scene(w[1])
            if(w.scene_index == 0xffffffff) then
                c_msg("Scene " .. w[1] .. " not found.\n")
                c_exit()
            end

            composer_name = w[2]
            if(config.use_postprocessing == false) then
                composer_name = "simple_composer"
            end
            w.composer_index = c_name_to_composer(w.scene_index, composer_name)
            w.camera_index   = c_name_to_camera(w.scene_index, w[3])
            if(w.composer_index == 0xffffffff) then
                c_msg("Composer " .. composer_name .. " not found.\n")
                c_exit()
            end
            if(w.camera_index == 0xffffffff) then
                c_msg("Camera " .. w[3] .. " not found.\n")
                c_exit()
            end
        end
    end;

    enter_game_test = function()
        app.game_test = game_tests[app.game_test_index]

        local name = app.game_test.title
        local r = app.game_test.hud_color[1]
        local g = app.game_test.hud_color[2]
        local b = app.game_test.hud_color[3]

        app.load_fms(app.game_test.fms_file)
        app.preprocess_cuts()
        app.cut_index = 0

        c_enter_game_test(name, r, g, b)
    end;

    run_intro = function()
        c_msg("Running intro...\n")
        app.game_test_index = 1
        app.enter_game_test()
        c_show_hud(0)
        c_pause(0)
        app.wait()
        c_msg("Done\n")
    end;
    
    run_all_test = function()
        c_msg("Running all tests...\n")

        for i, v in ipairs(menu.entries) do
	    c_msg(v.title);
	    c_msg("...\n");
            v.run()
        end

        c_msg("Done\n")
    end;

    update_cut = function()
        local seek_type = 0 -- normal next cut, no wrap

        if(app.cut_index > # game_tests[app.game_test_index].cuts) then
            app.cut_index = 1
            seek_type     = 1 -- wrap from last to first cut
            c_end_game_test(app.game_test.title)
            return
        end

        if(app.cut_index < 1) then
            app.cut_index = # game_tests[app.game_test_index].cuts
            seek_type     = 2 -- wrap from first to last cut
            c_end_game_test(app.game_test.title)
            return
        end
        
        if(app.cut_index < 1 or app.cut_index > # game_tests[app.game_test_index].cuts) then
            c_msg("Lua: cut_index = " .. app.cut_index .. " is not valid\n")
            c_end_game_test(app.game_test.title)
        else
            local c = app.game_test.cuts[app.cut_index]

            c_update_cut(
                app.cut_index,    -- 1
                c.scene_index,    -- 2
                c.composer_index, -- 3
                c.camera_index,   -- 4
                c[4],             -- 5 first frame
                c[5],             -- 6 last frame
                c[6]              -- 7 speed
            )
        end
    end;

    get_next_cut = function()
        app.seek_direction = 1
        app.cut_index = app.cut_index + 1
        app.update_cut()
    end;

    get_prev_cut = function()
        app.seek_direction = -1
        app.cut_index = app.cut_index - 1
        app.update_cut()
    end
}

menu =
{
    background_image = "Pictures/futuremark.tga";
    background_color = { 0.0, 0.0, 0.0 };
    text_color       = { 1.0, 1.0, 1.0 };
    title            = "3DMarkMobile ES 2.0 BDP";

    build = function()
        for i, v in ipairs(menu.entries) do
            c_menu_line(v.title, 0)
        end
    end;

    entries =
    {
        {
            title = "Game test: Taiji";
            enter = function()
                app.phase = menu.entries[1].run
            end;
            run = function()
                app.game_test_index = 2
                app.enter_game_test()
                c_show_hud(0)
                c_pause(0)
                app.wait()
            end;
        };

        {
            title = "Game test: Hover";
            enter = function()
                app.phase = menu.entries[2].run
            end;
            run = function()
                app.game_test_index = 3
                app.enter_game_test()
                c_show_hud(0)
                c_pause(0)
                app.wait()
            end;
        };

        {
            title = "Feature test: SimulationMark 'Advanced World'";
            enter = function()
                app.phase = menu.entries[3].run
            end;
            run = function()
                app.load_fms("/sdcard/mm07/feature_tests.fms")
                c_enter_advanced_world_test(
                    advanced_world_params.gridX,
                    advanced_world_params.gridY
                )
                app.wait()
            end;
        };

        {
            title = "Feature test: Batch count";
            enter = function()
                app.phase = menu.entries[4].run
            end;
            run = function()
                c_msg("Lua: starting batch test\n")
                app.load_fms("/sdcard/mm07/feature_tests.fms")
                c_enter_batch_test(batch_params.gridX, batch_params.gridY)
                app.wait()
            end;
        };

        {
            title = "Feature test: Texture filtering and anti-aliasing";
            enter = function()
                app.phase = menu.entries[5].run
            end;
            run = function()
                c_msg("Lua: texture filtering test\n")
                app.load_fms("/sdcard/mm07/feature_tests.fms")
                c_enter_texture_filtering_test(
                    texture_filtering.texture_name,
                    texture_filtering.image_quality_shape,
                    texture_filtering.vertex_shader,
                    texture_filtering.fragment_shader,
                    texture_filtering.texture_filter,
                    texture_filtering.color_mipmaps
                )
                app.wait()
            end;
        };

        {
            title = "Feature test: Unified shader";
            enter = function()
                app.phase = menu.entries[6].run
            end;
            run = function()
                app.load_fms("/sdcard/mm07/feature_tests.fms")
                unified_shader_params.do_test();
            end;
        };

        {
            title = "Exit";
            enter = function()
                app.exit()
            end;
            run = function()
                app.exit()
            end;
        };
    }
}


postprocessing_test_menu_entry =
{
    title = "Feature test: Post processing";
    enter = function()
        app.phase = menu.entries[7].run
    end;
    run = function()
        app.load_fms("/sdcard/mm07/feature_tests.fms")
        c_enter_post_process_test(
            post_process_params.grid_vertices_x, 
            post_process_params.grid_vertices_y,
            post_process_params.grid_pixels_x,
            post_process_params.grid_pixels_y,
            post_process_params.vertex_shader,
            post_process_params.fragment_shader,
            post_process_params.blur_vertex_shader,
            post_process_params.blur_fragment_shader,
            post_process_params.combine_vertex_shader,
            post_process_params.combine_fragment_shader,
            post_process_params.star_glow_vertex_shader,
            post_process_params.star_glow_fragment_shader,
            post_process_params.num_bloom_layers,
            post_process_params.down_scale_factor,
            post_process_params.original_image_weight,
            post_process_params.blurred_image_weight,
            post_process_params.luminance,
            post_process_params.num_star_lines,
            post_process_params.num_line_passes,
            post_process_params.line_attenuation_factor
        )
        app.wait()
    end;
}




---------------------------------------------------------------
--      Feature test parameters
---------------------------------------------------------------

---------------------------------------------------------------
--      Advanced world test
---------------------------------------------------------------
advanced_world_params = 
{
    -- Number of geometry grid vertices
    gridX = 5;
    gridY = 5;
    
    -- Surface roughness
    roughness = 0.030970;
    
    -- Specular, fresnel and ambient colors
    specular_color = {0.75, 0.55, 0.30};
    fresnel_color  = {0.15, 0.35, 0.70};
    ambient_color  = {0.80, 0.80, 0.80};  -- ambient diffuse
   
    -- Light colors
    light0_color = {1.0, 1.0, 1.0};
    light1_color = {0.2, 0.35, 1.0};
    
    -- Light velocities
    light0_velocity = 10.0;
    light1_velocity = 10.0;
    
    -- Textures
    diffuse_texture     = "Pictures/Fieldstone.tga";
    normalmap_texture   = "Pictures/FieldstoneBumpDOT3.tga";
    specular_texture    = "Pictures/noise2_ts.tga";
    cubemap_texture     = "Pictures/pondwinter.jpg";
    
    -- Shader paths
    vertex_shader   = "/sdcard/mm07/shaders/adv_world.vert";
    fragment_shader = "/sdcard/mm07/shaders/adv_world.frag";
}

---------------------------------------------------------------
--      Batch test
---------------------------------------------------------------
batch_params =
{
    -- Number of geometry grid vertices
    gridX = 22;
    gridY = 22;

    --[[ 
        Following indices can be used to select which shaders are used
        in batch test and in which order they are drawn into the batch
        grid. Here's a list of current batch test shaders, by index number.
    
        0  - texture mapping
        1  - texture mapping + vertex colors
        2  - vertex colors
        3  - texture + texture transform (zoom)
        4  - texture + vertex colors + texture transform
        5  - no texture, single color
        6  - alpha texturing
        7  - alpha texturing + vertex colors
        8  - noise
    --]]

    -- Number of shaders in batch grid
    -- Shaders and the order of shaders in the batch grid.
    -- The count of shader indices in array must be equal to the number above.
    -- shaderIndices = {0, 1, 2, 3, 4, 5, 6, 7, 8};
    -- shaderIndices = {1, 2, 3, 4, 5, 6, 7, 8};
    shaderIndices = {1, 2, 3, 4, 5, 6, 7, 8};
    numShaders = 8;

    -- Parameters per shader.
    shaderParameters = 
    {
        -- 0  - texture mapping
        {
            texDiffuse      = "Pictures/fm_logo.png";
            vertex_shader   = "/sdcard/mm07/shaders/batchtest00.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest00.frag";
        };

        -- 1  - texture mapping + vertex colors
        {
            texDiffuse      = "Pictures/fm_logo.png";
            vertex_shader   = "/sdcard/mm07/shaders/batchtest01.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest01.frag";
        };

        -- 2  - vertex colors
        {
            vertex_shader   = "/sdcard/mm07/shaders/batchtest02.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest02.frag";
        };

        -- 3  - texture mapping + texture transform
        {
            texDiffuse      = "Pictures/fm_logo.png";
            velRotation     = 1.0;
            velScale        = 0.3;
            dScale          = 3.0;
            vertex_shader   = "/sdcard/mm07/shaders/batchtest03.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest03.frag";
        };

        -- 4  - texture mapping + vertex colors + texture transform
        {
            texDiffuse      = "Pictures/fm_logo.png";
            velRotation     = 1.0;
            velScale        = 0.3;
            dScale          = 3.0;
            vertex_shader   = "/sdcard/mm07/shaders/batchtest04.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest04.frag";
        };

        -- 5  - no texture, single color
        {
            vertex_shader   = "/sdcard/mm07/shaders/batchtest05.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest05.frag";
        };

        -- 6  - alpha texturing
        {
            texDiffuse      = "Pictures/noise2_ts.png";
            vertex_shader   = "/sdcard/mm07/shaders/batchtest06.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest06.frag";
        };

        -- 7  - alpha texturing + vertex colors
        {
            texDiffuse      = "Pictures/noise2_ts.png";
            vertex_shader   = "/sdcard/mm07/shaders/batchtest07.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest07.frag";
        };

        -- 8  - noise
        {
            texDiffuse      = "Pictures/noise2_ts.png";
            vertex_shader   = "/sdcard/mm07/shaders/batchtest08.vert";
            fragment_shader = "/sdcard/mm07/shaders/batchtest08.frag";
        };
    };
}

texture_filtering = 
{
    texture_name        = "Pictures/filter_test_image_cm.tga";
    image_quality_shape = 80;
    vertex_shader       = "/sdcard/mm07/shaders/texturefiltertest.vert";
    fragment_shader     = "/sdcard/mm07/shaders/texturefiltertest.frag";
    texture_filter      = 0;
    color_mipmaps       = 0;
}



---------------------------------------------------------------
--      Unified Shader test
---------------------------------------------------------------
unified_shader_params = 
{
    -- The number of load steps. If smaller than 1, only one step is used with minimum load
    ----------------------------------------------------------------------------------------

    vertices_load_steps = 3;
    pixels_load_steps = 3;

    -- Load parameters
    --------------------------
    iteration_vertices_max = 100;
    iteration_vertices_min = 10;

    iteration_pixels_max = 100;
    iteration_pixels_min = 10;

    grid_vertices_x = 100;
    grid_vertices_y = 100;

    grid_pixels_x = 200;
    grid_pixels_y = 200;

    vertex_shader   = "/sdcard/mm07/shaders/unified_shader.vert";
    fragment_shader = "/sdcard/mm07/shaders/unified_shader2.frag";

    iterations_vs = 128;
    iterations_ps = 64;
    texture_sample_count = 10;

    -- only 64 and 512 are currently supported for palette size
    palette_size = 64;
    palette_anim_vel = 1.0;
    palette_tex = "";

    frag_vert_blend = 0.5;
}

---------------------------------
-- Unified shader test functions
---------------------------------

function unified_shader_params.do_test()
    u = unified_shader_params
    
    -- compute steps
    if u.vertices_load_steps < 2 then
        u.vertices_load_steps = 1
        v_step = u.iteration_vertices_max
    else
        v_step = (u.iteration_vertices_max - u.iteration_vertices_min) / (u.vertices_load_steps - 1)
    end

    if u.pixels_load_steps < 2 then
        u.pixels_load_steps = 1
        p_step = u.iteration_pixels_max
    else
        p_step = (u.iteration_pixels_max - u.iteration_pixels_min) / (u.pixels_load_steps - 1)
    end

    for v = u.iteration_vertices_min, u.iteration_vertices_max, v_step do
        u.iterations_vs = v
        for p = u.iteration_pixels_min, u.iteration_pixels_max, p_step do
            u.iterations_ps = p
            c_enter_unified_shader_test()
            app.wait()
        end
    end
end


-------------------------------------
--  Post procesing test
------------------------------------

post_process_params = 
{
    grid_vertices_x = 100;
    grid_vertices_y = 100;
    
    grid_pixels_x = 208;
    grid_pixels_y = 176;
    
    -- Base shader for rendering
    vertex_shader	= "/sdcard/mm07/shaders/1_Tex.vert";
    fragment_shader	= "/sdcard/mm07/shaders/1_Tex.frag";
    
    -- Gaussian blur shaders, HVBlur is combined version of HBlur & VBlur
    blur_vertex_shader    = "/sdcard/mm07/shaders/1_Mirror_Tex.vert";
    blur_fragment_shader  = "/sdcard/mm07/shaders/HVBlur.frag";
    -- blur_fragment_shader = "/sdcard/mm07/shaders/HBlur.frag";
    -- blur_fragment_shader = "/sdcard/mm07/shaders/VBlur.frag";

    -- Combine shader, combines two textures
    combine_vertex_shader   = "/sdcard/mm07/shaders/1_Mirror_Tex.vert";
    combine_fragment_shader = "/sdcard/mm07/shaders/combine.frag";
    
    -- Star glow shader, creates stars to bright spots in image
    star_glow_vertex_shader     = "/sdcard/mm07/shaders/1_Mirror_Tex.vert";
    star_glow_fragment_shader   = "/sdcard/mm07/shaders/StarGlow.frag";
    
    -- Number of down scaling passes and scaling amount per pass
    num_bloom_layers  = 3;
    down_scale_factor = 2.0;
    
    -- Weights when combining final post processed image to original scene
    original_image_weight = 1.0;
    blurred_image_weight  = 1.0;

    -- Brightness    
    luminance = 0.065;
    
    -- Star glow parameters, set values to zero to disable star glow
    num_star_lines          = 6;
    num_line_passes         = 3;
    line_attenuation_factor = 0.98;
}


