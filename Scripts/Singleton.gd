extends Node

enum Cidades {
	AQUA,
	ARVORE,
	INFERNOPOLIS,
	TORRE,
}
var cores : Array[Color] = [Color.SKY_BLUE, Color.GREEN, Color.INDIAN_RED, Color.BURLYWOOD]
var carimbos : Array = [
	preload("res://Sprites/Carimbos/carimboAqua.png"), 
	preload("res://Sprites/Carimbos/carimboArvore.png"), 
	preload("res://Sprites/Carimbos/carimboInfernopolis.png"), 
	preload("res://Sprites/Carimbos/carimboTorre.png")
	]

enum Direcao { FRENTE, ESQUERDA, COSTAS, DIREITA }

## Dicionario de grupos relacionando a direção e o grupo que deve sumir na direção, referente ao quarto
var direcao_grupo = {
	Direcao.FRENTE: "frente_quarto",
	Direcao.ESQUERDA: "esquerda_quarto",
	Direcao.COSTAS: "costas_quarto",
	Direcao.DIREITA: "direita_quarto",
}


var sigla_cidade = {
	Cidades.AQUA: "aqua",
	Cidades.ARVORE: "arvoro",
	Cidades.INFERNOPOLIS: "inferno",
	Cidades.TORRE: "torre"
}

var cartas_dir_path : Array[StringName] = [
"res://resources/cartas/", 
"res://resources/cartas/Aqualantida/", 
"res://resources/cartas/Arvorosa/",
"res://resources/cartas/Infernópolis/",
"res://resources/cartas/Torres/"]
var cartas : Array[CartaResource]
var cartas_acesadas : Array[int]

func _init() -> void :
	for diretorio in cartas_dir_path :
		for res in ResourceLoader.list_directory(diretorio):
			# Ignora pastas
			if res.ends_with("/"):
				continue
				
			var resource_path = diretorio.path_join(res)
			var resource_loaded = ResourceLoader.load(resource_path)
			print ("Carregando o " + resource_path)
			if resource_loaded :
				cartas.append(resource_loaded)
			else:
				print ("vixe rapaz, n deu pra carragar uma carta aqui nn")

	var i = 1
	for carta in cartas :
		print (i)
		i += 1

func _ready() -> void:
	print( get_rand_carta().conteudo)

func get_rand_carta() -> CartaResource :
	if cartas_acesadas.size() >= 22 :
		cartas_acesadas.clear()
	var index = randi_range(0, cartas.size() - 1)
	if cartas_acesadas.has(index) :
		return get_rand_carta()
	else :
		cartas_acesadas.append(index)
		return cartas[index]
