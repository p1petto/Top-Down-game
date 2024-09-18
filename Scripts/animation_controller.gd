extends AnimatedSprite2D

class_name AnimationController

const MOVEMENT_TO_IDLE = {
	"walk_top": "idle_top",
	"walk_down": "idle_down",
	"walk_horizontal": "idle_horizontal"
}

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func play_movement_animation(velocity: Vector2):
	if velocity.x > 0:
		#item_eject_direction = Vector2.RIGHT
		flip_h = false
		play("walk_horizontal")
	elif velocity.x < 0:
		#item_eject_direction = Vector2.LEFT
		flip_h = true
		play("walk_horizontal")
	
	elif velocity.y > 0:
		#item_eject_direction = Vector2.DOWN
		flip_h = false
		play("walk_down")
	elif velocity.y < 0:
		#item_eject_direction = Vector2.UP
		flip_h = false
		play("walk_top")

func play_idle_animation():
	if MOVEMENT_TO_IDLE.keys().has(animation):
		play(MOVEMENT_TO_IDLE[animation])
