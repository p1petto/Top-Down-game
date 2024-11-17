extends ProgressBar

@onready var hunger_system: HungerSystem = %HungerSystem

func _ready() -> void:
	await get_tree().process_frame
	hunger_system.satiety_changed.connect(update)
	max_value = GameData.player_stats.max_satiety
	update()

func update() -> void:
	max_value = GameData.player_stats.max_satiety
	value = GameData.player_stats.current_satiety
