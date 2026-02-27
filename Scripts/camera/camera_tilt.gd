extends Camera3D

var rotacao_base: Vector3
@export var margem_tela: Vector2 = Vector2(50,50)
@export_range(0, 360, 0.1, "radians_as_degrees") var rotacao_x: float = deg_to_rad(15)
@export_range(0, 360, 0.1, "radians_as_degrees") var rotacao_y: float = deg_to_rad(15)

func _ready() -> void:
	rotacao_base = rotation

func _physics_process(delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	var axis = Vector2.ZERO
	if mouse_pos.x < margem_tela.x:
		axis.x = 1
	elif mouse_pos.x > viewport_size.x - margem_tela.x:
		axis.x = -1
	
	if mouse_pos.y < margem_tela.y:
		axis.y = 1
	elif mouse_pos.y > viewport_size.y - margem_tela.y:
		axis.y = -1
	
	rotation.y = move_toward(rotation.y, rotacao_base.y+rotacao_x*axis.x, delta)
	rotation.x = move_toward(rotation.x, rotacao_base.x+rotacao_y*axis.y, delta)
	
