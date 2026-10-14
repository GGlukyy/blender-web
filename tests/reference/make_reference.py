"""Render a Workbench (Solid) reference image of the open scene. Run with DESKTOP Blender:

    blender -b out/scenes/cube.blend --python tests/reference/make_reference.py -- out/reference/cube_solid.png

The settings below are the "contract" the web viewport must match in M10.
If you change them, all references must be regenerated and the change needs an ADR.
"""
import os
import sys

import bpy

out_path = sys.argv[sys.argv.index("--") + 1]
os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)

scene = bpy.context.scene
scene.render.engine = "BLENDER_WORKBENCH"
shading = scene.display.shading
shading.light = "STUDIO"
shading.color_type = "MATERIAL"
shading.show_cavity = False
shading.show_shadows = False
shading.show_xray = False
scene.display.render_aa = "OFF"           # no anti-aliasing → easier pixel compare
scene.view_settings.view_transform = "Standard"
scene.world = scene.world or bpy.data.worlds.new("World")
scene.render.film_transparent = False
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = os.path.abspath(out_path)

bpy.ops.render.render(write_still=True)
print(f"REFERENCE WRITTEN {out_path}")
