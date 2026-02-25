extends Jogavel

@export var camera: Camera3D
@export var spawner: Node3D
var encomenda_atual: Encomenda

@export_group("Inspecionar Encomendas")
@export var pos_pacote_na_cara: Node3D
@export var pos_pacote_aberto: Node3D
@export var pos_carta_na_cara: Node3D
@export var pos_carta_aberta: Node3D
@export var sair_inspecionar_trigger: Node3D

@export_group("Sistema recebe e entrega")
@export var pos_meio_mesa: Node3D
@export var pos_receber_proximo: Node3D
var proxima_encomenda: Encomenda

var ja_comecou = false


func jogar() -> void:
	super()
	
	if not ja_comecou:
		ja_comecou = true
		proxima_encomenda = gerar_nova_encomenda()
		pos_receber_proximo.add_child(proxima_encomenda)
	
	camera.make_current()
	

func sair() -> void:
	super()
	
	if encomenda_atual != null and encomenda_atual.estado_atual != Encomenda.EstadoEncomenda.PARADA:
		sair_inspecionar()
		sair_inspecionar()
	
	camera.clear_current()

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
	
	var tween = get_tree().create_tween()
	tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_CUBIC)
	
	encomenda_atual.clicando.connect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.connect(encomenda_atual_mudou_estado)
	
	proxima_encomenda = gerar_nova_encomenda()
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
	var encomenda = spawner.spawn()
	encomenda.clicando.connect(mandar_encomenda_nova_ao_centro)
	return encomenda


func encomenda_atual_selecionada() -> void:
	if encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA:
		encomenda_atual.set_estado(Encomenda.EstadoEncomenda.INSPECIONANDO)
		sair_inspecionar_trigger.show()


func encomenda_atual_mudou_estado(estado: Encomenda.EstadoEncomenda) -> void:
	
	if estado == Encomenda.EstadoEncomenda.ABERTA:
		var pos_aberto = pos_carta_aberta if encomenda_atual is Carta else pos_pacote_aberto
		encomenda_atual.reparent(pos_aberto)
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25)
		tween.tween_property(encomenda_atual, "rotation", Vector3.ZERO, 0.25)
	elif estado == Encomenda.EstadoEncomenda.INSPECIONANDO:
		var pos_na_cara = pos_carta_na_cara if encomenda_atual is Carta else pos_pacote_na_cara
		encomenda_atual.reparent(pos_na_cara)
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(encomenda_atual, "rotation", Vector3.ZERO, 0.25)
		tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25)


func _clicar_sair_inspecionar(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			sair_inspecionar()

func sair_inspecionar() -> void:
	if encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.ABERTA:
		encomenda_atual.set_estado(Encomenda.EstadoEncomenda.INSPECIONANDO)
	elif encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.INSPECIONANDO:
		encomenda_atual.reparent(pos_meio_mesa)
		
		var tween = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25)
		tween.tween_property(encomenda_atual, "rotation", Vector3.ZERO, 0.25)

		#encomenda_atual.position = Vector3.ZERO
		encomenda_atual.set_estado(Encomenda.EstadoEncomenda.PARADA)
		sair_inspecionar_trigger.hide()
