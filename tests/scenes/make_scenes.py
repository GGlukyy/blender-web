"""Generate deterministic test scenes. Run with DESKTOP Blender:

    blender -b --factory-startup --python tests/scenes/make_scenes.py -- out/scenes
"""
import os
import sys

import bpy

out_dir = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "out/scenes"
os.makedirs(out_dir, exist_ok=True)

# Start from an empty scene so the result never depends on the default startup file.
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

# Camera looking at the origin from a fixed angle.
cam_data = bpy.data.cameras.new("Camera")
cam = bpy.data.objects.new("Camera", cam_data)
scene.collection.objects.link(cam)
cam.location = (6.0, -6.0, 4.5)
cam.rotation_euler = (1.1, 0.0, 0.785398)
scene.camera = cam

# One cube at the origin.
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0.0, 0.0, 0.0))
bpy.context.active_object.name = "Cube"

scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.resolution_percentage = 100

path = os.path.join(out_dir, "cube.blend")
bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(path), compress=False)
print(f"SCENE WRITTEN {path} objects={len(scene.objects)}")
