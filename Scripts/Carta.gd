extends RigidBody3D

class_name Carta

var destino : Singleton.Cidades
@export var valor : int = 1
@export var animation_player : AnimationPlayer


@export var pode_abrir := false
@export var carta_aberta := false

@export_group("Texto")
@export var texto_meio : Label3D

func _ready() -> void:
	randomize()
	destino = randi_range(0, 3) as Singleton.Cidades
	mudar_cor_da_carta(destino)

func mudar_cor_da_carta(valor : int) -> void:
	var mesh_carta : MeshInstance3D = $CartaMesh/Carta
	var material = mesh_carta.get_surface_override_material(0)
	var novo_material = material.duplicate()
	novo_material.albedo_color = Singleton.cores[valor]
	mesh_carta.set_surface_override_material(0, novo_material)

func recebe_valores(carta: CartaResource) -> void:
	texto_meio.text = carta.conteudo
	destino = carta.indo_para
	mudar_cor_da_carta(destino)

func abrir_carta() -> void:
	animation_player.play()
