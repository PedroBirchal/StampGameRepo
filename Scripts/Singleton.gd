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
