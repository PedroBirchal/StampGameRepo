extends Node3D

func configurar(tipo: String, cidade_sigla: String, textura: Texture2D):
	$Direcao.text = tipo
	$Selo.texture = textura
	#rotation.y = randf_range(-0.2, 0.2)
