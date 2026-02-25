class_name Pacote
extends Encomenda

@export var animator : AnimationPlayer
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
@export var item_pra_cima : Node3D
@export var item_pra_cara : Node3D


func _ready() -> void:
	super._ready() # Chama a função _ready da classe Encomenda
	
	fechando.connect(fechar_pacote)
	

func setar_pacote(item_resource: ItemResource) -> void:
	var tamanho: ItemResource.TamanhoPacote = item_resource.cabe_em
	item = item_resource.mesh.instantiate()
	item_res = item_resource
	
	conteudo_holder.add_child(item)
	item.position = item_resource.offset_pos
	item.rotation = item_resource.offset_rot
	
	setar_tamanho(tamanho)

func setar_tamanho(tamanho: ItemResource.TamanhoPacote) -> void:
	if tamanho == ItemResource.TamanhoPacote.PEQUENO:
		#animator = pacote_pequeno.get_node("AnimationPlayer")
		pacote_medio.queue_free()
		colisor_medio.queue_free()
		pacote_grande.queue_free()
		colisor_grande.queue_free()
	elif tamanho == ItemResource.TamanhoPacote.MEDIO:
		pacote_pequeno.queue_free()
		colisor_pequeno.queue_free()
		#animator = pacote_medio.get_node("AnimationPlayer")
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
	pacote_aberto = true
	set_estado(EstadoEncomenda.ABERTA)
	
	var timer = get_tree().create_timer(0.75)
	timer.timeout.connect(func():
		item.reparent(item_pra_cima)
		
		var tween = get_tree().create_tween()
		tween.tween_property(item, "position", Vector3.ZERO, 1.0)
		tween.finished.connect(func():
			item.reparent(item_pra_cara)
			var tween2 = get_tree().create_tween()
			tween2.tween_property(item, "position", Vector3.ZERO, 1.0)
		)
	)
	
	
	

func fechar_pacote() -> void:
	item.reparent(item_pra_cima)
	var tween = get_tree().create_tween()
	tween.tween_property(item, "position", Vector3.ZERO, 0.2)
	tween.finished.connect(func():
		item.reparent(conteudo_holder)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(item, "position", item_res.offset_pos, 0.2)
		tween2.finished.connect(func(): pacote_aberto = false)
	)
