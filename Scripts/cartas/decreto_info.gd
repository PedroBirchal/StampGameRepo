## Resource que faz parte do DecretoResource, não utilizar sozinho.
class_name DecretoInfo
extends Resource

enum Limitacao { DEVE_TER, NAO_PODE_TER, DEVE_TER_DUAS, PROIBICAO_DE_ENCOMENDA, NEGAR_DECRETO }

@export var requer_caracteristicas : PackedStringArray
@export var carimbo : String
@export var limite : Limitacao
@export var sobrepoe_decretos: Array[DecretoResource]


func checa_se_engloba(encomenda: Encomenda) -> bool:
	if len(encomenda.caracteristicas) < len(requer_caracteristicas):
		return false
	
	for caracteristica_necessaria in requer_caracteristicas:
		if not encomenda.caracteristicas.has(caracteristica_necessaria):
			return false
	
	return true

func checar_encomenda_valida(encomenda: Encomenda) -> bool:
	if limite == Limitacao.NEGAR_DECRETO:
		return true
	
	if not checa_se_engloba(encomenda):
		return true
	
	match limite:
		Limitacao.DEVE_TER:
			return encomenda.carimbos.has(carimbo)
		Limitacao.NAO_PODE_TER:
			return not encomenda.carimbos.has(carimbo)
		Limitacao.DEVE_TER_DUAS:
			return encomenda.carimbos.count(carimbo) >= 2
		Limitacao.PROIBICAO_DE_ENCOMENDA:
			return encomenda.estado_entregue != Encomenda.EstadoEntregue.ENTREGUE
	
	return true
