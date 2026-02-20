extends RigidBody3D

var rotating : bool = false
var selecionado : bool = false
@export var sensibilidade : float = 0.01

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not selecionado:
				selecionado = true
				get_viewport().set_input_as_handled()

func _input(event):
	if selecionado:
		if event is InputEventMouseButton:
			if event.is_pressed():
				rotating = true
			else:
				rotating = false
		
		if event is InputEventMouseMotion and rotating:
			var rel = event.relative
			rotate_object_local(Vector3.UP, rel.x * .7 * sensibilidade)
			rotate_object_local(Vector3.RIGHT, rel.y * .7 * sensibilidade)
		
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				selecionado = false
				rotating = false
