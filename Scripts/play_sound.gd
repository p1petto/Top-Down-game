extends AudioStreamPlayer

class_name SoundPlayer

var damage_sound: AudioStream
var death_sound: AudioStream

func _ready() -> void:
	# Загружаем звуковые файлы
	damage_sound = load("res://Assets/music/sound/damage.wav")
	death_sound = load("res://Assets/music/sound/death.wav")

func _process(delta: float) -> void:
	pass

func play_damage_sound() -> void:
	stream = damage_sound
	play()

func play_death_sound() -> void:
	stream = death_sound
	play()
