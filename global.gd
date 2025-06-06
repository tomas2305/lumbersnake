extends Node

var arboles_destuidos : int = 0
var won : bool = false

func _process(delta: float) -> void:
	if arboles_destuidos == 5:
		won = true


func reset():
	arboles_destuidos = 0
	won = false
