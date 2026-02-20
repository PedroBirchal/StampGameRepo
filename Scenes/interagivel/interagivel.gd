@tool
class_name Interagivel
extends Node3D

signal on_interact
@export var mesh: MeshInstance3D
@export var material_outline: Material
@export var area_de_interacao: Node3D

func _ready() -> void:
	var collision = get_parent()
	if collision != null and collision is CollisionObject3D:
		collision.mouse_entered.connect(_on_hover)
		collision.mouse_exited.connect(_on_unhover)

func interagir() -> void:
	on_interact.emit()

func _on_hover() -> void:
	mesh.set_surface_override_material(0, material_outline)

func _on_unhover() -> void:
	mesh.set_surface_override_material(0, null)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not get_parent() is CollisionObject3D:
		warnings.push_back("Interagivel deve ser filho direto de um CollisionObject3D.")

	return warnings
