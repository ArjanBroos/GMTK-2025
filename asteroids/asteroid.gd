@tool
class_name Asteroid
extends RigidBody2D

@export var speed: float = 20.0
@export var direction_degrees: float = 90.0

@onready var direction_line_editor: Line2D = $DirectionLineEditor

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dirVec = Vector2.RIGHT.rotated(deg_to_rad(direction_degrees))
	
	apply_central_force(dirVec * speed)

func _draw() -> void:
	var dir = Vector2.RIGHT.rotated(deg_to_rad(direction_degrees)) * 50
	direction_line_editor.points[1] = dir
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		direction_line_editor.visible = false

func _determine_mirror_position(cur_pos: Vector2) -> Vector2:
	var window = DisplayServer.window_get_size()
	
	# positions are determined by taking the window width/height and resetting
	# the position of the asteroid to either the 0 or window width/height based
	# on where on the screen the asteroid left
	
	var new_pos: Vector2
	
	if cur_pos.x > window.x:
		# exited on the right
		new_pos = Vector2(0, clamp(cur_pos.y, 0, window.y))
	elif cur_pos.x < 0:
		# exited on the left
		new_pos = Vector2(window.x, clamp(cur_pos.y, 0, window.y))
	elif cur_pos.y > window.y:
		# exited at the bottom
		new_pos = Vector2(clamp(cur_pos.x, 0, window.x), 0)
	elif cur_pos.y < 0:
		# exited at the top
		new_pos = Vector2(clamp(cur_pos.x, 0, window.x), window.y)
		
	return new_pos

func _on_visible_on_screen_screen_exited() -> void:
	global_position = _determine_mirror_position(global_position)
