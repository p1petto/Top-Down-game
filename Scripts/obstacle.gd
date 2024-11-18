extends Area2D

@onready var timer = $Timer

var on_obstacle = false
var player: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	on_obstacle = true
	if body.name == 'Player':
		player = body
		to_damage()
	timer.start()


func _on_body_exited(body: Node2D) -> void:
	on_obstacle = false

func to_damage():
		player.health_system.apply_damage(3)

func _on_timer_timeout() -> void:
	if on_obstacle:
		to_damage()
		timer.start()
