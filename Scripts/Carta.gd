extends RigidBody3D

class_name Carta

var destino : Singleton.Cidades
@export var valor : int = 1

func _ready() -> void:
	randomize()
	destino = randi_range(0, 3)
	mudar_cor_da_carta(destino)

func mudar_cor_da_carta(valor : int) -> void:
	var mesh_carta : MeshInstance3D = $CartaMesh/Carta
	print(mesh_carta.name)
	var material = mesh_carta.get_surface_override_material(0)
	var novo_material = material.duplicate()
	novo_material.albedo_color = Singleton.cores[valor]
	mesh_carta.set_surface_override_material(0, novo_material)
