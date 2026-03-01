class_name DecretosController
extends Node




@export var lista_decretos : Array[DecretoResource]
var ultimo_decreto_idx = -1

class Decreto:
	var resource: DecretoResource
	var postit: PostIt
var decretos: Array[Decreto]
var decreto_a_ser_incluido: Decreto
var entregas_incorretas = 0

@export var tempo_checagem_postit := 0.5

@export_group("Referências")
@export var jogo_carimbar: JogoCarimbar
@export var telefone: Telefone

signal apos_checar_corretude

func _ready() -> void:
	var t = get_tree().create_timer(1)
	t.timeout.connect(gerar_novo_decreto)
	
	jogo_carimbar.encomenda_despachada.connect(checar_corretude)


func gerar_novo_decreto() -> void:
	ultimo_decreto_idx += 1
	if ultimo_decreto_idx >= len(lista_decretos):
		ultimo_decreto_idx = len(lista_decretos)
		print("Acabou os decretos da lista de decretos!")
		return
	
	var decreto = Decreto.new()
	decreto.resource = lista_decretos[ultimo_decreto_idx]
	
	if decreto.resource.tem_postit:
		decreto.postit = jogo_carimbar.gerar_post_it(decreto.resource)
		decreto.postit.hide()
	
	decreto_a_ser_incluido = decreto
	criar_ligacao(decreto_a_ser_incluido)

func criar_ligacao(decreto: Decreto) -> void:
	telefone.tocar_telefone(["Um novo decreto acaba de ser anunciado!", "\"" + decreto.resource.informativo +"\""])
	await telefone.chamada_encerrada
	
	if decreto_a_ser_incluido.postit != null:
		decreto_a_ser_incluido.postit.show()
	
	decretos.append(decreto_a_ser_incluido)
	decreto_a_ser_incluido = null
	
	var t = get_tree().create_timer(30)
	t.timeout.connect(gerar_novo_decreto)


func checar_corretude(encomenda: Encomenda) -> void:
	var tween = get_tree().create_tween()
	
	var certo = true
	for decreto in decretos:
		var valido = decreto.resource.checar_encomenda_valida(encomenda)
		decreto.postit.piscar_estado(valido)
		certo = certo and valido
		await get_tree().create_timer(tempo_checagem_postit).timeout
	
	print("A encomenda estava: " + ("correta" if certo else "errada"))
	if not certo : entregas_incorretas += 1
	
	apos_checar_corretude.emit()
