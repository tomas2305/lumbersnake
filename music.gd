extends Node

var musica_actual : AudioStreamPlayer
var esta_muted : bool = false

func _ready():
	musica_actual = AudioStreamPlayer.new()
	add_child(musica_actual)
	musica_actual.bus = "Music"
	musica_actual.stream_paused = false
	actualizar_volumen()

func reproducir_musica(stream: AudioStream):
	if musica_actual.stream != stream:
		musica_actual.stream = stream
		musica_actual.play()

func mutear():
	esta_muted = true
	actualizar_volumen()

func desmutear():
	esta_muted = false
	actualizar_volumen()

func toggle_mute():
	esta_muted = !esta_muted
	actualizar_volumen()

func actualizar_volumen():
	musica_actual.volume_db = -80 if esta_muted else 0
