extends Node

class_name HungerSystem

@onready var timer: Timer = $Timer

signal hunger_die
signal satiety_changed

var current_satiety: float:
	set(value):
		var new_satiety = clamp(value, 0, GameData.player_stats.max_satiety)
		current_satiety = new_satiety
		GameData.player_stats.current_satiety = new_satiety
		satiety_changed.emit()
	get:
		return current_satiety


func init(max_satiety: float) -> void:
	print("GameData.player_stats.max_satiety ", GameData.player_stats.max_satiety)
	GameData.player_stats.max_satiety = max_satiety
	current_satiety = GameData.player_stats.current_satiety
	satiety_changed.emit()  
	

func _on_timer_timeout() -> void:
	current_satiety -= 1
	# NOTE: ????
	# GameData.player_stats.current_satiety = current_satiety
	# satiety_changed.emit()
	if current_satiety == 0:
		hunger_die.emit()

func eat(value: int) -> void:
	current_satiety += value
