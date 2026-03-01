class_name Carta
extends Encomenda


@export var valor : int = 1

@export var mesh_carta : MeshInstance3D
@export var area_carimbavel : Area3D

@export var pode_abrir := false
@export var carta_aberta := false

@export_group("Texto")
@export var textos : Array[Label3D]
var caracter_max : int = 1900

func _ready() -> void:
	super._ready() # Chama a função _ready da classe Encomenda
	recebe_valores(load("res://resources/cartas/carta_1.tres"))
	fechando.connect(fechar_carta)
	
	caracteristicas.append("carta")
	
	randomize()
	gerar_localidades()
	mudar_cor_da_carta(indo_para)
	#caracter_max = textos[0].text.length()

# Temporario
func gerar_localidades() -> void:
	var locais = Singleton.Cidades.values()
	locais.shuffle()
	vindo_de = locais[0]
	indo_para = locais[1]
	
	caracteristicas.append("vem_" + Singleton.sigla_cidade[vindo_de])
	caracteristicas.append("indo_" + Singleton.sigla_cidade[indo_para])

func mudar_cor_da_carta(valor : int) -> void:
	var material = mesh_carta.get_active_material(0)
	var novo_material = material.duplicate()
	novo_material.albedo_color = Singleton.cores[valor]
	mesh_carta.set_surface_override_material(0, novo_material)

func recebe_valores(carta: CartaResource) -> void:
	#texto_meio.text = carta.conteudo
	indo_para = carta.indo_para
	mudar_cor_da_carta(indo_para)

func abrir_carta() -> void:
	if not pode_abrir or estado_atual != EstadoEncomenda.INSPECIONANDO:
		return
	carta_aberta = true
	set_estado(EstadoEncomenda.ABERTA)
	AudioManager.open_letter.play()

func fechar_carta() -> void:
	carta_aberta = false
	AudioManager.close_letter.play()
	

func _on_area_clicavel_para_abrir_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			abrir_carta()
