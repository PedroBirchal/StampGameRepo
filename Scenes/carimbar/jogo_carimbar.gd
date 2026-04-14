class_name JogoCarimbar
extends Jogavel

@export var camera: Camera3D
@export var spawner: Node3D
var encomenda_atual: Encomenda
var encomenda_atual_ultimo_estado: Encomenda.EstadoEncomenda

@export var rotacionavel: Rotacionavel
@export var ui_girar: Control
@export var ui_girar_horizontal: Control
@export var botao_abrir_cima: Control

@export_group("Inspecionar Encomendas")
@export var pos_pacote_na_cara: Node3D
@export var pos_pacote_p_na_cara: Node3D
@export var pos_pacote_g_na_cara: Node3D
@export var pos_item_na_cara: Node3D
@export var pos_carta_na_cara: Node3D
@export var sair_inspecionar_trigger: Node3D

@export var texto_carta_holder: Node3D
@export var texto_carta_label: Label3D

@export_group("Descanso Caixa com Item Aberto")
@export var descanso_caixa_p: Node3D
@export var descanso_caixa_m: Node3D
@export var descanso_caixa_g: Node3D



@export_group("Sistema recebe e entrega")
@export var pos_meio_mesa: Node3D
@export var pos_receber_proximo: Node3D
@export var pos_receber_proxima_carta: Node3D
var proxima_encomenda: Encomenda

@export_group("PostIts")
@export var pos_postit_cara: Node3D
@export var postit_prefab: PackedScene
@export var postits_pin_list: Array[Node3D]
var postits_pin_idx = 0

@export_group("Colocadores")
@export var cesto: CestoCarta
@export var lixo: Lixo
@export var estoque: EstoqueCaixa


var ja_comecou = false

## Sempre que muda a encomenda_atual, chama o sinal com o valor dela
signal mudou_encomenda(encomenda: Encomenda)

signal encomenda_despachada(encomenda: Encomenda)


func jogar() -> void:
	super()
	
	if not ja_comecou:
		ja_comecou = true
		proxima_encomenda = gerar_nova_encomenda()
		if proxima_encomenda is Pacote:
			pos_receber_proximo.add_child(proxima_encomenda)
		else:
			pos_receber_proxima_carta.add_child(proxima_encomenda)
	
	checar_impedimento_ligacao()
	
	setar_modo_girando(false)
	
	camera.make_current()

func sair() -> void:
	super()
	
	if encomenda_atual != null and encomenda_atual.estado_atual != Encomenda.EstadoEncomenda.PARADA:
		sair_inspecionar()
		sair_inspecionar()
	
	preview_unhover_cesto()
	preview_unhover_estoque()
	preview_unhover_lixo()
	force_postit_out()
	
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
	encomenda_atual_ultimo_estado = Encomenda.EstadoEncomenda.PARADA
	
	var tween = get_tree().create_tween()
	tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_CUBIC)
	
	encomenda_atual.clicando.connect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.connect(encomenda_atual_mudou_estado)
	
	
	mudou_encomenda.emit(encomenda_atual)
	
	proxima_encomenda = gerar_nova_encomenda()
	
	if proxima_encomenda is Pacote:
		pos_receber_proximo.add_child(proxima_encomenda)
	else:
		pos_receber_proxima_carta.add_child(proxima_encomenda)

func gerar_nova_encomenda() -> Node3D:
	var encomenda = spawner.spawn()
	encomenda.clicando.connect(mandar_encomenda_nova_ao_centro)
	return encomenda


func encomenda_atual_selecionada() -> void:
	if encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA:
		encomenda_atual.set_estado(Encomenda.EstadoEncomenda.INSPECIONANDO)
		sair_inspecionar_trigger.show()


