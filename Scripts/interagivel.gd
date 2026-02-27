@tool
class_name Interagivel
extends Node3D

signal on_interact
@export var area_clicavel: InteragivelHover
@export var mesh: MeshInstance3D
@export var material_outline: Material
@export var area_de_interacao: Node3D

@export var jogavel: Jogavel

@export var setar_area_pos_click := false

const FORCA_EMISSAO = 0.4

var mat : BaseMaterial3D

func _ready() -> void:
	if area_clicavel != null:
		area_clicavel.ta_em_cima.connect(_on_hover)
		area_clicavel.saiu_de_cima.connect(_on_unhover)
	
	if mesh != null:
		mat = mesh.get_active_material(0).duplicate()
		mesh.set_surface_override_material(0, mat)
		
		if mat.albedo_texture == null:
			mat.emission = mat.albedo_color
		else:
			mat.emission = Color(0,0,0)
			mat.emission_texture = mat.albedo_texture
		
		mat.emission_enabled = false
		mat.emission_energy_multiplier = FORCA_EMISSAO
	

func interagir() -> void:
	on_interact.emit()
	
	if jogavel != null:
		jogavel.jogar()
	
	if mat != null:
		mat.emission_enabled = false

func _on_hover() -> void:
	if mat != null:
		mat.emission_enabled = true

func _on_unhover() -> void:
	if mat != null:
		mat.emission_enabled = false

func setar_area_click(pos: Vector3) -> void:
	area_de_interacao.position = pos

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not get_parent() is CollisionObject3D:
		warnings.push_back("Interagivel deve ser filho direto de um CollisionObject3D.")

	return warnings
