extends AnimationPlayer

class_name AnimationControllerEnemy

var item_eject_direction = Vector2.DOWN

const MOVEMENT_TO_IDLE = {
	"walk_top": "idle_top",
	"walk_down": "idle_down",
	"walk_horizontal": "idle_horizontal"
}

const TO_DAMAGE = {
	"walk_top": "damaged_top",
	"walk_down": "damaged_down",
	"walk_horizontal": "damaged_horizontal",
	"idle_horizontal": "damaged_horizontal",
	"idle_top": "damaged_top",
	"idle_down": "damaged_down"
}

var last_direction: Vector2 = Vector2.ZERO

func play_movement_animation(direction: Vector2):
	if direction.distance_squared_to(last_direction) < 0.01:
		return
		
	last_direction = direction
	
	if direction.x > 0 and absf(direction.x) > absf(direction.y):
		play("walk_horizontal")
		$"../Sprite2D".flip_h = false
		item_eject_direction = Vector2.RIGHT
		return
	elif direction.x < 0 and absf(direction.x) > absf(direction.y):	
		
		play("walk_horizontal")
		$"../Sprite2D".flip_h = true
		item_eject_direction = Vector2.LEFT
		return
	
	if direction.y > 0 and absf(direction.y) > absf(direction.x):
		play("walk_down")
		item_eject_direction = Vector2.DOWN
		return
	elif direction.y < 0 and absf(direction.y) > absf(direction.x):
		play("walk_top")
		item_eject_direction = Vector2.UP
		return
		

func play_idle_animation():
	var animation = current_animation
	if MOVEMENT_TO_IDLE.keys().has(animation):
		play(MOVEMENT_TO_IDLE[animation])
		
func play_damaged_animation():
	if TO_DAMAGE.keys().has(current_animation):
		play(TO_DAMAGE[current_animation])