func encomenda_atual_mudou_estado(estado: Encomenda.EstadoEncomenda) -> void:
	if encomenda_atual_ultimo_estado != Encomenda.EstadoEncomenda.PARADA and estado != Encomenda.EstadoEncomenda.PARADA:
		Jogo.instance.fade.transicao()
		await Jogo.instance.fade.terminou_escurecer
	
	if estado == Encomenda.EstadoEncomenda.ABERTA:
		if encomenda_atual is Carta:
			texto_carta_holder.show()
			texto_carta_label.text = (encomenda_atual as Carta).carta_res.conteudo
		else:
			var pacote = encomenda_atual as Pacote
			var pos_off = pacote.item_res.offset_pos_mostrar if not pacote.com_defeito else pacote.item_res.offset_pos_defeito
			var rot_off = pacote.item_res.offset_rot_mostrar if not pacote.com_defeito else pacote.item_res.offset_rot_defeito
			
			pacote.item_holder.reparent(pos_item_na_cara)
			pacote.item_holder.position = pos_off
			pacote.item_holder.rotation = Vector3.ZERO
			pacote.item.rotation = rot_off
			
			if pacote.tamanho_pacote == ItemResource.TamanhoPacote.PEQUENO:
				pacote.reparent(descanso_caixa_p)
			elif pacote.tamanho_pacote == ItemResource.TamanhoPacote.MEDIO:
				pacote.reparent(descanso_caixa_m)
			else:
				pacote.reparent(descanso_caixa_g)
			pacote.position = Vector3.ZERO
			pacote.rotation = Vector3.ZERO
			pacote.pacote_aberto = true
			
		rotacionavel = null
		setar_modo_girando(false)
		
	elif estado == Encomenda.EstadoEncomenda.INSPECIONANDO:
		if encomenda_atual is Carta:
			texto_carta_holder.hide()
			texto_carta_label.text = ""
			botao_abrir_cima.hide()
		else:
			var pacote = encomenda_atual as Pacote
			pacote.item_holder.reparent(pacote.conteudo_holder)
			pacote.item_holder.position = Vector3.ZERO
			pacote.item.rotation = pacote.item_res.offset_rot
			pacote.pacote_aberto = false
			botao_abrir_cima.show()
		
		rotacionavel = encomenda_atual.rotacionavel
		setar_modo_girando(true)
		
		var pos_na_cara = pos_carta_na_cara
		if encomenda_atual is Pacote:
			var pac = encomenda_atual as Pacote
			match pac.item_res.cabe_em:
				ItemResource.TamanhoPacote.GRANDE:
					pos_na_cara = pos_pacote_g_na_cara
				ItemResource.TamanhoPacote.MEDIO:
					pos_na_cara = pos_pacote_na_cara
				ItemResource.TamanhoPacote.PEQUENO:
					pos_na_cara = pos_pacote_p_na_cara
	
		
		encomenda_atual.reparent(pos_na_cara)
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(encomenda_atual, "rotation", Vector3.ZERO, 0.25)
		tween.tween_property(encomenda_atual, "position", Vector3.ZERO, 0.25)
	else:
		if encomenda_atual is Pacote:
			encomenda_atual.freeze = false
			
		rotacionavel = null
		setar_modo_girando(false)
	
	encomenda_atual_ultimo_estado = estado

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

func setar_modo_girando(girando: bool) -> void:
	ui_girar.visible = girando


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
		tween.tween_property(postit, "rotation", Vector3.ZERO, 0.3)
	elif postit.get_parent() == postit.pin:
		postit.reparent(pos_postit_cara)
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(postit, "position", Vector3.ZERO, 0.6)
		tween.tween_property(postit, "rotation", Vector3.ZERO, 0.6)

func force_postit_out() -> void:
	if pos_postit_cara.get_child_count() > 0:
		clicou_post_it(pos_postit_cara.get_child(0) as PostIt)


var previewing_no_lixo = false
func preview_hover_lixo() -> void:
	if encomenda_atual != null and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA:
		encomenda_atual.freeze = true
		encomenda_atual.reparent(lixo.deletar_holder)
		encomenda_atual.position = Vector3.ZERO
		previewing_no_lixo = true

func preview_unhover_lixo() -> void:
	if encomenda_atual != null and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA and previewing_no_lixo:
		encomenda_atual.freeze = encomenda_atual is Carta
		encomenda_atual.reparent(pos_meio_mesa)
		encomenda_atual.position = Vector3.ZERO
		previewing_no_lixo = false

