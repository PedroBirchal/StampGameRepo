extends Node3D

@export var caixas : Array[Node] = []
@onready var indicador : Node = $Indicador
@onready var carta : Node = $CartaController
@onready var contador : Label = $UiLetterThrowing/Pontuacao
var pontuacao : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contador.text = "x" + str(pontuacao)
	for caixa in caixas:
		caixa.box_hover.connect(indicador.on_box_hovered)
		caixa.box_unhover.connect(indicador.on_box_unhovered)
		caixa.box_clicked.connect(carta.on_target_clicked)
		caixa.pontuar.connect(pontuar)

func pontuar(pontos : int) -> void :
	pontuacao += pontos
	if pontuacao < 0 : pontuacao = 0
	contador.text = "x" + str(pontuacao)
