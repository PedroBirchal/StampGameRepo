extends Control

var timer : Timer
@onready var progress_bar : TextureProgressBar = $RelogioBG/TextureProgressBar
@onready var ponteiro = $RelogioBG/RelogioPonteiro

func _process(_delta: float) -> void:
	if timer :
		atualizar_relogio(timer.time_left)

func set_timer(game_timer : Timer) -> void :
	timer = game_timer
	progress_bar.max_value = timer.wait_time

func atualizar_relogio(progresso) -> void :
	progress_bar.value = progresso
	ponteiro.rotation = TAU  * (1 - progresso / progress_bar.max_value)
