class_name Pacote
extends Encomenda

@export var animator : AnimationPlayer
@export var item_holder : Node3D
@export var conteudo_holder : Node3D
var item : Node3D
var item_res: ItemResource
var com_defeito := false

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

@export var selo_scene: PackedScene
@export var texturas_cidades: Dictionary[String, Texture2D] = {}
@export var markersG: Array[Node3D]
@export var markersM: Array[Node3D]
@export var markersP: Array[Node3D]

var tamanho_pacote:
	get:
		return null if item_res == null else item_res.cabe_em


func _ready() -> void:
	super._ready() # Chama a função _ready da classe Encomenda
	fechando.connect(fechar_pacote)
	
	caracteristicas.append("item")

func gerar_localidades() -> void:
	var locais = Singleton.Cidades.values()
	locais.shuffle()
	vindo_de = locais[0]
	indo_para = locais[1]
	
	
	caracteristicas.append("vem_" + Singleton.sigla_cidade[vindo_de])
	caracteristicas.append("indo_" + Singleton.sigla_cidade[indo_para])
	

func setar_pacote(item_resource: ItemResource, defeituoso: bool) -> void:
	var tamanho: ItemResource.TamanhoPacote = item_resource.cabe_em
	item = (item_resource.mesh if not defeituoso else item_resource.mesh_defeito).instantiate()
	item_res = item_resource
	com_defeito = defeituoso
	
	gerar_localidades()
	
	caracteristicas.append_array(item_res.categorias)
	caracteristicas.append("qualidade_boa" if not com_defeito else "qualidade_ruim")
	
	if item_holder.get_parent() != conteudo_holder:
		item_holder.reparent(conteudo_holder)
	
	item_holder.add_child(item)
	item_holder.position = Vector3.ZERO
	
	item.position = item_resource.offset_pos
	item.rotation = item_resource.offset_rot
	
	#print(caracteristicas)
	
	setar_tamanho(tamanho)
	instanciar_selos()

func setar_tamanho(tamanho: ItemResource.TamanhoPacote) -> void:
	if tamanho == ItemResource.TamanhoPacote.PEQUENO:
		animator = pacote_pequeno.get_node("AnimationPlayer")
		pacote_pequeno.show()
		pacote_medio.queue_free()
		colisor_medio.queue_free()
		pacote_grande.queue_free()
		colisor_grande.queue_free()
		rotacionavel.rot_x_y = false
		rotacionavel.rot_x_z = true
		rotacionavel.offset_rot_deg *= -1
	elif tamanho == ItemResource.TamanhoPacote.MEDIO:
		pacote_medio.show()
		pacote_pequeno.queue_free()
		colisor_pequeno.queue_free()
		animator = pacote_medio.get_node("AnimationPlayer")
		pacote_grande.queue_free()
		colisor_grande.queue_free()
	else:
		pacote_grande.show()
		pacote_pequeno.queue_free()
		colisor_pequeno.queue_free()
		pacote_medio.queue_free()
		colisor_medio.queue_free()
		animator = pacote_grande.get_node("AnimationPlayer")

func instanciar_selos() -> void:
	var pacote_ativo: Node3D = null
	
	var remetente
	var destinatario
	
	if item_res.cabe_em == ItemResource.TamanhoPacote.PEQUENO:
		markersP.shuffle()
		remetente = markersP[0]
		destinatario = markersP[1]
	elif item_res.cabe_em == ItemResource.TamanhoPacote.MEDIO: 
		markersM.shuffle()
		remetente = markersM[0]
		destinatario = markersM[1]
	elif item_res.cabe_em == ItemResource.TamanhoPacote.GRANDE: 
		markersG.shuffle()
		remetente = markersG[0]
		destinatario = markersG[1]
	
	gerar_um_selo(remetente, "Remetente", vindo_de)
	gerar_um_selo(destinatario, "Destinatário", indo_para)

func gerar_um_selo(alvo: Node3D, tipo: String, cidade_index: int) -> void:
	var novo_selo = selo_scene.instantiate()
	
	alvo.add_child(novo_selo)
	
	novo_selo.position = Vector3.ZERO
	novo_selo.rotation = Vector3.ZERO
	
	var sigla = Singleton.sigla_cidade[cidade_index]
	var tex = texturas_cidades.get(sigla)
	
	novo_selo.configurar(tipo, sigla, tex)
	novo_selo.scale = Vector3.ONE
	

func _on_area_clicavel_para_abrir_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			abrir_pacote()

func abrir_pacote() -> void:
	if not pode_abrir or estado_atual != EstadoEncomenda.INSPECIONANDO:
		return
	
	set_estado(EstadoEncomenda.ABERTA)

func fechar_pacote() -> void:
	pass
