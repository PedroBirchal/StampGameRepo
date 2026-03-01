class_name Lixo
extends Node3D

@export var deletar_pos: Node3D
@export var deletar_holder: Node3D
@export var ate_fundo: Node3D

@export var tempo_delecao := 1.0
@export var escala_final := 0.2

signal hover
signal unhover
signal clicado

signal excluido(encomenda: Encomenda)


func excluir(encomenda: Encomenda) -> void:
	if deletar_holder.get_parent() != deletar_pos:
		deletar_holder.reparent(deletar_pos)
	
	deletar_holder.position = Vector3.ZERO
	deletar_holder.scale = Vector3.ONE
	
	encomenda.reparent(deletar_holder)
	encomenda.position = Vector3.ZERO
	
	deletar_holder.reparent(ate_fundo)
	
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(deletar_holder, "position", Vector3.ZERO, tempo_delecao)
	tween.tween_property(deletar_holder, "scale", Vector3.ONE * escala_final, tempo_delecao)
	await tween.finished
	
	excluido.emit(encomenda)
	encomenda.queue_free()
	
	deletar_holder.reparent(deletar_pos)
	deletar_holder.position = Vector3.ZERO
	deletar_holder.scale = Vector3.ONE

func _on_area_3d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover.emit()


func _on_area_3d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	unhover.emit()


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicado.emit()
