extends Jogavel


@export var camera: Camera3D

var caixas : Array[Node]
@export var max_time : float = 10
@onready var armario : Node = $Armario/Caixas
@onready var indicador : Node = $Indicador
@onready var carta_controller : Node = $CartaController
var pontuacao : int = 0


func jogar() -> void:
	super()
	camera.make_current()
	carta_controller.instantiate_new_carta()
	carta_controller.active = true

func sair() -> void:
	super()
	camera.clear_current()
	
	carta_controller.retornar_carta()

func mudar_cartas(ativar: bool) -> void:
	var cartas = get_tree().get_nodes_in_group("colisao_da_carta")


func _ready() -> void:
	super()
	caixas = armario.get_children()
	for caixa in caixas:
		if indicador != null:
			caixa.box_hover.connect(indicador.on_box_hovered)
			caixa.box_unhover.connect(indicador.on_box_unhovered)
			caixa.box_clicked.connect(indicador.on_box_clicked)
		if carta_controller != null :
			caixa.box_clicked.connect(carta_controller.on_target_clicked)
	if Jogo.instance :
		Jogo.instance.fim_de_jogo.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if carta_controller != null :
		carta_controller.active = false
