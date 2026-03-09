## Para todas as coisas, isso é um GameManager
class_name Jogo
extends Node

static var instance: Jogo
var comecou := false

enum Estado { QUARTO, JOGANDO }

signal fim_de_jogo
var carimbos_incorretos = 0
var envios_incorretos = 0
var saldo_final = 0

var pontuacao : int = 0
var aluguel : int = 800
var estado := Estado.QUARTO
var jogavel_atual : Jogavel
@export var jogador : Jogador
@export var decretos : DecretosController
@export var camera_principal : Camera3D
@export var jogo_carimbo : JogoCarimbar
@export var jogo_cartas : Node3D
@export var telefone : Telefone

@export_group("UI")
@export var fade : FadeController
@export var quarto_ui : Control
@export var dialogo : Dialogo
@export var texto_fim_de_jogo : Control
@export var sair_jogavel_btn : TextureButton
@export var texto_impedimento : Label
@export var impedimento_tela : Control

@export_group("Timer")
@export var ui_timer_pontuacao : Control
@export var relogio_mesa : Node3D
@export var timer : Timer
@export var duracao_do_dia : float = 300 # em segundos

@export_group("Impedimentos")
@export_multiline var impedir_por_ligacao : String
@export_multiline var impedir_por_ligacao_comeco : String
@export_multiline var impedir_sem_cartas : String
var ta_impedido := false



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
	if pontuacao < 0 : 
		pontuacao = 0
		envios_incorretos += 1
	ui_timer_pontuacao.atualizar_pontuacao(pontuacao)

func jogavel_iniciado(jogavel: Jogavel) -> void:
	if jogavel_atual == jogavel:
		return
	
	sair_jogavel_btn.visible = jogavel.pode_sair
	jogavel_atual = jogavel
	jogavel_atual.saindo.connect(jogavel_encerrado)
	mudar_estado(Estado.JOGANDO)

func jogavel_encerrado() -> void:
	jogavel_atual.saindo.disconnect(jogavel_encerrado)
	camera_principal.make_current()
	sair_jogavel_btn.hide()
	limpar_impedimento()
	mudar_estado(Estado.QUARTO)
	jogavel_atual = null

func _handle_sair_jogavel() -> void:
	if jogavel_atual == null:
		return
	jogavel_atual.sair()

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
	
	var mesh_sumivel = sumiveis.filter(func(x): return x is MeshInstance3D)
	
	for sumivel: MeshInstance3D in mesh_sumivel:
		for i in range(0, sumivel.get_surface_override_material_count()):
			var mat: StandardMaterial3D = sumivel.get_active_material(i)
			if mat == null:
				continue
			
			mat = mat.duplicate()
			
			if mat.transparency == 3 and not pode_sumir:
				mat.transparency = 0 as BaseMaterial3D.Transparency
			if mat.transparency == 0 and pode_sumir:
				mat.transparency = 3 as BaseMaterial3D.Transparency
			
			sumivel.set_surface_override_material(i, mat)
	

# Fim de jogo
func _on_timer_do_jogo_timeout() -> void:
	fim_de_jogo.emit()
	texto_fim_de_jogo.mostrar_fim_de_jogo()
	await get_tree().create_timer(2.0).timeout
	carimbos_incorretos = decretos.entregas_incorretas
	saldo_final = pontuacao - aluguel
	get_tree().change_scene_to_file("res://Scenes/c_ena_final.tscn")



func criar_impedimento(texto: String) -> void:
	texto_impedimento.text = texto
	impedimento_tela.visible = true
	ta_impedido = true

func limpar_impedimento() -> void:
	texto_impedimento.text = ""
	impedimento_tela.visible = false
	ta_impedido = false


func _on_telefone_tocando() -> void:
	if jogavel_atual == jogo_carimbo:
		jogo_carimbo.checar_impedimento_ligacao()

func impedir_por_chamada() -> void:
	if not comecou:
		criar_impedimento(impedir_por_ligacao_comeco)
	else:
		criar_impedimento(impedir_por_ligacao)


func _on_telefone_chamada_encerrada() -> void:
	if not comecou:
		comecou = true


func _on_telefone_atendido() -> void:
	limpar_impedimento()
