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

var review_entregues: Array[EncomendaReview]
var entregues_nesse_decreto: Array[EncomendaReview]

@export var tempo_checagem_postit := 0.5

@export_group("Referências")
@export var jogo_carimbar: JogoCarimbar
@export var telefone: Telefone

@export_group("Para proximo decreto")
@export var quant_para_proximo := 5
@export var mins_para_proximo := 5
var timer_proximo_decreto


signal apos_checar_corretude

func _ready() -> void:
	timer_proximo_decreto = get_tree().create_timer(1)
	timer_proximo_decreto.timeout.connect(gerar_novo_decreto)
	
	jogo_carimbar.encomenda_despachada.connect(checar_corretude)


func gerar_novo_decreto() -> void:
	ultimo_decreto_idx += 1
	if ultimo_decreto_idx >= len(lista_decretos):
		ultimo_decreto_idx = len(lista_decretos)
		print("Acabou os decretos da lista de decretos!")
		return
	
	entregues_nesse_decreto.clear()
	timer_proximo_decreto.timeout.disconnect(gerar_novo_decreto)
	
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
	
	timer_proximo_decreto = get_tree().create_timer(60 * mins_para_proximo)
	timer_proximo_decreto.timeout.connect(gerar_novo_decreto)


func checar_corretude(encomenda: Encomenda) -> void:
	var tween = get_tree().create_tween()
	
	var review = EncomendaReview.new()
	review.copiar_base(encomenda)
	
	var certo = true
	for decreto in decretos:
		var valido = decreto.resource.checar_encomenda_valida(encomenda)
		review.adicionar_criterio(decreto.resource, valido)
		
		decreto.postit.piscar_estado(valido)
		certo = certo and valido
		await get_tree().create_timer(tempo_checagem_postit).timeout
	
	review.corretude = certo
	review.print_review()
	
	print("A encomenda estava: " + ("correta" if certo else "errada"))
	if not certo : entregas_incorretas += 1
	
	review_entregues.append(review)
	entregues_nesse_decreto.append(review)
	if len(entregues_nesse_decreto) >= quant_para_proximo:
		gerar_novo_decreto()
	
	apos_checar_corretude.emit()
