extends Node

@export_range(0,1,0.05) var chance_pacote := 0.5

const PASTA_ITENS := "resources/itens"
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
		pacote.setar_pacote(get_item_aleatorio())
		return pacote
	
	var carta: Carta = carta_prefab.instantiate()
	return carta


func get_item_aleatorio() -> ItemResource:
	var item_name = lista_itens.get(randi_range(0, lista_itens.size()-1))
	return ResourceLoader.load(PASTA_ITENS + "/" + item_name)