func clicou_encomenda_lixo() -> void:
	if encomenda_atual != null and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA and previewing_no_lixo:
		var encomenda = encomenda_atual
		_encomenda_mandada_pro_lixo()
		lixo.excluir(encomenda)

func encomenda_lixada(_encomenda: Encomenda) -> void:
	print("lixooo")

func _encomenda_mandada_pro_lixo() -> void:
	encomenda_atual.estado_entregue = Encomenda.EstadoEntregue.DESCARTADA
	encomenda_despachada.emit(encomenda_atual)
	
	encomenda_atual.clicando.disconnect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.disconnect(encomenda_atual_mudou_estado)
	encomenda_atual = null
	mudou_encomenda.emit(null)
	checar_impedimento_ligacao()


var previewing_caixa_estoque = false
func preview_hover_estoque() -> void:
	if encomenda_atual != null and encomenda_atual is Pacote and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA:
		encomenda_atual.freeze = true
		encomenda_atual.reparent(estoque.area_preview_caixa)
		encomenda_atual.position = Vector3.ZERO
		previewing_caixa_estoque = true

func preview_unhover_estoque() -> void:
	if encomenda_atual != null and encomenda_atual is Pacote and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA and previewing_caixa_estoque:
		encomenda_atual.freeze = false
		encomenda_atual.reparent(pos_meio_mesa)
		encomenda_atual.position = Vector3.ZERO
		previewing_caixa_estoque = false

func clicou_estocar() -> void:
	if encomenda_atual != null and encomenda_atual is Pacote and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA and previewing_caixa_estoque:
		_mandar_caixa_para_estoque()

func _mandar_caixa_para_estoque() -> void:
	print("mandaaar")
	encomenda_atual.estado_entregue = Encomenda.EstadoEntregue.ENTREGUE
	encomenda_despachada.emit(encomenda_atual)
	
	encomenda_atual.clicando.disconnect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.disconnect(encomenda_atual_mudou_estado)
	
	mudou_encomenda.emit(null)
	
	encomenda_atual.freeze = false
	encomenda_atual = null
	checar_impedimento_ligacao()
	
	await Jogo.instance.decretos.apos_checar_corretude
	
	var review = Jogo.instance.decretos.ultimo_review
	if review != null and review.tipo == Singleton.TipoEncomenda.CAIXA and review.corretude:
		Jogo.instance.pontuar(2)


var previewing_guarda_carta = false
func preview_hover_cesto() -> void:
	if encomenda_atual != null and encomenda_atual is Carta and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA:
		cesto.preview_carta(encomenda_atual)
		previewing_guarda_carta = true

func preview_unhover_cesto() -> void:
	if encomenda_atual != null and encomenda_atual is Carta and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.PARADA and previewing_guarda_carta:
		encomenda_atual.reparent(pos_meio_mesa)
		encomenda_atual.position = Vector3.ZERO
		encomenda_atual.rotation = Vector3.ZERO
		previewing_guarda_carta = false

func _on_cesto_carta_clicado() -> void:
	if not cesto.ainda_cabe():
		return
		
	if not tem_encomenda_no_meio() or encomenda_atual.estado_atual != Encomenda.EstadoEncomenda.PARADA:
		return
	
	if encomenda_atual is not Carta:
		return
	
	encomenda_atual.estado_entregue = Encomenda.EstadoEntregue.ENTREGUE
	encomenda_despachada.emit(encomenda_atual)
	encomenda_atual.clicando.disconnect(encomenda_atual_selecionada)
	encomenda_atual.estado_mudado.disconnect(encomenda_atual_mudou_estado)
	cesto.adicionar_carta(encomenda_atual)
	encomenda_atual = null
	mudou_encomenda.emit(null)
	checar_impedimento_ligacao()
	
	await Jogo.instance.decretos.apos_checar_corretude
	

func tentar_abrir_caixa() -> void:
	if encomenda_atual != null and encomenda_atual.estado_atual == Encomenda.EstadoEncomenda.INSPECIONANDO and encomenda_atual is Pacote:
		encomenda_atual.abrir_pacote()

func checar_impedimento_ligacao() -> void:
	if Jogo.instance.telefone.tocando and encomenda_atual == null:
		Jogo.instance.impedir_por_chamada()
