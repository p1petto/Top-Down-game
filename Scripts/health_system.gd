# health_system.gd
extends Node
class_name HealthSystem

signal health_changed
signal damage_taken
signal died

var current_health: float:
	set(value):
		var new_health = clamp(value, 0, GameData.player_stats.max_health)
		current_health = new_health
		GameData.player_stats.current_health = new_health
		health_changed.emit()
	get:
		return current_health

func init(max_health: float) -> void:
	print("GameData.player_stats.max_health ", GameData.player_stats.max_health)
	GameData.player_stats.max_health = max_health
	current_health = GameData.player_stats.current_health
	health_changed.emit()  
	

func apply_damage(damage: float) -> void:
	current_health -= damage  
	damage_taken.emit()
	print("Player health: ", current_health)
	if current_health <= 0:
		died.emit()
