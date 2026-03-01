class_name Encomenda
extends RigidBody3D

enum EstadoEncomenda { PARADA, INSPECIONANDO, ABERTA }

enum EstadoEntregue { EM_ANALISE, ENTREGUE, DESCARTADA }

@export var estado_atual := EstadoEncomenda.PARADA
var rotating : bool = false
var selecionado : bool = false

signal abrindo
signal fechando
signal clicando
signal estado_mudado(estado: EstadoEncomenda)

var carimbos: Array[String]

@export var rotacionavel : Rotacionavel

@export var caracteristicas : PackedStringArray


var vindo_de : Singleton.Cidades
var indo_para : Singleton.Cidades

var estado_entregue = EstadoEntregue.EM_ANALISE

func _ready() -> void:
	input_event.connect(_on_input_event)

func set_estado(estado: EstadoEncomenda) -> void:
	if estado == estado_atual:
		return
	
	if estado_atual == EstadoEncomenda.INSPECIONANDO:
		rotating = false
		selecionado = false
	elif estado_atual == EstadoEncomenda.ABERTA:
		fechando.emit()
	
	estado_atual = estado
	
	if estado_atual == EstadoEncomenda.INSPECIONANDO:
		gravity_scale = 0
		freeze = true
	elif estado_atual == EstadoEncomenda.ABERTA:
		abrindo.emit()
	elif estado_atual == EstadoEncomenda.PARADA:
		gravity_scale = 1
		freeze = true
	
	estado_mudado.emit(estado_atual)


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicando.emit()


func recebeu_carimbo(carimbo: String) -> void:
	carimbos.append(carimbo)
