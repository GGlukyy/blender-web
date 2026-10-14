# patches/

`blender-web.patch` = **všechny naše změny** ve zdrojáku Blenderu (upravené i nové soubory)
oproti čistému tagu `BLENDER_TAG`.

- Vytváří ho `tools/save_patch.sh` (spustit před každým commitem).
- Aplikuje ho `scripts/prepare_blender.sh`.
- Ze začátku je prázdný — to je v pořádku.

Proč patch a ne celý fork Blenderu: repo zůstane malé, CI si Blender stáhne a cachuje,
a vždy je vidět přesně, co jsme na Blenderu změnili.
