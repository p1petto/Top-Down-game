extends ProgressBar

@onready var health_system: HealthSystem = %HealthSystem

func _ready() -> void:
	await get_tree().process_frame
	health_system.health_changed.connect(update)
	max_value = GameData.player_stats.max_health
	update()

func update() -> void:
	# Убедимся что max_value всегда актуальное
	max_value = GameData.player_stats.max_health
	# Используем текущее здоровье напрямую из GameData
	value = GameData.player_stats.current_health
	print("health",value)
