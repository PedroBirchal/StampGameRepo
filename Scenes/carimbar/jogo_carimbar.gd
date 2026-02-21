extends Node3D

@export_group("Spawn Encomendas")
@export var carta_prefab: PackedScene
var encomenda_atual: Encomenda

@export_group("Inspecionar Encomendas")
@export var pos_na_cara: Node3D
@export var pos_bem_na_cara: Node3D
@export var sair_inspecionar_trigger: Node3D

@export_group("Sistema recebe e entrega")
@export var pos_meio_mesa: Node3D
@export var pos_receber_proximo: Node3D
var proxima_encomenda: Encomenda


func _ready() -> void:
	proxima_encomenda = gerar_nova_encomenda()
	pos_receber_proximo.add_child(proxima_encomenda)


func tem_encomenda_no_meio() -> bool:
	return encomenda_atual != null

func tem_encomenda_para_pegar() -> bool:
	return proxima_encomenda != null


func mandar_encomenda_nova_ao_centro() -> void:
	if not tem_encomenda_para_pegar() or tem_encomenda_no_meio():
		return
	
	proxima_encomenda.reparent(pos_meio_mesa)
	proxima_encomenda.clicando.disconnect(mandar_encomenda_nova_ao_centro)
	encomenda_atual = proxima_encomenda
	encomenda_atual.position = Vector3.ZERO
	encomenda_atual.clicando.connect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.connect(encomenda_atual_mudou_estado)
	
	proxima_encomenda = gerar_nova_encomenda()
	proxima_encomenda.clicando.connect(mandar_encomenda_nova_ao_centro)
	pos_receber_proximo.add_child(proxima_encomenda)


func _on_mandar_pra_la(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mandar_encomenda_atual_para_destino()


func mandar_encomenda_atual_para_destino() -> void:
	if not tem_encomenda_no_meio() or encomenda_atual.estado_atual != Encomenda.EstadoEncomenda.PARADA:
		return
	
	encomenda_atual.clicando.disconnect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.disconnect(encomenda_atual_mudou_estado)
	encomenda_atual.queue_free()
	encomenda_atual = null


func gerar_nova_encomenda() -> Node3D:
	var encomenda = carta_prefab.instantiate()
	return encomenda


func encomenda_atual_selecionada() -> void:
	if encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA:
		encomenda_atual.reparent(pos_na_cara)
		encomenda_atual.position = Vector3.ZERO
		encomenda_atual.set_estado(Encomenda.EstadoEncomenda.INSPECIONANDO)
		sair_inspecionar_trigger.show()


func encomenda_atual_mudou_estado(estado: Encomenda.EstadoEncomenda) -> void:
	if estado == Encomenda.EstadoEncomenda.ABERTA:
		encomenda_atual.reparent(pos_bem_na_cara)
		encomenda_atual.position = Vector3.ZERO
	elif estado == Encomenda.EstadoEncomenda.INSPECIONANDO:
		encomenda_atual.reparent(pos_na_cara)
		encomenda_atual.position = Vector3.ZERO


func _clicar_sair_inspecionar(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.ABERTA:
				encomenda_atual.set_estado(Encomenda.EstadoEncomenda.INSPECIONANDO)
			elif encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.INSPECIONANDO:
				encomenda_atual.reparent(pos_meio_mesa)
				encomenda_atual.position = Vector3.ZERO
				encomenda_atual.set_estado(Encomenda.EstadoEncomenda.PARADA)
				sair_inspecionar_trigger.hide()
