extends Node3D

func _ready() -> void :
	hide()

func on_box_hovered(posicao_caixa):
	position = posicao_caixa 
	show()

func on_box_unhovered():
	hide()
