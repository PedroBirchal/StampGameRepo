## Para todas as coisas, isso é um GameManager
class_name Jogo
extends Node

static var instance: Jogo

enum Estado { QUARTO, JOGANDO }

var estado := Estado.QUARTO
var jogavel_atual : Jogavel

@export_group("UI")
@export var quarto_ui : Control

@export_group("Sumir Objetos Perto")
@export var distancia_fade_min := 7
@export var distancia_fade_max := 8


func _init() -> void:
	instance = self

func _ready() -> void:
	atualizar_sumiveis()

func jogavel_iniciado(jogavel: Jogavel) -> void:
	jogavel_atual = jogavel
	jogavel_atual.saindo.connect(jogavel_encerrado)
	mudar_estado(Estado.JOGANDO)

func jogavel_encerrado() -> void:
	jogavel_atual.saindo.disconnect(jogavel_encerrado)
	mudar_estado(Estado.QUARTO)


func mudar_estado(std: Estado) -> void:
	if estado == std:
		return
	
	estado = std
	
	if estado == Estado.QUARTO:
		quarto_ui.show()
	elif estado == Estado.JOGANDO:
		quarto_ui.hide()
	
	atualizar_sumiveis()

func atualizar_sumiveis() -> void:
	var sumiveis = get_tree().get_nodes_in_group("sumivel")
	var pode_sumir = estado == Estado.QUARTO
	
	print("atualizando sumiveis como " + str(pode_sumir))
	
	for sumivel: MeshInstance3D in sumiveis:
		var mat: StandardMaterial3D = sumivel.get_active_material(0)
		if mat == null:
			continue
		
		mat = mat.duplicate()
		
		if mat.distance_fade_mode == 2 and not pode_sumir:
			mat.distance_fade_mode = 0
		if mat.distance_fade_mode == 0 and pode_sumir:
			mat.distance_fade_mode = 2
			mat.distance_fade_min_distance = distancia_fade_min
			mat.distance_fade_max_distance = distancia_fade_max
		
		sumivel.set_surface_override_material(0, mat)
