class_name Interagivel
extends Node3D

signal on_interact
@export var collision: CollisionObject3D
@export var mesh: MeshInstance3D
@export var material_outline: Material

func _ready() -> void:
	if collision != null:
		collision.mouse_entered.connect(_on_hover)
		collision.mouse_exited.connect(_on_unhover)

func interagir() -> void:
	print("aadasdsadasdasa")
	on_interact.emit()

func _on_hover() -> void:
	mesh.set_surface_override_material(0, material_outline)

func _on_unhover() -> void:
	mesh.set_surface_override_material(0, null)
