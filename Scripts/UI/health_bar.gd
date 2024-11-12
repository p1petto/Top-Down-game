extends ProgressBar

@onready var player: Player = $"../"
@onready var health_system: HealthSystem = $"../HealthSystem"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_system.health_changed.connect(update)
	value = player.max_health
	update()

func update():
	value =health_system.current_health * 100 / player.max_health
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
