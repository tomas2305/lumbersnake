extends Control

@onready var input_button_scene = preload("res://menus/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
		"up" : "Mover Arriba",
		"left": "Mover Izquierda",
		"down": "Mover Abajo",
		"right": "Mover Derecha",
		"hit": "Talar"
		}
		

func _ready() -> void:
	_load_input_bindings()
	_create_action_list()




func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text= "Press key to bind..."

func _input(event):
	if is_remapping:
		if (event is InputEventKey || (event is InputEventMouseButton && event.pressed)):
			if event is InputEventMouseButton && event.double_click:
				event.doble_click = false
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_save_input_bindings()
			_update_action_list(remapping_button, event)
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()
				

func _update_action_list(button,event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
		


func _on_reset_button_pressed() -> void:
	_create_action_list()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/menu.tscn") # Replace with function body.
	
	
func _save_input_bindings():
	var config = ConfigFile.new()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var ev = events[0]
			if ev is InputEventKey and ev.keycode > 0:
				config.set_value("input", action, ev)
	config.save("user://input.cfg")

func _load_input_bindings():
	var config = ConfigFile.new()
	if config.load("user://input.cfg") == OK:
		for action in config.get_section_keys("input"):
			var event = config.get_value("input", action)
			if event and event is InputEventKey and event.keycode > 0:
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
