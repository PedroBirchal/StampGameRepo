class_name ItemResource
extends Resource

enum TamanhoPacote { PEQUENO, MEDIO, GRANDE }

@export var offset_pos : Vector3
@export var offset_rot : Vector3
@export var mesh : PackedScene
@export var cabe_em : TamanhoPacote
@export var categorias : PackedStringArray


@export_group("Offset ao mostrar")
@export var offset_rot_mostrar : Vector3
@export var offset_pos_mostrar : Vector3
