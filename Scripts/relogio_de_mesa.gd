extends Node3D

@onready var timer : Timer = $"RelogioTimer"
@onready var display_label : Label3D = $"Relogio_Digital/RelogioDisplay"
@onready var cor_display : Color = display_label.modulate
@export var intervalo_da_piscada : float = 1
var visivel : bool = true

func _ready() -> void :
	timer.wait_time = intervalo_da_piscada
	timer.start()

func _on_relogio_timer_timeout() -> void:
	if visivel :
		display_label.modulate = Color(0, 0, 0, 0)
	else :
		display_label.modulate = cor_display
	visivel = !visivel
