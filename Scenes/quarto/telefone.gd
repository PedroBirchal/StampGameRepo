class_name Telefone
extends Jogavel

enum Estado { PARADO, TOCANDO, EM_CHAMADA}

@export var camera : Camera3D

@export var estado := Estado.PARADO
@export var textos : Array[String]

func _ready() -> void:
	tocar_telefone()

func tocar_telefone() -> void:
	estado = Estado.TOCANDO

func atender_telefone() -> void:
	estado = Estado.EM_CHAMADA
	Jogo.instance.dialogo.display_texts(textos)
	await Jogo.instance.dialogo.finished_multiple_texts
	sair()
	estado = Estado.PARADO


func jogar() -> void:
	super()
	atender_telefone()
	camera.make_current()

func sair() -> void:
	super()
	camera.clear_current()
