class_name Pacote
extends Encomenda

@export var animator : AnimationPlayer
@export var item_holder : Node3D
@export var conteudo_holder : Node3D
var item : Node3D
var item_res: ItemResource

@export var pode_abrir := false
@export var pacote_aberto := false

@export_group("Pacote")
@export var pacote_pequeno : Node3D
@export var pacote_medio : Node3D
@export var pacote_grande : Node3D

@export_group("Colisores")
@export var colisor_pequeno : CollisionShape3D
@export var colisor_medio : CollisionShape3D
@export var colisor_grande : CollisionShape3D

@export_group("Trajetoria")
	
	
@export var item_pra_cima_p : Node3D
@export var item_pra_cima_m : Node3D
@export var item_pra_cima_g : Node3D
@export var item_pra_cara : Node3D

var timer_atual
var tween_atual: Tween
var tween_atual_2: Tween


var tamanho_pacote:
	get:
		return null if item_res == null else item_res.cabe_em

var item_pra_cima :
	get:
		match tamanho_pacote:
			ItemResource.TamanhoPacote.PEQUENO:
				return item_pra_cima_p
			ItemResource.TamanhoPacote.MEDIO:
				return item_pra_cima_m
			ItemResource.TamanhoPacote.GRANDE:
				return item_pra_cima_g


func _ready() -> void:
	super._ready() # Chama a função _ready da classe Encomenda
	fechando.connect(fechar_pacote)
	

func setar_pacote(item_resource: ItemResource) -> void:
	var tamanho: ItemResource.TamanhoPacote = item_resource.cabe_em
	item = item_resource.mesh.instantiate()
	item_res = item_resource
	
	item_holder.reparent(conteudo_holder)
	item_holder.add_child(item)
	item_holder.position = Vector3.ZERO
	
	item.position = item_resource.offset_pos
	item.rotation = item_resource.offset_rot
	
	setar_tamanho(tamanho)

func setar_tamanho(tamanho: ItemResource.TamanhoPacote) -> void:
	if tamanho == ItemResource.TamanhoPacote.PEQUENO:
		animator = pacote_pequeno.get_node("AnimationPlayer")
		pacote_medio.queue_free()
		colisor_medio.queue_free()
		pacote_grande.queue_free()
		colisor_grande.queue_free()
	elif tamanho == ItemResource.TamanhoPacote.MEDIO:
		pacote_pequeno.queue_free()
		colisor_pequeno.queue_free()
		animator = pacote_medio.get_node("AnimationPlayer")
		pacote_grande.queue_free()
		colisor_grande.queue_free()
	else:
		pacote_pequeno.queue_free()
		colisor_pequeno.queue_free()
		pacote_medio.queue_free()
		colisor_medio.queue_free()
		animator = pacote_grande.get_node("AnimationPlayer")


func _on_area_clicavel_para_abrir_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			abrir_pacote()

func abrir_pacote() -> void:
	if not pode_abrir or estado_atual != EstadoEncomenda.INSPECIONANDO:
		return
	
	parar_tweens_rolando()
	
	pacote_aberto = true
	set_estado(EstadoEncomenda.ABERTA)
	
	timer_atual = get_tree().create_timer(0.75)
	timer_atual.timeout.connect(_abrir_pacote_tween)

func _abrir_pacote_tween() -> void:
	item_holder.reparent(item_pra_cima)
	tween_atual = get_tree().create_tween()
	tween_atual.tween_property(item_holder, "position", Vector3.ZERO, 1.0)
	tween_atual.finished.connect(func():
		tween_atual = null
		item_holder.reparent(item_pra_cara)
		tween_atual_2 = get_tree().create_tween()
		tween_atual_2.tween_property(item_holder, "position", Vector3.ZERO, 1.0)
		tween_atual_2.finished.connect(func():
			tween_atual_2 = null
		)
	)

func fechar_pacote() -> void:
	parar_tweens_rolando()
	
	item_holder.reparent(item_pra_cima)
	tween_atual = get_tree().create_tween()
	tween_atual.tween_property(item_holder, "position", Vector3.ZERO, 0.4)
	
	tween_atual.finished.connect(func():
		tween_atual = null
		item_holder.reparent(conteudo_holder)
		tween_atual_2 = get_tree().create_tween()
		tween_atual_2.tween_property(item_holder, "position", Vector3.ZERO, 0.4)
		tween_atual_2.finished.connect(func(): 
			pacote_aberto = false
			tween_atual_2 = null
		)
	)

func parar_tweens_rolando() -> void:
	if timer_atual != null:
		timer_atual.timeout.disconnect(_abrir_pacote_tween)
		timer_atual = null
	if tween_atual != null:
		tween_atual.stop()
		tween_atual = null
	if tween_atual_2 != null:
		tween_atual_2.stop()
		tween_atual_2 = null
