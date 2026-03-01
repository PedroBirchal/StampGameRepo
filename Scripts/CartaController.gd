extends Node3D

var carta_atual: Carta
var rb : RigidBody3D
@onready var cena_carta = preload("res://Scenes/Carta.tscn")
@export var force: float
var active = true

signal sem_cartas


func on_target_clicked(target_position) -> void:
	if not active : return
	if rb == null:
		return
	
	var direction = target_position - rb.global_position 
	rb.freeze = false
	rb.apply_impulse(direction.normalized() * force)
	carta_atual = null
	rb = null
	instantiate_new_carta()

func instantiate_new_carta() -> void:
	carta_atual = Jogo.instance.jogo_carimbo.cesto.remover_ultima_carta()
	if carta_atual != null:
		if carta_atual.get_parent() != null:
			carta_atual.reparent(self)
		else:
			add_child(carta_atual)
			
		carta_atual.position = Vector3.ZERO
		carta_atual.rotation = Vector3.ZERO
		rb = carta_atual
		rb.freeze = true
		rb.sleeping = false
	else:
		sem_cartas.emit()

func retornar_carta() -> void:
	if carta_atual != null:
		Jogo.instance.jogo_carimbo.cesto.adicionar_carta(carta_atual)
		carta_atual = null
		rb = null
	
