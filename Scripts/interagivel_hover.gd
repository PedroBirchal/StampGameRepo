class_name InteragivelHover
extends CollisionObject3D

signal ta_em_cima
signal saiu_de_cima

func call_em_cima() -> void:
	ta_em_cima.emit()

func call_fora_cima() -> void:
	saiu_de_cima.emit()
