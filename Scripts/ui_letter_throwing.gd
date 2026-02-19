extends Control

@onready var timer : Label = $TimerLabel
var milisegundos : int
var segundos : int
var minutos : int
@onready var pontuacao : Label = $Pontuacao

func atualizar_pontuacao(pontos : int) -> void :
	pontuacao.text = "x" + str(pontos)

func atualizar_timer(tempo_restante) -> void:
	minutos = int(tempo_restante) / 60
	segundos = int(tempo_restante) % 60
	milisegundos = int(tempo_restante * 100) % 100
	timer.text = "%02d:%02d:%02d" % [minutos, segundos, milisegundos]
