class_name PostIt
extends Node3D

@export var mesh: MeshInstance3D
@export var label: Label3D
var pin: Node3D

@export_range(0,10,0.1) var duracao_piscada_in := 0.5
@export_range(0,10,0.1) var duracao_piscada_out := 0.5

@export var cor_correta: Color
@export var cor_errada: Color
var cor_padrao: Color


signal clicado(post_it: PostIt)
signal piscada_finalizada

func _ready() -> void:
	var mat: StandardMaterial3D = mesh.get_active_material(0)
	cor_padrao = mat.albedo_color

func set_texto(texto: String) -> void:
	label.text = texto

func piscar_cor(cor: Color) -> void:
	var mat: StandardMaterial3D = mesh.get_active_material(0)
	mat = mat.duplicate()
	mesh.set_surface_override_material(0, mat)
	
	var tween = get_tree().create_tween()
	tween.tween_property(mat, "albedo_color", cor, duracao_piscada_in)
	tween.tween_property(mat, "albedo_color", cor_padrao, duracao_piscada_out)
	await tween.finished
	piscada_finalizada.emit()


func piscar_estado(correto: bool) -> void:
	if correto:
		piscar_cor(cor_correta)
	else:
		piscar_cor(cor_errada)

func _on_static_body_3d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_static_body_3d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			clicado.emit(self)
	
