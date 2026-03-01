extends Control

@onready var fim_de_jogo_label : Label = $"LabelFimDeJogo"
@export var posicao_final : Control
@export var posicao_inicial : Control
var tween

func mostrar_fim_de_jogo() -> void :
	tween = create_tween()
	tween.tween_property(fim_de_jogo_label, "position", posicao_final, 1)
