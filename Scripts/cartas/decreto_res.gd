class_name DecretoResource
extends Resource

@export_multiline var informativo : String
@export var decretacoes: Array[DecretoInfo]
@export var tem_postit := true

func checar_encomenda_valida(encomenda: Encomenda) -> bool:
	for decretacao in decretacoes:
		if not decretacao.checar_encomenda_valida(encomenda):
			return false
	return true
