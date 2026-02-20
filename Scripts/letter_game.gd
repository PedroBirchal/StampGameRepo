extends Node3D

@export var caixas : Array[Node] = []
@export var max_time : float = 10
@onready var indicador : Node = $Indicador
@onready var carta_controller : Node = $CartaController
@onready var ui : Node = $UiLetterThrowing
@onready var timer : Timer = $Timer
var pontuacao : int = 0

func _ready() -> void:
	for caixa in caixas:
		if indicador != null:
			caixa.box_hover.connect(indicador.on_box_hovered)
			caixa.box_unhover.connect(indicador.on_box_unhovered)
			caixa.box_clicked.connect(indicador.on_box_clicked)
		if carta_controller != null :
			caixa.box_clicked.connect(carta_controller.on_target_clicked)
		caixa.pontuar.connect(pontuar)
	timer.wait_time = max_time
	timer.start()

func _process(delta: float) -> void:
	ui.atualizar_timer(timer.time_left)

func pontuar(pontos : int) -> void :
	pontuacao += pontos
	if pontuacao < 0 : pontuacao = 0
	ui.atualizar_pontuacao(pontuacao)


func _on_timer_timeout() -> void:
	if carta_controller != null : carta_controller.active = false
