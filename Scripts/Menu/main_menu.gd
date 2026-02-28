extends Node2D

@export var creditsTela : Panel
@export var opcoesTela : Panel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/LetterGame.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	creditsTela.visible = true


func _on_texture_button_pressed() -> void:
	creditsTela.visible = false
	opcoesTela.visible = false


func _on_options_pressed() -> void:
	opcoesTela.visible = true
