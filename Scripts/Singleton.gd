extends Node

enum Cidades {
	BICADAS,
	BELO_NINHO,
	POUSO_VELHO,
	AVIARIO,
}
var cores : Array[Color] = [Color.AQUAMARINE, Color.INDIAN_RED, Color.INDIGO, Color.BURLYWOOD]

enum Direcao { FRENTE, ESQUERDA, COSTAS, DIREITA }

## Dicionario de grupos relacionando a direção e o grupo que deve sumir na direção, referente ao quarto
var direcao_grupo = {
	Direcao.FRENTE: "frente_quarto",
	Direcao.ESQUERDA: "esquerda_quarto",
	Direcao.COSTAS: "costas_quarto",
	Direcao.DIREITA: "direita_quarto",
}
