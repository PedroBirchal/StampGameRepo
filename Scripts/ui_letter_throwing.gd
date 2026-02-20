extends Control

@export_category("Configurações de animação :")
@export var label_tween_scale : float = 1.5
@export var label_wiggle_intensity : float = 20

@onready var pontuacao : Label = $Pontuacao
@onready var timer : Label = $TimerLabel
var milisegundos : int
var segundos : int
var minutos : int
var pontuacao_atual : int = 0
var tween


func atualizar_pontuacao(pontos : int) -> void :
	if pontos > pontuacao_atual :
		animar_pontuacao_aumentando()
	else:
		animar_pontuacao_diminuindo()
	pontuacao.text = "x" + str(pontos)
	pontuacao_atual = pontos

func animar_pontuacao_aumentando() -> void :
	if tween:
		tween.kill()
	tween = create_tween()
	var o_text_color = pontuacao.label_settings.font_color
	pontuacao.label_settings.font_color = Color.SPRING_GREEN
	tween.finished.connect(func(): pontuacao.label_settings.font_color = o_text_color)
	tween.tween_property(pontuacao, "scale", Vector2(label_tween_scale, label_tween_scale), 0.05)
	tween.tween_property(pontuacao, "scale", Vector2(1, 1), 0.05)

func animar_pontuacao_diminuindo() -> void :
	if tween:
		tween.kill()
	tween = create_tween()
	randomize()
	var o_position = pontuacao.position
	var o_text_color = pontuacao.label_settings.font_color
	pontuacao.label_settings.font_color = Color.INDIAN_RED
	tween.finished.connect(func(): pontuacao.label_settings.font_color = o_text_color)
	for i in range(10):
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		tween.tween_property(pontuacao, "position", o_position + direction * label_wiggle_intensity, 0.01)
	tween.tween_property(pontuacao, "position", o_position, 0.01)

func atualizar_timer(tempo_restante) -> void:
	minutos = int(tempo_restante) / 60
	segundos = int(tempo_restante) % 60
	milisegundos = int(tempo_restante * 100) % 100
	timer.text = "%02d:%02d:%02d" % [minutos, segundos, milisegundos]
