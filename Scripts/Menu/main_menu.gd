extends Node2D

@export var creditsTela : Panel
@export var opcoesTela : Panel
@export var tutorialTela : Panel
@export var buttonManager : Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/quarto/quarto.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	buttonManager.visible = false
	creditsTela.visible = true


func _on_texture_button_pressed() -> void:
	creditsTela.visible = false
	opcoesTela.visible = false
	tutorialTela.visible = false
	buttonManager.visible = true


func _on_options_pressed() -> void:
	opcoesTela.visible = true
	buttonManager.visible = false
	


func _on_tutorial_pressed() -> void:
	tutorialTela.visible = true
	buttonManager.visible = false
	
