## Para todas as coisas, isso é um GameManager
class_name Jogo
extends Node

static var instance: Jogo

enum Estado { QUARTO, JOGANDO }

signal fim_de_jogo

var pontuacao : int = 0
var estado := Estado.QUARTO
var jogavel_atual : Jogavel
@export var jogador : Jogador
@export var decretos : DecretosController
@export var camera_principal : Camera3D
@export var jogo_carimbo : JogoCarimbar

@export_group("UI")
@export var fade : FadeController
@export var quarto_ui : Control
@export var dialogo : Dialogo

@export_group("Timer")
@export var ui_timer_pontuacao : Control
@export var relogio_mesa : Node3D
@export var timer : Timer
@export var duracao_do_dia : float = 300 # em segundos


func _init() -> void:
	instance = self

func _ready() -> void:
	atualizar_sumiveis()
	if not timer.is_node_ready() :
		await timer.ready
	timer.start(duracao_do_dia)
	if not ui_timer_pontuacao.is_node_ready() :
		await ui_timer_pontuacao.ready
	ui_timer_pontuacao.setup_timer(timer)
	relogio_mesa.set_timer(timer)

func pontuar(pontos : int) -> void :
	pontuacao += pontos
	if pontuacao < 0 : pontuacao = 0
	ui_timer_pontuacao.atualizar_pontuacao(pontuacao)

func jogavel_iniciado(jogavel: Jogavel) -> void:
	if jogavel_atual == jogavel:
		return
	
	jogavel_atual = jogavel
	jogavel_atual.saindo.connect(jogavel_encerrado)
	mudar_estado(Estado.JOGANDO)

func jogavel_encerrado() -> void:
	jogavel_atual.saindo.disconnect(jogavel_encerrado)
	camera_principal.make_current()
	mudar_estado(Estado.QUARTO)
	jogavel_atual = null


func mudar_estado(std: Estado) -> void:
	if estado == std:
		return
	
	estado = std
	
	if estado == Estado.QUARTO:
		quarto_ui.show()
		jogador.show()
	elif estado == Estado.JOGANDO:
		quarto_ui.hide()
		if jogavel_atual.sumir_jogador:
			jogador.hide()
	
	atualizar_sumiveis()

func atualizar_sumiveis() -> void:
	var sumiveis = get_tree().get_nodes_in_group("sumivel")
	var pode_sumir = estado == Estado.QUARTO
	
	for sumivel: MeshInstance3D in sumiveis:
		for i in range(0, sumivel.get_surface_override_material_count()):
			var mat: StandardMaterial3D = sumivel.get_active_material(i)
			if mat == null:
				continue
			
			mat = mat.duplicate()
			
			if mat.transparency == 3 and not pode_sumir:
				mat.transparency = 0 
			if mat.transparency == 0 and pode_sumir:
				mat.transparency = 3
			
			sumivel.set_surface_override_material(i, mat)

# Fim de jogo
func _on_timer_do_jogo_timeout() -> void:
	fim_de_jogo.emit()
	get_tree().change_scene_to_file("res://Scenes/c_ena_final.tscn")
