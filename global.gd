extends Node

var arboles_destuidos : int = 0
var arboles_a_destruir : int = 0
var won : bool = false
var first_run = true

func _process(_delta: float) -> void:
	if arboles_destuidos == arboles_a_destruir:
		won = true


func reset():
	arboles_destuidos = 0
	won = false
