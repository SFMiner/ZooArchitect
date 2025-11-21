class_name GridBoard
extends Node2D

@export var grid_size: Vector2i = Vector2i(21, 17)
@export var cell_size: int = 32

var occupied: Dictionary = {}
var draft: Dictionary = {}
var obstacles: Dictionary = {}

func set_state(new_occupied: Dictionary, new_draft: Dictionary, new_obstacles: Dictionary) -> void:
    occupied = new_occupied
    draft = new_draft
    obstacles = new_obstacles
    queue_redraw()

func point_to_cell(global_position: Vector2) -> Variant:
    var local := to_local(global_position)
    if local.x < 0.0 or local.y < 0.0:
        return null
    var cell := Vector2i(floor(local.x / cell_size), floor(local.y / cell_size))
    if cell.x < 0 or cell.y < 0 or cell.x >= grid_size.x or cell.y >= grid_size.y:
        return null
    return cell

func cell_to_rect(cell: Vector2i) -> Rect2:
    return Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size))

func _draw() -> void:
    var board_size := Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
    draw_rect(Rect2(Vector2.ZERO, board_size), Color(0.14, 0.32, 0.16)) # grass backdrop
    _draw_cells(obstacles, Color(0.24, 0.44, 0.72, 0.9))
    _draw_cells(occupied, Color(0.82, 0.71, 0.53, 0.95)) # tan bare earth
    _draw_cells(draft, Color(0.26, 0.68, 0.32, 0.8))
    _draw_grid_lines(board_size)

func _draw_cells(data: Dictionary, color: Color) -> void:
    for cell in data.keys():
        draw_rect(cell_to_rect(cell), color, true)

func _draw_grid_lines(board_size: Vector2) -> void:
    var line_color := Color(0.28, 0.3, 0.34)
    for x in range(grid_size.x + 1):
        var x_pos := float(x * cell_size)
        draw_line(Vector2(x_pos, 0), Vector2(x_pos, board_size.y), line_color, 1.0)
    for y in range(grid_size.y + 1):
        var y_pos := float(y * cell_size)
        draw_line(Vector2(0, y_pos), Vector2(board_size.x, y_pos), line_color, 1.0)
