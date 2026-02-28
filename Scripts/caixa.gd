extends Node3D

signal box_hover
signal box_unhover
signal box_clicked
signal pontuar

@export var destino : Singleton.Cidades = Singleton.Cidades.AQUA
@onready var ancora_indicador = $AncoraIndicador
@onready var marca = $MarcaCaixa
@onready var area3D_caixa : Area3D = $AreaCaixa

var hovered : bool
@export var limite_de_cartas : int = 10

func _ready() -> void:
	mudar_cor_da_marca(Singleton.carimbos[destino])

func _on_area_3d_mouse_entered() -> void:
	hovered = true
	box_hover.emit(ancora_indicador.global_position)

func _on_area_3d_mouse_exited() -> void:
	hovered = false
	box_unhover.emit()

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			box_clicked.emit(ancora_indicador.global_position)

func _on_area_caxa_body_entered(body: Node3D) -> void:
	if body is Carta :
		if body.destino == destino:
			pontuar.emit(body.valor)
		else :
			pontuar.emit(-body.valor)
	var cartas_na_caixa = area3D_caixa.get_overlapping_bodies()
	if cartas_na_caixa.size() > limite_de_cartas:
		cartas_na_caixa[0].queue_free()
	pass

func mudar_cor_da_marca(texture : Texture) -> void:
	var novo_material = marca.material_override.duplicate()
	novo_material.albedo_texture = texture
	marca.material_override = novo_material
