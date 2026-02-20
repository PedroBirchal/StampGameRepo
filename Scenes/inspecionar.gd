extends RigidBody3D

var rotating : bool = false
var selecionado : bool = false

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not selecionado:
				selecionado = true
				get_viewport().set_input_as_handled()

var dir : Vector2
func _physics_process(delta: float):
	rotate_object_local(Vector3.UP, dir.x * .7 * delta)
	rotate_object_local(Vector3.RIGHT, dir.y * .7 * delta)

func _input(event):
	if selecionado:
		if event is InputEventMouseButton:
			rotating = event.is_pressed()
		
		if event is InputEventMouseMotion and rotating:
			dir = event.relative
		else:
			dir = Vector2.ZERO
			
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				selecionado = false
				rotating = false
