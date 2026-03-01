extends Node3D

@onready var timer : Timer = $"RelogioTimer"
@onready var display_label : Label3D = $"Relogio_Digital/RelogioDisplay"
@onready var cor_display : Color = display_label.modulate
@export var cor_piscada : Color = Color.TRANSPARENT
@export var intervalo_da_piscada : float = 1
var minutos : int = 0
var segundos : int = 0
var visivel : bool = true
var timer_de_jogo : Timer

func _ready() -> void :
	timer.wait_time = intervalo_da_piscada
	if Jogo.instance:
		Jogo.instance.fim_de_jogo.connect(set_piscando)

func _process(_delta: float) -> void:
	update_timer()

func _on_relogio_timer_timeout() -> void:
	if visivel :
		display_label.modulate = cor_piscada
	else :
		display_label.modulate = cor_display
	visivel = !visivel

func set_timer(timer_jogo : Timer) -> void :
	timer_de_jogo = timer_jogo

func set_piscando() -> void:
	timer.start()

func update_timer() -> void :
	minutos = int(timer_de_jogo.time_left / 60)
	segundos = int(timer_de_jogo.time_left) % 60
	display_label.text = "%02d:%02d" % [minutos, segundos]
