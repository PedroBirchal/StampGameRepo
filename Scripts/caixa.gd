extends Node3D

signal box_hover
signal box_unhover

@onready var ancora_indicador = $AncoraIndicador
@onready var marca = $MarcaCaixa
var hovered : bool

func _ready() -> void:
	var material = marca.get_active_material(0)
	print(material.albedo_color)
	mudar_cor_da_marca(Color.INDIAN_RED)
	material = marca.get_surface_override_material(0)
	print(material.albedo_color)

func _on_area_3d_mouse_entered() -> void:
	hovered = true
	box_hover.emit(ancora_indicador.global_position)

func _on_area_3d_mouse_exited() -> void:
	hovered = false
	box_unhover.emit()

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print(name)

func mudar_marca() -> void:
	
	pass

func mudar_cor_da_marca(color : Color) -> void:
	var novo_material = StandardMaterial3D.new()
	novo_material.albedo_color = color
	marca.set_surface_override_material(0, novo_material)
