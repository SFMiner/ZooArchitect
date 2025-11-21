# Repository Guidelines

## Project Structure & Module Organization
- Core config lives in `project.godot`; it targets Godot 4.5 with GL Compatibility.
- The design brief is in `GDD.md`.
- `icon.svg` is the default project icon; other brand assets should live under `res://assets/`.
- Avoid touching `.godot/` and `.import` artifacts; they are editor caches.
- When adding content, organize under the Godot `res://` root: `res://scenes/` for levels/UI, `res://scripts/` for GDScript, `res://assets/` for art/audio, and `res://tests/` for future automation.

## Build, Test, and Development Commands
- Open the project in the editor: `godot4 --editor --path .`
- Run the game from the command line: `godot4 --path .`
- Headless smoke test (loads the project and exits on launch): `godot4 --headless --path . --quit-after 0`
- Exports are not configured yet; create export presets in the editor before packaging.

## Coding Style & Naming Conventions
- GDScript: tabs indentation, no spaces; keep methods and variables `snake_case`, classes `PascalCase`.
- Node paths and scene filenames should mirror their main node type (e.g., `ZooBuilder.tscn`, `MainMenu.tscn`).
- Favor small, single-responsibility scripts. Keep exported properties typed and documented with brief comments when behavior is non-obvious.
- Prefer signals over polling for node coordination; avoid singletons unless they carry cross-scene state intentionally.

## Testing Guidelines
- There are no automated tests yet; please add lightweight scene-level checks under `res://tests/` when introducing complex behavior.
- For manual testing, launch the scene being modified directly in the editor; validate loading with `godot4 --path .` before submitting.
- Include repro steps and expected outcomes in your change notes; attach screenshots or short clips for UI/gameplay tweaks.

## Commit & Pull Request Guidelines
- Use clear, action-oriented commit messages (e.g., “Add habitat placement grid snapping”).
- Keep PRs focused and small; describe the change, risks, and testing performed. Link related issue/task IDs when available.
- Include notes on new inputs, debug shortcuts, or editor settings that reviewers need to reproduce the change.
- Do not commit editor cache directories (`.godot/`, `.import/`) or platform-specific export outputs unless explicitly required.

## Security & Configuration Tips
- Keep assets royalty-free or properly licensed; store license files alongside third-party content in `res://assets/`.
- If you add plugins or addons, document their version and source in the PR and store them under `res://addons/`.
- When modifying project settings, favor editor UI over manual edits to `project.godot` to avoid invalid keys.
