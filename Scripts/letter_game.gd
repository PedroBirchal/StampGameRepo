extends Node3D

@export var caixas : Array[Node] = []
@onready var indicador : Node = $Indicador

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for caixa in caixas:
		caixa.box_hover.connect(indicador.on_box_hovered)
		caixa.box_unhover.connect(indicador.on_box_unhovered)
