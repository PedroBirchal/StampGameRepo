extends Node3D

@export var cor_default : Color
@export var cor_piscante : Color 
@export var duracao_da_piscada : float
@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var timer : Timer = $Timer

func _ready() -> void :
	hide()

func on_box_hovered(posicao_caixa):
	global_position = posicao_caixa 
	show()

func on_box_unhovered():
	hide()

func _on_timer_timeout() -> void:
	sprite.modulate = cor_default

func on_box_clicked(_argumento) -> void :
	sprite.modulate = cor_piscante
	timer.start(duracao_da_piscada)
