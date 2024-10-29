extends ProgressBar

@onready var player: Player = $"../../Player"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_system.health_changed.connect(update)
	max_value = player.max_health
	update()

func update():
	value = player.health_system.current_health * 100 / player.max_health
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
