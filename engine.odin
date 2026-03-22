package fenrir

import "core:fmt"
import "core:math/linalg"
import SDL "vendor:sdl3"
import GL "vendor:OpenGL"

Engine :: struct {
    window: ^SDL.Window,
    event: SDL.Event,
    gl_context: SDL.GLContext,

    shader: Shader,
    mesh: Mesh,
    light_shader: Shader,
    terrain_shader: Shader,
    texture: Texture,
    camera: Camera,
    light: Light,
    scene: Scene,

    wireframe: bool,
    last_time: f32,
    delta_time: f32,

    terrain_mesh: Mesh,
}

Scene :: struct {
    objects: [dynamic]GameObject,
    lights: [dynamic]Light,
}

cube_positions := [10]vec3 {
    vec3{0.0, 0.0, 0.0},
    vec3{ 2.0,  5.0, -15.0},
    vec3{-1.5, -2.2, -2.5},
    vec3{-3.8, -2.0, -12.3},
    vec3{2.4, -0.4, -3.5},
    vec3{-1.7,  3.0, -7.5},
    vec3{ 1.3, -2.0, -2.5},
    vec3{ 1.5,  2.0, -2.5},
    vec3{ 1.5,  0.2, -1.5},
    vec3{-1.3,  1.0, -1.5}
}

main_loop :: proc(engine: ^Engine) {
    for {
        for SDL.PollEvent(&engine.event) {
            #partial switch engine.event.type {
                case .QUIT:
                    return
                case .MOUSE_MOTION:
                    update_mouse_input(&engine.camera, f64(engine.event.motion.xrel), f64(engine.event.motion.yrel))
                case .MOUSE_WHEEL:
                    zoom_input(&engine.camera, f64(engine.event.wheel.x), f64(engine.event.wheel.y))
            }
        }

        //SDL.Delay(16)
        GL.ClearColor(0.2, 0.3, 0.3, 1.0)
        GL.Clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)

        now := f32(SDL.GetTicks()) / 1000.0
        engine.delta_time = now - engine.last_time
        engine.last_time = now
        
        // render container
        use(&engine.shader)
        set_int(&engine.shader, "material.diffuse", 0)
        set_int(&engine.shader, "material.specular", 1)
        view_loc := GL.GetUniformLocation(engine.shader.id, "view")
        flat_view := linalg.matrix_flatten(engine.camera.view)
        GL.UniformMatrix4fv(view_loc, 1, GL.FALSE, &flat_view[0])

        // Positions of objects
        set_vec3(&engine.shader, "light.position", &engine.light.position)
        set_vec3(&engine.shader, "viewPos", &engine.camera.position)
        
        // Light Properties
        set_vec3(&engine.shader, "light.ambient", &engine.light.ambient_color)
        set_vec3(&engine.shader, "light.diffuse", &engine.light.diffuse_color)
        set_vec3(&engine.shader, "light.specular", &engine.light.specular_color)
        
        // Material Properties
        set_float(&engine.shader, "material.shininess", 64.0)
        
        // View and Projection transformations
        projection := linalg.matrix4_perspective_f32(f32(linalg.to_radians(engine.camera.fov)), f32(SCREEN_WIDTH) / f32(SCREEN_HEIGHT), 0.1, 100.0)
        set_mat4(&engine.shader, "projection", &projection)

        // Bind diffuse Map
        GL.ActiveTexture(GL.TEXTURE0);
        GL.BindTexture(GL.TEXTURE_2D, engine.texture.diffuse_map);
        
        // Bind Specular Map
        GL.ActiveTexture(GL.TEXTURE1);
        GL.BindTexture(GL.TEXTURE_2D, engine.texture.specular_map);

        // Draw gameobjects in the scene
        for &obj in engine.scene.objects {
            draw_object(&obj)
        }
        
        use(&engine.light_shader)
        use(&engine.terrain_shader)
        
        // upload view and projection to light shader
        light_view_loc := GL.GetUniformLocation(engine.light_shader.id, "view")
        GL.UniformMatrix4fv(light_view_loc, 1, GL.FALSE, &flat_view[0])
        set_mat4(&engine.light_shader, "projection", &projection)
        
        terrain_view_loc := GL.GetUniformLocation(engine.terrain_shader.id, "view")
        GL.UniformMatrix4fv(terrain_view_loc, 1, GL.FALSE, &flat_view[0])
        set_mat4(&engine.terrain_shader, "projection", &projection)
        
        update_camera(&engine.camera)
        update_keyboard_input(engine, &engine.camera)
        
        // Color changing of the scene gameobjects
        // update_light(&engine.light)

        //GL.DrawElements(GL.TRIANGLES, 6, GL.UNSIGNED_INT, nil);
        SDL.GL_SwapWindow(engine.window)
    }
}

run :: proc(engine: ^Engine) {
    
    if !init_window(engine) do return
    fmt.println("window ok")
    if !init_shader(&engine.shader, "shaders/transform.vs", "shaders/shader.fs") do return
    fmt.println("shader ok") 
    if !init_shader(&engine.light_shader, "shaders/light.vs", "shaders/light.fs") do return
    fmt.println("light shader ok")
    if !init_shader(&engine.terrain_shader, "shaders/terrain.vs", "shaders/terrain.fs") do return
    fmt.println("terrain shader ok")
    create_mesh_cube(&engine.mesh)
    create_mesh_terrain(&engine.terrain_mesh, 100, 100, 2.0, 0.8)
    fmt.println("mesh ok")
    if !init_light(&engine.light) do return
    fmt.printfln("light ok")
    if !init_texture(&engine.texture) do return
    fmt.println("texture ok")
    if !init_camera(&engine.camera) do return
    fmt.printfln("Camera ok")

    // Creating GameObjects
    terrain := GameObject {
        position = vec3{0.0, 0.0, 0.0},
        rotation_angle = 0,
        rotation_axis = vec3{0.0, 1.0, 0.0},
        scale = vec3{100.0, 100.0, 100.0},
        mesh = &engine.terrain_mesh,
        shader = &engine.terrain_shader
    }
    append(&engine.scene.objects, terrain)


    for i: u32 = 0; i < 10; i += 1 {
        cubes := GameObject {
            position        = cube_positions[i],
            rotation_angle  = 20.0 * f32(i),
            rotation_axis   = vec3{1.0, 0.3, 0.5},
            scale           = vec3{1.0, 1.0, 1.0},
            mesh            = &engine.mesh,
            shader          = &engine.shader
        }
        append(&engine.scene.objects, cubes)
    }

    light := GameObject {
        position = engine.light.position,
        rotation_angle = 1,
        rotation_axis = vec3{1.0, 1.0, 1.0},
        scale = vec3{0.2, 0.2, 0.2},
        mesh = &engine.mesh,
        shader = &engine.light_shader,
    }
    append(&engine.scene.objects, light)

    main_loop(engine)
    cleanup(engine)
    cleanup_mesh(&engine.mesh)
}