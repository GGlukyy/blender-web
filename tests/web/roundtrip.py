"""Runs INSIDE the web (wasm) Blender: add a cube to the loaded .blend and save it."""
import sys
import bpy

out = sys.argv[sys.argv.index("--") + 1]
before = len(bpy.data.objects)
bpy.ops.mesh.primitive_cube_add(location=(3.0, 0.0, 0.0))
bpy.context.active_object.name = "WebCube"
print("WEB objects:", before, "->", len(bpy.data.objects))
bpy.ops.wm.save_as_mainfile(filepath=out)
print("WEB saved:", out)
