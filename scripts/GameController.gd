class_name GameController
extends Node2D

@export var grid_size: Vector2i = Vector2i(21, 17)
@export var cell_size: int = 32

@onready var board := $Grid as GridBoard
@onready var contract_label := $"UI/PanelContainer/VBoxContainer/ContractLabel"
@onready var stats_label := $"UI/PanelContainer/VBoxContainer/StatsLabel"
@onready var hint_label := $"UI/PanelContainer/VBoxContainer/HintLabel"
@onready var build_button := $"UI/PanelContainer/VBoxContainer/Controls/BuildButton"
@onready var clear_button := $"UI/PanelContainer/VBoxContainer/Controls/ClearButton"
@onready var demolish_button := $"UI/PanelContainer/VBoxContainer/Controls/DemolishButton"
@onready var reset_button := $"UI/PanelContainer/VBoxContainer/Controls/ResetButton"

const INPUT_PRIMARY := MOUSE_BUTTON_LEFT
const INPUT_SECONDARY := MOUSE_BUTTON_RIGHT

var contracts: Array = []
var animal_scene := preload("res://scenes/Animal.tscn")
var sprite_lookup: Dictionary = {}

var current_contract_index := 0
var built_cells: Dictionary = {}
var built_history: Array = []
var built_animals: Array = []
var draft_cells: Dictionary = {}
var obstacles: Dictionary = {}

func _ready() -> void:
	_setup_board()
	_seed_obstacles()
	_build_sprite_lookup()
	contracts = _generate_contracts()
	_load_contract(0)
	_connect_buttons()
	_refresh_ui()

