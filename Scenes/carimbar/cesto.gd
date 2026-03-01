class_name CestoCarta
extends Node3D

@export var informativo_cheio: Node3D
@export var area_das_cartas: Array[Node3D]
var prox_carta_idx = 0

signal hover
signal unhover
signal clicado

func ainda_cabe() -> bool:
	return prox_carta_idx < len(area_das_cartas)

func _pegar_nova_area_carta() -> Node3D:
	var area = area_das_cartas[prox_carta_idx]
	prox_carta_idx += 1
	return area

func adicionar_carta(carta: Carta) -> void:
	var area = _pegar_nova_area_carta()
	carta.reparent(area)
	carta.position = Vector3.ZERO
	carta.rotation = Vector3.ZERO


func preview_carta(carta: Carta) -> void:
	if not ainda_cabe():
		return
	
	var area = area_das_cartas[prox_carta_idx]
	carta.reparent(area)
	carta.position = Vector3.ZERO
	carta.rotation = Vector3.ZERO


func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			print("clicado")
			clicado.emit()


func _on_static_body_3d_mouse_entered() -> void:
	if not ainda_cabe():
		informativo_cheio.show()
	else:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	hover.emit()


func _on_static_body_3d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	informativo_cheio.hide()
	
	unhover.emit()
