class_name JogoCarimbar
extends Jogavel

@export var camera: Camera3D
@export var spawner: Node3D
var encomenda_atual: Encomenda

@export var rotacionavel: Rotacionavel
@export var ui_girar: Control
@export var ui_girar_horizontal: Control
@export var ui_girar_vertical: Control
@export var botao_gira_cima: Control
@export var botao_gira_baixo: Control

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

@export_group("PostIts")
@export var pos_postit_cara: Node3D
@export var postit_prefab: PackedScene
@export var postits_pin_list: Array[Node3D]
var postits_pin_idx = 0


var ja_comecou = false

## Sempre que muda a encomenda_atual, chama o sinal com o valor dela
signal mudou_encomenda(encomenda: Encomenda)

signal encomenda_despachada(encomenda: Encomenda)


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
	
	
	mudou_encomenda.emit(encomenda_atual)
	
	proxima_encomenda = gerar_nova_encomenda()
	pos_receber_proximo.add_child(proxima_encomenda)


func _on_mandar_pra_la(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mandar_encomenda_atual_para_destino()


func mandar_encomenda_atual_para_destino() -> void:
	if not tem_encomenda_no_meio() or encomenda_atual.estado_atual != Encomenda.EstadoEncomenda.PARADA:
		return
	
	encomenda_atual.estado_entregue = Encomenda.EstadoEntregue.ENTREGUE
	encomenda_despachada.emit(encomenda_atual)
	
	await Jogo.instance.decretos.apos_checar_corretude
	
	encomenda_atual.clicando.disconnect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.disconnect(encomenda_atual_mudou_estado)
	encomenda_atual.queue_free()
	encomenda_atual = null
	
	mudou_encomenda.emit(null)


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
		
		if rotacionavel != null:
			rotacionavel.giro_vertical_mudou.disconnect(refresh_modo_giro_vertical)
		rotacionavel = null
		setar_modo_girando(false)
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25)
		tween.tween_property(encomenda_atual, "rotation", Vector3.ZERO, 0.25)
	elif estado == Encomenda.EstadoEncomenda.INSPECIONANDO:
		var pos_na_cara = pos_carta_na_cara if encomenda_atual is Carta else pos_pacote_na_cara
		encomenda_atual.reparent(pos_na_cara)
		
		rotacionavel = encomenda_atual.rotacionavel
		refresh_modo_giro_vertical()
		rotacionavel.giro_vertical_mudou.connect(refresh_modo_giro_vertical)
		setar_modo_girando(true)
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(encomenda_atual, "rotation", Vector3.ZERO, 0.25)
		tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25)
	else:
		if rotacionavel != null:
			rotacionavel.giro_vertical_mudou.disconnect(refresh_modo_giro_vertical)
			
		rotacionavel = null
		setar_modo_girando(false)


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
		encomenda_atual.set_estado(Encomenda.EstadoEncomenda.PARADA)
		sair_inspecionar_trigger.hide()


func _on_botao_girar_esquerda() -> void:
	if rotacionavel != null:
		rotacionavel.girar(-1)


func _on_botao_girar_direita() -> void:
	if rotacionavel != null:
		rotacionavel.girar(1)

func _on_botao_girar_cima() -> void:
	if rotacionavel != null:
		rotacionavel.girar_vertical(1)


func _on_botao_girar_baixo() -> void:
	if rotacionavel != null:
		rotacionavel.girar_vertical(-1)

func setar_modo_girando(girando: bool) -> void:
	ui_girar.visible = girando

func refresh_modo_giro_vertical(_aux := 0) -> void:
	ui_girar_vertical.visible = rotacionavel.rotaciona_na_vertical
	
	if rotacionavel.rot_vertical == 0:
		botao_gira_cima.visible = rotacionavel.pode_rot_cima
		botao_gira_baixo.visible = rotacionavel.pode_rot_baixo
		ui_girar_horizontal.visible = true
	elif rotacionavel.rot_vertical == 1:
		botao_gira_cima.visible = false
		botao_gira_baixo.visible = true
		ui_girar_horizontal.visible = false
	elif rotacionavel.rot_vertical == -1:
		botao_gira_cima.visible = true
		botao_gira_baixo.visible = false
		ui_girar_horizontal.visible = false
	else:
		ui_girar_horizontal.visible = true
		

func gerar_post_it(decreto_res: DecretoResource) -> PostIt:
	postits_pin_idx += 1
	
	if postits_pin_idx >= len(postits_pin_list):
		print("Sem pins para novos decretos")
		return null
	
	var postit_pin = postits_pin_list[postits_pin_idx]
	var postit: PostIt = postit_prefab.instantiate()
	postit_pin.add_child(postit)
	postit.pin = postit_pin
	postit.set_texto(decreto_res.informativo)
	
	postit.clicado.connect(clicou_post_it)
	
	return postit

func clicou_post_it(postit: PostIt) -> void:
	if postit.get_parent() != postit.pin:
		postit.reparent(postit.pin)
		var tween = get_tree().create_tween()
		tween.tween_property(postit, "position", Vector3.ZERO, 0.3)
	elif postit.get_parent() == postit.pin:
		postit.reparent(pos_postit_cara)
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(postit, "position", Vector3.ZERO, 0.6)