func _connect_buttons() -> void:
	build_button.pressed.connect(_on_build_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	demolish_button.pressed.connect(_on_demolish_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

func _setup_board() -> void:
	if board.has_method("set_state"):
		board.set("grid_size", grid_size)
		board.set("cell_size", cell_size)

func _seed_obstacles() -> void:
	obstacles.clear()
	# River down the middle.
	var river_x := grid_size.x / 2
	for y in range(grid_size.y):
		obstacles[Vector2i(river_x, y)] = true
	# Ancient trees as static blockers.
	for pos in [Vector2i(3, 3), Vector2i(12, 5), Vector2i(8, 10), Vector2i(14, 9)]:
		obstacles[pos] = true

func _load_contract(index: int) -> void:
	current_contract_index = clamp(index, 0, contracts.size())
	if current_contract_index >= contracts.size():
		contract_label.text = "[b]All animals settled![/b]\nYou can keep practicing or reset the zoo."
		build_button.disabled = true
		return
	build_button.disabled = false
	var contract : Dictionary = contracts[current_contract_index]
	contract_label.text = _format_contract(contract)
	draft_cells.clear()
	_refresh_ui()

func _format_contract(contract: Dictionary) -> String:
	var parts: Array[String] = []
	parts.append("[b]%s[/b]" % contract.get("name", "Animal"))
	parts.append(contract.get("description", "Design a safe home."))
	parts.append("Target Area: %d" % contract.get("area", 0))
	if contract.has("perimeter_max"):
		parts.append("Perimeter: <= %d" % int(contract["perimeter_max"]))
	if contract.has("perimeter_min"):
		parts.append("Perimeter: >= %d" % int(contract["perimeter_min"]))
	if contract.has("min_corners"):
		parts.append("Corners: >= %d" % int(contract["min_corners"]))
	return "\n".join(parts)

func _unhandled_input(event: InputEvent) -> void:
	if current_contract_index >= contracts.size():
		return
	if event is InputEventMouseButton and event.pressed:
		var cell = _to_cell(event.position)
		if cell == null:
			return
		if event.button_index == INPUT_PRIMARY:
			_try_paint(cell)
		elif event.button_index == INPUT_SECONDARY:
			_erase_cell(cell)
	elif event is InputEventMouseMotion:
		var cell_motion = _to_cell(event.position)
		if cell_motion == null:
			return
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_try_paint(cell_motion)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			_erase_cell(cell_motion)

func _to_cell(position: Vector2) -> Variant:
	var world_pos := get_global_mouse_position()
	if board.has_method("point_to_cell"):
		return board.call("point_to_cell", world_pos)
	return null

func _try_paint(cell: Vector2i) -> void:
	if obstacles.has(cell):
		_set_hint("That spot is blocked by terrain.")
		return
	if built_cells.has(cell):
		_set_hint("Existing cages stay put. Draft around them.")
		return
	draft_cells[cell] = true
	_refresh_ui()

func _erase_cell(cell: Vector2i) -> void:
	draft_cells.erase(cell)
	_refresh_ui()

func _on_clear_pressed() -> void:
	draft_cells.clear()
	_set_hint("Draft cleared. Sketch a better fit.")
	_refresh_ui()

func _on_reset_pressed() -> void:
	built_cells.clear()
	built_history.clear()
	for animal in built_animals:
		if animal and animal.is_inside_tree():
			animal.queue_free()
	built_animals.clear()
	draft_cells.clear()
	_set_hint("Zoo reset. Start from a clean lot.")
	contracts = _generate_contracts()
	_load_contract(0)

func _on_demolish_pressed() -> void:
	if built_history.is_empty():
		_set_hint("No cages to demolish.")
		return
	var last_shape: Array = built_history.pop_back()
	if built_animals.size() > 0:
		var last_animal = built_animals.pop_back()
		if last_animal and last_animal.is_inside_tree():
			last_animal.queue_free()
	for cell in last_shape:
		built_cells.erase(cell)
	_set_hint("Last cage removed. Rebuild to suit the new plan.")
	_refresh_ui()

func _on_build_pressed() -> void:
	if current_contract_index >= contracts.size():
		return
	if draft_cells.is_empty():
		_set_hint("Draw a cage first.")
		return
	var contract = contracts[current_contract_index]
	var metrics := _compute_metrics(draft_cells)
	var validation := _validate(metrics, contract)
	if not validation["ok"]:
		_set_hint(validation["message"])
		return
	_commit_build()

func _commit_build() -> void:
	var shape: Array = []
	for cell in draft_cells.keys():
		built_cells[cell] = true
		shape.append(cell)
	built_history.append(shape)
	var contract = contracts[current_contract_index]
	var spawned_animal = _spawn_animal(contract.get("name", "Animal"), shape)
	built_animals.append(spawned_animal)
	draft_cells.clear()
	_set_hint("Cage built! Visitors are arriving.")
	_load_contract(current_contract_index + 1)

func _compute_metrics(cells: Dictionary) -> Dictionary:
	var area := cells.size()
	var perimeter := 0
	var edges: Dictionary = {}
	var directions := [
		Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	for cell in cells.keys():
		for dir in directions:
			var neighbor = cell + dir
			if cells.has(neighbor):
				continue
			perimeter += 1
			var edge := _edge_from_cell(cell, dir)
			edges[edge["key"]] = edge
	var corners := _count_corners(edges)
	return {
		"area": area,
		"perimeter": perimeter,
		"corners": corners
	}

func _edge_from_cell(cell: Vector2i, dir: Vector2i) -> Dictionary:
	# Returns a consistent edge representation for perimeter tracing.
	var a: Vector2i
	var b: Vector2i
	if dir == Vector2i.UP:
		a = Vector2i(cell.x, cell.y)
		b = Vector2i(cell.x + 1, cell.y)
	elif dir == Vector2i.DOWN:
		a = Vector2i(cell.x, cell.y + 1)
		b = Vector2i(cell.x + 1, cell.y + 1)
	elif dir == Vector2i.LEFT:
		a = Vector2i(cell.x, cell.y)
		b = Vector2i(cell.x, cell.y + 1)
	else:
		a = Vector2i(cell.x + 1, cell.y)
		b = Vector2i(cell.x + 1, cell.y + 1)
	var key := "%d,%d:%d,%d" % [a.x, a.y, b.x, b.y]
	return {"a": a, "b": b, "key": key}

func _count_corners(edges: Dictionary) -> int:
	var vertex_dirs: Dictionary = {}
	for edge in edges.values():
		var a: Vector2i = edge["a"]
		var b: Vector2i = edge["b"]
		var dir := (b - a).sign()
		for v in [a, b]:
			if not vertex_dirs.has(v):
				vertex_dirs[v] = []
			vertex_dirs[v].append(dir)

	var corners := 0
	for dirs in vertex_dirs.values():
		var has_horizontal := false
		var has_vertical := false
		for d in dirs:
			if d.x != 0:
				has_horizontal = true
			if d.y != 0:
				has_vertical = true
		if has_horizontal and has_vertical:
			corners += 1
	return corners

func _generate_contracts() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var templates: Array = [
		{"name": "Arctic Wolves", "description": "Plenty of room; keep fencing lean.", "style": "efficient"},
		{"name": "Meerkats", "description": "They love nooks and corners.", "style": "corners"},
		{"name": "Penguins", "description": "Work around water and visitors.", "style": "balanced"},
		{"name": "Elephants", "description": "Wide roamers; avoid skinny corridors.", "style": "efficient"},
		{"name": "Flamingos", "description": "Stretch a long shallow pool.", "style": "stretched"},
		{"name": "Foxes", "description": "They prefer winding paths.", "style": "corners"}
	]
	var shuffled := _shuffle_with_rng(templates, rng)
	var chosen := shuffled.slice(0, 5)
	var available_area := grid_size.x * grid_size.y - obstacles.size()
	var generated: Array = []
	for template in chosen:
		generated.append(_build_random_contract(template, rng, available_area))
	return generated

func _build_random_contract(template: Dictionary, rng: RandomNumberGenerator, available_area: int) -> Dictionary:
	var area_min := 10
	var area_max = min(36, max(area_min, available_area))
	var area_target := rng.randi_range(area_min, area_max)
	var perim_min := _min_perimeter_estimate(area_target)
	var perim_max := _max_perimeter_for_area(area_target)
	var contract: Dictionary = {
		"name": template.get("name", "Animal"),
		"description": template.get("description", "Design a safe home."),
		"area": area_target
	}

	match template.get("style", "balanced"):
		"efficient":
			var cap = min(perim_max, perim_min + 8)
			contract["perimeter_max"] = rng.randi_range(perim_min, cap)
		"balanced":
			var cap_bal = min(perim_max, perim_min + 10)
			contract["perimeter_max"] = rng.randi_range(perim_min + 1, cap_bal)
			if rng.randi_range(0, 1) == 1:
				contract["perimeter_min"] = perim_min
		"stretched":
			var min_stretch = min(perim_min + 4, perim_max)
			contract["perimeter_min"] = rng.randi_range(min_stretch, perim_max)
		"corners":
			var cap_corners = min(perim_max, perim_min + 10)
			contract["perimeter_max"] = rng.randi_range(perim_min + 1, cap_corners)
			var min_corners = clamp(rng.randi_range(6, 9), 4, area_target)
			contract["min_corners"] = min_corners
		_:
			var cap_default = min(perim_max, perim_min + 10)
			contract["perimeter_max"] = rng.randi_range(perim_min, cap_default)

	return contract

func _min_perimeter_estimate(area_target: int) -> int:
	var width := int(sqrt(area_target))
	if width < 1:
		width = 1
	var height := int(ceil(float(area_target) / float(width)))
	return 2 * (width + height)

func _max_perimeter_for_area(area_target: int) -> int:
	if area_target <= 0:
		return 0
	return 2 * (area_target + 1)

func _shuffle_with_rng(source: Array, rng: RandomNumberGenerator) -> Array:
	var result := source.duplicate()
	for i in range(result.size()):
		var j := rng.randi_range(i, result.size() - 1)
		var tmp = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result

func _build_sprite_lookup() -> void:
	sprite_lookup.clear()
	var dir := DirAccess.open("res://assets")
	if dir == null:
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with("-Spritesheet.png"):
			var key := fname.replace("-Spritesheet.png", "").to_lower()
			sprite_lookup[key] = "res://assets/%s" % fname
		fname = dir.get_next()
	dir.list_dir_end()

func _find_texture_for_animal(animal_name: String) -> Texture2D:
	if animal_name == "":
		return null
	var lowered := animal_name.to_lower()
	var candidates: Array = []
	candidates.append(lowered.replace(" ", ""))
	candidates.append_array(lowered.split(" "))
	# Try simple singular forms to cover "Elephants" vs "Elephant"
	var trimmed := lowered
	if trimmed.ends_with("es"):
		trimmed = trimmed.substr(0, trimmed.length() - 2)
	elif trimmed.ends_with("s"):
		trimmed = trimmed.substr(0, trimmed.length() - 1)
	candidates.append(trimmed.replace(" ", ""))
	for key in candidates:
		if sprite_lookup.has(key):
			var path: String = sprite_lookup[key]
			var tex: Texture2D = load(path)
			return tex
	return null

func _shape_center_local(shape: Array) -> Vector2:
	if shape.is_empty():
		return Vector2.ZERO
	var min_x = shape[0].x
	var max_x = shape[0].x
	var min_y = shape[0].y
	var max_y = shape[0].y
	for cell in shape:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)
	var center_cell := Vector2((min_x + max_x + 1) * 0.5, (min_y + max_y + 1) * 0.5)
	return center_cell * float(cell_size)

func _spawn_animal(animal_name: String, shape: Array) -> Node2D:
	var texture := _find_texture_for_animal(animal_name)
	if texture == null:
		return null
	var inst := animal_scene.instantiate() as Node2D
	var sprite := inst.get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture = texture
	inst.position = _shape_center_local(shape)
	board.add_child(inst)
	return inst

func _validate(metrics: Dictionary, contract: Dictionary) -> Dictionary:
	if metrics["area"] != contract.get("area", metrics["area"]):
		return {"ok": false, "message": "Area needs to be %d. Current: %d." % [contract["area"], metrics["area"]]}
	if contract.has("perimeter_max") and metrics["perimeter"] > int(contract["perimeter_max"]):
		return {"ok": false, "message": "Perimeter too long. Max: %d." % int(contract["perimeter_max"])}
	if contract.has("perimeter_min") and metrics["perimeter"] < int(contract["perimeter_min"]):
		return {"ok": false, "message": "Perimeter too short. Min: %d." % int(contract["perimeter_min"])}
	if contract.has("min_corners") and metrics["corners"] < int(contract["min_corners"]):
		return {"ok": false, "message": "Add more corners (goal: %d)." % int(contract["min_corners"])}
	return {"ok": true, "message": "Math checks out!"}

func _refresh_ui() -> void:
	var metrics := _compute_metrics(draft_cells)
	stats_label.text = "Draft — Area %d | Perimeter %d | Corners %d" % [metrics["area"], metrics["perimeter"], metrics["corners"]]
	if board.has_method("set_state"):
		board.call("set_state", built_cells, draft_cells, obstacles)

func _set_hint(text: String) -> void:
	hint_label.text = text
