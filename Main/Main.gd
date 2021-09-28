extends Node2D

enum{
	DEAD,
	ALIVE
}

export var underpopulation_threshold: int = 2
export var overpopulation_threshold: int = 3
export var brush_size: int = 0
export var check_radius: int = 1

onready var timer: Timer = $Timer

onready var current_generation: TileMap = $TileMap
onready var previous_generation: TileMap = $TileMap
onready var brush_preview: ColorRect = $ColorRect
onready var instructions: Control = $CanvasLayer/Control

func _ready() -> void:
	for i in range(0, 193):
		for j in range(0, 109):
			current_generation.set_cell(i, j, DEAD)
			previous_generation.set_cell(i, j, DEAD)

func _on_Timer_timeout() -> void:
	game_tick()

func game_tick() -> void:
	previous_generation = current_generation.duplicate()
	calculate_new_generation()

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("add"):
		var mouse_position: Vector2 = get_global_mouse_position()/10
		if brush_size == 0:
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
			current_generation.set_cell(mouse_position.x, mouse_position.y, ALIVE)
		for i in range(-brush_size, brush_size):
			for j in range(-brush_size, brush_size):
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
				current_generation.set_cell(mouse_position.x + i, mouse_position.y+ j, ALIVE)
	if Input.is_action_pressed("subtract"):
		var mouse_position: Vector2 = get_global_mouse_position()/10
		if brush_size == 0:
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
			current_generation.set_cell(mouse_position.x, mouse_position.y, DEAD)
		for i in range(-brush_size, brush_size):
			for j in range(-brush_size, brush_size):
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
				current_generation.set_cell(mouse_position.x + i, mouse_position.y + j, DEAD)
	
	if Input.is_action_pressed("toggle_play"):
		timer.autostart = not timer.autostart
		if timer.autostart:
			timer.start()
		else:
			timer.stop()
	
	if Input.is_action_just_pressed("clear_and_pause"):
		_ready()
		timer.autostart = false
		timer.stop()
	
	if Input.is_action_just_pressed("increase_brush_size"):
		brush_size += 1
	if Input.is_action_just_pressed("decrease_brush_size"):
		brush_size -= 1 if brush_size > 0 else 0
	
	if Input.is_action_just_pressed("toggle_instructions"):
		instructions.visible = not instructions.visible

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var radius = brush_size * 20 if not brush_size == 0 else 10
	brush_preview.rect_size = Vector2(radius, radius)
	brush_preview.set_position(Vector2(floor(mouse_position.x/10)*10 - brush_size * 10, floor(mouse_position.y/10)*10  - brush_size * 10))

func calculate_new_generation() -> void:
	var tile_map: TileMap = current_generation
	for i in range(0, 193):
		for j in range(0, 109):
			var current_status: int = previous_generation.get_cell(i, j)
			var alive_neighbours: int = get_number_of_alive_neighbours(i, j)
			
			if current_status == DEAD and alive_neighbours == 3:
				current_status = ALIVE
			if current_status == ALIVE:
				if alive_neighbours < underpopulation_threshold or alive_neighbours > overpopulation_threshold:
					current_status = DEAD
			tile_map.set_cell(i, j,  current_status)

func get_number_of_alive_neighbours(x: int, y: int) -> int:
	var out: int = 0
	
	for i in range(-check_radius, check_radius + 1):
		for j in range(-check_radius, check_radius + 1):
			if i == 0 and j == 0:
				continue
			out += previous_generation.get_cell(x + i, y + j)
	
	return out
