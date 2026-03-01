class_name FadeController
extends Control

@export var rect: ColorRect
@export var cor_escurecer : Color
@export var tempo_escurecer := 0.2
@export var cor_aparecer : Color
@export var tempo_aparecer := 0.2

@export var tempo_manter := 0.3

signal terminou_escurecer
signal terminou_aparecer
signal terminou_transicao

func escurecer() -> void:
	rect.color = cor_aparecer
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "color", cor_escurecer, tempo_escurecer)
	await tween.finished
	print("escureceu! " + str(rect.color))
	terminou_escurecer.emit()

func aparecer() -> void:
	rect.color = cor_escurecer
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "color", cor_aparecer, tempo_aparecer)
	await tween.finished
	terminou_aparecer.emit()

func transicao() -> void:
	escurecer()
	await terminou_escurecer
	await get_tree().create_timer(tempo_manter).timeout
	aparecer()
	await terminou_aparecer
	terminou_transicao.emit()
