## Resource que faz parte do DecretoResource, não utilizar sozinho.
class_name DecretoInfo
extends Resource

enum Limitacao { DEVE_TER, NAO_PODE_TER, DEVE_TER_DUAS, PROIBICAO_DE_ENCOMENDA, NEGAR_DECRETO }

@export var requer_caracteristicas : PackedStringArray
@export var carimbo : String
@export var limite : Limitacao
@export var sobrepoe_decretos: Array[DecretoResource]
