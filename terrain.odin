package fenrir

import "core:fmt"
import GL "vendor:OpenGL"

generate_terrain_heights :: proc(engine: ^Engine) {
    BAKE_SIZE :: 256

    engine.terrain_heights = make([]f32, BAKE_SIZE * BAKE_SIZE)
    for i: u32 = 0; i < BAKE_SIZE; i += 1 {
        for j: u32 = 0; j < BAKE_SIZE; j += 1 {
            x := f32(i) / f32(BAKE_SIZE) * 100.0
            z := f32(j) / f32(BAKE_SIZE) * 100.0
            engine.terrain_heights[i * BAKE_SIZE + j] = max(sample_height(x, z), 0.0)
        }
    }

    // Find actual range
    min_h := engine.terrain_heights[0]
    max_h := engine.terrain_heights[0]
    for h in engine.terrain_heights {
        if h < min_h do min_h = h
        if h > max_h do max_h = h
    }
    fmt.println("terrain height range - min:", min_h, "max:", max_h)

    // Upload as R32F texture to GPU
    GL.GenTextures(1, &engine.heightmap_texture)
    GL.BindTexture(GL.TEXTURE_2D, engine.heightmap_texture)
    GL.TexImage2D(
        GL.TEXTURE_2D, 0, GL.R32F,
        BAKE_SIZE, BAKE_SIZE, 0,
        GL.RED, GL.FLOAT,
        &engine.terrain_heights[0],
    )
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE)

    fmt.println("heightmap texture uploaded, id:", engine.heightmap_texture)
}