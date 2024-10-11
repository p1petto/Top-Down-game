extends AnimationPlayer

class_name AnimationControllerEnemy

const MOVEMENT_TO_IDLE = {
	"walk_top": "idle_top",
	"walk_down": "idle_down",
	"walk_horizontal": "idle_horizontal"
}

var last_direction: Vector2 = Vector2.ZERO

func play_movement_animation(direction: Vector2):
	if direction.distance_squared_to(last_direction) < 0.01:
		return
		
	last_direction = direction
	
	if direction.x > 0 and absf(direction.x) > absf(direction.y) or direction.x < 0 and absf(direction.x) > absf(direction.y):
		play("walk_horizontal")
		return
	
	if direction.y > 0 and absf(direction.y) > absf(direction.x):
		play("walk_down")
		return
	elif direction.y < 0 and absf(direction.y) > absf(direction.x):
		play("walk_top")
		return
		

func play_idle_animation():
	var animation = current_animation
	if MOVEMENT_TO_IDLE.keys().has(animation):
		play(MOVEMENT_TO_IDLE[animation])
