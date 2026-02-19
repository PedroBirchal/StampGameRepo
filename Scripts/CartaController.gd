extends Node3D

@onready var rb : RigidBody3D = $Carta
@export var force: float

func on_target_clicked(target_position) -> void:
	var direction = target_position - rb.global_position  
	print(direction)
	rb.apply_impulse(direction.normalized() * force)
