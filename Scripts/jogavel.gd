class_name Jogavel
extends Node

signal entrando
signal saindo

@export var desativar_on_jogar: Array[Node]
@export var desativar_colisor_on_jogar: Array[CollisionShape3D]
@export var reativar_ao_sair := true

@export var ativar_on_jogar: Array[Node]
@export var ativar_colisor_on_jogar: Array[CollisionShape3D]
@export var desativar_ao_sair := true

@export var sumir_jogador := true

@export var jogavel_ui : Control

func _ready() -> void:
	if jogavel_ui != null:
		jogavel_ui.hide()
	
	if desativar_ao_sair:
		if not ativar_on_jogar.is_empty():
			for desativar in ativar_on_jogar:
				desativar.hide()
		if not ativar_colisor_on_jogar.is_empty():
			for desativar in ativar_colisor_on_jogar:
				desativar.disabled = true

func jogar() -> void:
	entrando.emit()
	
	if jogavel_ui != null:
		jogavel_ui.show()
	
	Jogo.instance.jogavel_iniciado(self)
	
	if not desativar_on_jogar.is_empty():
		for desativar in desativar_on_jogar:
			desativar.hide()
	if not desativar_colisor_on_jogar.is_empty():
		for desativar in desativar_colisor_on_jogar:
			desativar.disabled = true
	
	if not ativar_on_jogar.is_empty():
		for ativar in ativar_on_jogar:
			ativar.show()
	if not ativar_colisor_on_jogar.is_empty():
		for ativar in ativar_colisor_on_jogar:
			ativar.disabled = false

func sair() -> void:
	saindo.emit()
	
	if jogavel_ui != null:
		jogavel_ui.hide()
	
	if reativar_ao_sair:
		if not desativar_on_jogar.is_empty():
			for desativar in desativar_on_jogar:
				desativar.show()
		if not desativar_colisor_on_jogar.is_empty():
			for desativar in desativar_colisor_on_jogar:
				desativar.disabled = false
	
	if desativar_ao_sair:
		if not ativar_on_jogar.is_empty():
			for ativar in ativar_on_jogar:
				ativar.hide()
		if not ativar_colisor_on_jogar.is_empty():
			for ativar in ativar_colisor_on_jogar:
				ativar.disabled = true
