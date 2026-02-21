class_name Encomenda
extends RigidBody3D

enum EstadoEncomenda { PARADA, INSPECIONANDO, ABERTA }

@export var estado_atual := EstadoEncomenda.PARADA

var rotating : bool = false
var selecionado : bool = false

signal abrindo
signal fechando
signal clicando
signal estado_mudado(estado: EstadoEncomenda)

func _ready() -> void:
	input_event.connect(_on_input_event)

func set_estado(estado: EstadoEncomenda) -> void:
	if estado == estado_atual:
		return
	
	if estado_atual == EstadoEncomenda.INSPECIONANDO:
		rotating = false
		selecionado = false
		rotation = Vector3.ZERO
		position = Vector3.ZERO
		dir = Vector2.ZERO
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
		freeze = false
	
	estado_mudado.emit(estado_atual)


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicando.emit()
			if not selecionado and estado_atual == EstadoEncomenda.INSPECIONANDO:
				selecionado = true
				get_viewport().set_input_as_handled()

var dir : Vector2
func _physics_process(delta: float):
	if estado_atual == EstadoEncomenda.INSPECIONANDO:
		rotate_object_local(Vector3.UP, dir.x * .7 * delta)
		rotate_object_local(Vector3.RIGHT, dir.y * .7 * delta)

func _input(event):
	if selecionado and estado_atual == EstadoEncomenda.INSPECIONANDO:
		if event is InputEventMouseButton:
			rotating = event.is_pressed()
		
		if event is InputEventMouseMotion and rotating:
			dir = event.relative
		else:
			dir = Vector2.ZERO
			
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				selecionado = false
				rotating = false
