extends Panel

var music_id
var sfx_id

func _ready():
	music_id = AudioServer.get_bus_index("Music")
	sfx_id = AudioServer.get_bus_index("SFX")

func _on_music_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(music_id, db)


func _on_sfx_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx_id, db)
