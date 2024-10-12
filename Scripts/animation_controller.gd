extends AnimatedSprite2D

class_name AnimationController

@onready var attak_collision: CollisionShape2D = $"../Area2D/AttakCollision"

signal attack_animation_finished

const MOVEMENT_TO_IDLE = {
	"walk_top": "idle_top",
	"walk_down": "idle_down",
	"walk_horizontal": "idle_horizontal"
}

const DIRECTION_TO_ATTACK_ANIMATION = {
	"top": "attack_top",
	"down": "attack_down",
	"horizontal": "attack_horizontal"
}

const TO_DAMAGE = {
	"walk_top": "damaged_top",
	"walk_down": "damaged_down",
	"walk_horizontal": "damaged_horizontal",
	"idle_horizontal": "damaged_horizontal",
	"idle_top": "damaged_top",
	"idle_down": "damaged_down"
}

const COLLISION_ATTAK_POSITION = {
	"top": Vector2(0, -12),
	"down": Vector2(0, 0),
	"right": Vector2(8.5, -4),
	"left": Vector2(-8.5, -4)
}

var attack_direction = null

func play_movement_animation(velocity: Vector2):
	if velocity.x > 0:
		flip_h = false
		play("walk_horizontal")
	elif velocity.x < 0:
		flip_h = true
		play("walk_horizontal")
	
	elif velocity.y > 0:
		flip_h = false
		play("walk_down")
	elif velocity.y < 0:
		flip_h = false
		play("walk_top")

func play_idle_animation():
	if MOVEMENT_TO_IDLE.keys().has(animation):
		play(MOVEMENT_TO_IDLE[animation])
		
func play_attack_animation():
	var direction = animation.split("_")[1]
	attack_direction = direction
	play(DIRECTION_TO_ATTACK_ANIMATION[direction])
	if (str(direction) == "horizontal"):
		if flip_h == false:
			attak_collision.position = COLLISION_ATTAK_POSITION["right"]
		else:
			attak_collision.position = COLLISION_ATTAK_POSITION["left"]
	else:	
		attak_collision.position = COLLISION_ATTAK_POSITION[direction]
	
func play_damaged_animation():
	if TO_DAMAGE.keys().has(animation):
		play(TO_DAMAGE[animation])
	
func _on_animation_finished() -> void:
	
	if DIRECTION_TO_ATTACK_ANIMATION.values().has(animation):
		var animation_string = String(animation)
		var direction = DIRECTION_TO_ATTACK_ANIMATION.find_key(animation_string)
		
		play("idle_" + direction)
		attack_direction = null
		attack_animation_finished.emit()
