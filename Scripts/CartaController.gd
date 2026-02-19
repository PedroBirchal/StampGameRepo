extends Node3D

@onready var rb : RigidBody3D = $Carta
@onready var cena_carta = preload("res://Scenes/Carta.tscn")
@export var force: float

func on_target_clicked(target_position) -> void:
	var direction = target_position - rb.global_position  
	print(direction)
	rb.apply_impulse(direction.normalized() * force)
	instantiate_new_carta()

func instantiate_new_carta() -> void:
	var nova_carta = cena_carta.instantiate()
	add_child(nova_carta)
	rb = nova_carta
