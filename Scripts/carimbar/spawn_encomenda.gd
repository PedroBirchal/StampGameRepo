extends Node

@export_range(0,1,0.05) var chance_pacote := 0.5
@export_range(0,1,0.05) var chance_defeito := 0.5

const PASTA_ITENS := "res://resources/itens"
@export var lugar_de_spawn: Node3D

@export_group("Spawn Encomendas")
@export var carta_prefab: PackedScene
@export var pacote_prefab: PackedScene

signal on_spawned(encomenda: Encomenda)

var lista_itens : PackedStringArray

func _ready() -> void:
	lista_itens = ResourceLoader.list_directory(PASTA_ITENS)

func spawn() -> Encomenda:
	var probabilidade = randf()
	
	if probabilidade < chance_pacote:
		var pacote: Pacote = pacote_prefab.instantiate()
		var probabilidade_defeito = randf()
		
		pacote.setar_pacote(get_item_aleatorio(), probabilidade_defeito < chance_defeito)
		return pacote
	
	var carta: Carta = carta_prefab.instantiate()
	return carta


func get_item_aleatorio() -> ItemResource:
	print(lista_itens)
	var item_name = lista_itens.get(randi_range(0, lista_itens.size()-1))
	return ResourceLoader.load(PASTA_ITENS + "/" + item_name)
