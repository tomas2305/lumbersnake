extends Node

var arboles_destuidos : int = 0
var arboles_a_destruir : int = 0
var won : bool = false
var first_run = true
var curse_duration_default = 40
var curse_duration : float = curse_duration_default

func _process(_delta: float) -> void:
	if arboles_destuidos == arboles_a_destruir:
		won = true


func reset():
	arboles_destuidos = 0
	won = false
	curse_duration = curse_duration_default
