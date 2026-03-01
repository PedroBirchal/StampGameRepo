class_name Telefone
extends Jogavel

enum Estado { PARADO, TOCANDO, EM_CHAMADA}

@export var camera : Camera3D

@export var estado := Estado.PARADO
@export var textos : Array[String]

signal telefone_tocando
signal telefone_atendido
signal chamada_encerrada

func tocar_telefone(falas: Array[String]) -> void:
	textos = falas
	estado = Estado.TOCANDO
	AudioManager.telephone.play()
	telefone_tocando.emit()

func atender_telefone() -> void:
	if textos.is_empty():
		Jogo.instance.dialogo.display_texts(["Não há ninguém na linha."])
		await Jogo.instance.dialogo.finished_multiple_texts
		sair()
	else:
		estado = Estado.EM_CHAMADA
		Jogo.instance.dialogo.display_texts(textos)
		telefone_atendido.emit()
		AudioManager.telephone.stop()
		AudioManager.gibberish.play()
		await Jogo.instance.dialogo.finished_multiple_texts
		textos = []
		sair()
		estado = Estado.PARADO
		chamada_encerrada.emit()
		AudioManager.gibberish.stop()


func jogar() -> void:
	super()
	atender_telefone()
	camera.make_current()

func sair() -> void:
	super()
	camera.clear_current()
