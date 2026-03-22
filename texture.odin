package fenrir

import "core:log"
import GL "vendor:OpenGL"
import STB "vendor:stb/image"

Texture :: struct {
    texture1, texture2, diffuse_map, specular_map: u32
}

init_texture :: proc(texture: ^Texture) -> bool {
    // texture 1
    // ---------
    GL.GenTextures(1, &texture.texture1);
    GL.BindTexture(GL.TEXTURE_2D, texture.texture1);
    // set the texture wrapping parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    // set texture filtering parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

    // load image, create texture and generate mipmaps
    width, height, nrChannels: i32
    // tell stb_image.h to flip loaded texture's on the y-axis.
    STB.set_flip_vertically_on_load(1)
    // The FileSystem::getPath(...) is part of the GitHub repository so we can find files on any IDE/platform; replace it with your own image path.
    data: [^]byte = STB.load("resources/textures/container.jpg", &width, &height, &nrChannels, 0);
    
    if (data != nil) {
        GL.TexImage2D(GL.TEXTURE_2D, 0, GL.RGB, i32(width), i32(height), 0, GL.RGB, GL.UNSIGNED_BYTE, data);
        GL.GenerateMipmap(GL.TEXTURE_2D);
    } else {
        log.error("Failed to load Texture\n")
        return false
    }
    STB.image_free(data);

    // texture 2
    // ---------
    GL.GenTextures(1, &texture.texture2);
    GL.BindTexture(GL.TEXTURE_2D, texture.texture2);
    // set the texture wrapping parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    // set texture filtering parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
    // load image, create texture and generate mipmaps
    data = STB.load("resources/textures/awesomeface.png", &width, &height, &nrChannels, 0);
    if (data != nil)
    {
        // note that the awesomeface.png has transparency and thus an alpha channel, so make sure to tell OpenGL the data type is of GL_RGBA
        GL.TexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, i32(width), i32(height), 0, GL.RGBA, GL.UNSIGNED_BYTE, data);
        GL.GenerateMipmap(GL.TEXTURE_2D);
    } else {
        log.error("Failed to load texture")
        return false 
    }
    STB.image_free(data);

    // texture 3 - diffuse map
    // ---------
    GL.GenTextures(1, &texture.diffuse_map);
    GL.BindTexture(GL.TEXTURE_2D, texture.diffuse_map);
    // set the texture wrapping parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    // set texture filtering parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
    // load image, create texture and generate mipmaps
    data = STB.load("resources/textures/container2.png", &width, &height, &nrChannels, 0);
    if (data != nil)
    {
        // note that the awesomeface.png has transparency and thus an alpha channel, so make sure to tell OpenGL the data type is of GL_RGBA
        GL.TexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, i32(width), i32(height), 0, GL.RGBA, GL.UNSIGNED_BYTE, data);
        GL.GenerateMipmap(GL.TEXTURE_2D);
    } else {
        log.error("Failed to load texture")
        return false 
    }
    STB.image_free(data);

    // texture 4 - specular map
    // ---------
    GL.GenTextures(1, &texture.specular_map);
    GL.BindTexture(GL.TEXTURE_2D, texture.specular_map);
    // set the texture wrapping parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    // set texture filtering parameters
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
    // load image, create texture and generate mipmaps
    data = STB.load("resources/textures/container2_specular.png", &width, &height, &nrChannels, 0);
    if (data != nil)
    {
        // note that the awesomeface.png has transparency and thus an alpha channel, so make sure to tell OpenGL the data type is of GL_RGBA
        GL.TexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, i32(width), i32(height), 0, GL.RGBA, GL.UNSIGNED_BYTE, data);
        GL.GenerateMipmap(GL.TEXTURE_2D);
    } else {
        log.error("Failed to load texture")
        return false 
    }
    STB.image_free(data);

    return true
}