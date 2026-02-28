class_name Dialogo
extends MarginContainer

var texts : Array[String]
var texts_index := -1

@onready var label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer

const MAX_WIDTH =500

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

var writting := false

signal finished_displaying()
signal finished_multiple_texts()
signal pressed_to_next()


func display_texts(texts_to_display: Array[String]) -> void:
	texts = texts_to_display
	texts_index = 0
	
	pressed_to_next.connect(_next_text_to_display)
	display_text(texts[0])

func _next_text_to_display() -> void:
	texts_index += 1
	if texts_index >= len(texts):
		texts = []
		texts_index = -1
		pressed_to_next.disconnect(_next_text_to_display)
		finished_multiple_texts.emit()
		return
	
	display_text(texts[texts_index])


func display_text(text_to_display: String):
	show()
	text = text_to_display
	label.text = ""
	
	letter_index = 0
	writting = true
	
	timer.timeout.connect(_display_letter)
	_display_letter()
	
func _display_letter():
	if not writting:
		return
	
	label.text += text[letter_index]
	letter_index += 1
	
	if letter_index >= text.length():
		finished_displaying.emit()
		writting = false
		timer.timeout.disconnect(_display_letter)
		return
		
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)


func _on_letter_display_timer_timeout() -> void:
	_display_letter()


func _on_texture_button_pressed() -> void:
	pressed_to_next.emit()
	
	if texts_index == -1:
		hide()
