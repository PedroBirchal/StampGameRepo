class_name ItemResource
extends Resource

enum TamanhoPacote { PEQUENO, MEDIO, GRANDE }

@export var offset_pos : Vector3
@export var offset_rot : Vector3
@export var mesh : PackedScene
@export var cabe_em : TamanhoPacote
@export var categorias : PackedStringArray
