extends Node3D

@export_group("Spawn Encomendas")
@export var carta_prefab: PackedScene
var encomenda_atual: Node3D

@export_group("Sistema recebe e entrega")
@export var pos_meio_mesa: Node3D
@export var pos_receber_proximo: Node3D
var proxima_encomenda: Node3D


func _ready() -> void:
	proxima_encomenda = gerar_nova_encomenda()
	pos_receber_proximo.add_child(proxima_encomenda)


func tem_encomenda_no_meio() -> bool:
	return encomenda_atual != null

func tem_encomenda_para_pegar() -> bool:
	return proxima_encomenda != null


func _on_pegar_proximo(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mandar_encomenda_nova_ao_centro()

func mandar_encomenda_nova_ao_centro() -> void:
	print("mandarr")
	if not tem_encomenda_para_pegar() or tem_encomenda_no_meio():
		return
	
	proxima_encomenda.reparent(pos_meio_mesa)
	encomenda_atual = proxima_encomenda
	encomenda_atual.position = Vector3.ZERO
	
	proxima_encomenda = gerar_nova_encomenda()
	pos_receber_proximo.add_child(proxima_encomenda)
	print("cabou")



func _on_mandar_pra_la(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mandar_encomenda_atual_para_destino()
			
func mandar_encomenda_atual_para_destino() -> void:
	print("dess")
	if not tem_encomenda_no_meio():
		return
	
	encomenda_atual.queue_free()
	encomenda_atual = null



func gerar_nova_encomenda() -> Node3D:
	var encomenda = carta_prefab.instantiate()
	return encomenda
