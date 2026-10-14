"""Validate a .blend produced by the WEB build, using DESKTOP Blender.

    blender -b out/roundtrip.blend --python tests/validate_blend.py -- --expect-objects 2

Prints `VALID .blend: N objects` and exits 0 on success, exits 1 otherwise.
Optional: --expect-location NAME X Y Z  (checks an object's location, tolerance 1e-3)
"""
import sys

import bpy

args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ok = True

objects = [o for o in bpy.data.objects]
print("objects:", [o.name for o in objects])

if "--expect-objects" in args:
    want = int(args[args.index("--expect-objects") + 1])
    # Ignore cameras/lights so the check is about the modelled content.
    meshes = [o for o in objects if o.type == "MESH"]
    if len(meshes) != want:
        print(f"FAIL: expected {want} mesh objects, found {len(meshes)}")
        ok = False

if "--expect-location" in args:
    i = args.index("--expect-location")
    name, x, y, z = args[i + 1], *map(float, args[i + 2:i + 5])
    obj = bpy.data.objects.get(name)
    if obj is None:
        print(f"FAIL: object {name} not found")
        ok = False
    else:
        loc = tuple(obj.location)
        if any(abs(a - b) > 1e-3 for a, b in zip(loc, (x, y, z))):
            print(f"FAIL: {name} location {loc} != {(x, y, z)}")
            ok = False

if ok:
    print(f"VALID .blend: {len([o for o in objects if o.type == 'MESH'])} objects")
    sys.exit(0)
sys.exit(1)
