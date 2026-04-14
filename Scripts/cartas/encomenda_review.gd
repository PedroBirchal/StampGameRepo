class_name EncomendaReview
extends Resource

@export var tipo : Singleton.TipoEncomenda
@export var vindo_de : Singleton.Cidades
@export var indo_para : Singleton.Cidades
@export var caracteristicas : PackedStringArray
@export var carimbos: Array[String]
@export var criterios : Dictionary[DecretoResource, bool]
@export var corretude : bool

func copiar_base(encomenda: Encomenda) -> void:
	tipo = Singleton.TipoEncomenda.CARTA if encomenda is Carta else Singleton.TipoEncomenda.CAIXA
	vindo_de = encomenda.vindo_de
	indo_para = encomenda.indo_para
	caracteristicas = encomenda.caracteristicas.duplicate()
	carimbos = encomenda.carimbos.duplicate()

func adicionar_criterio(decreto_res: DecretoResource, corretude: bool) -> void:
	criterios[decreto_res] = corretude

func checar_criterio(decreto_res: DecretoResource) -> bool:
	return criterios[decreto_res] if criterios.has(decreto_res) else false

func print_review() -> void:
	print("-------------------------")
	print("Review de Encomenda")
	print("Tipo: ", Singleton.TipoEncomenda.find_key(tipo))
	print("Vindo de: ", Singleton.Cidades.find_key(vindo_de))
	print("Indo para: ", Singleton.Cidades.find_key(indo_para))
	print("Carimbos: ", ", ".join(carimbos))
	print("Caracteristicas: ")
	for caracteristica in caracteristicas:
		print("	>", caracteristica)
	print("Criterios: ")
	for chave in criterios.keys():
		print("	>", chave.informativo,": ", "De acordo" if criterios[chave] else "Errado")
	print("")
	print("Veredito: ", "Correto" if corretude else "Errado")
	print("-------------------------")
