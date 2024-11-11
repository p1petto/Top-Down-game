extends AnimatedSprite2D

class_name AnimationController

@onready var attak_collision: CollisionShape2D = $"../Area2D/AttakCollision"
var item_eject_direction = Vector2.DOWN

signal attack_animation_finished
signal damage_animation_finished
signal mining_animation_finished

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

const DIRECTION_TO_MINING_ANIMATION = {
	"top": "mining_top",
	"down": "mining_down",
	"horizontal": "mining_horizontal"
}

const TO_DAMAGE = {
	"walk_top": "damaged_top",
	"walk_down": "damaged_down",
	"walk_horizontal": "damaged_horizontal",
	"idle_horizontal": "damaged_horizontal",
	"idle_top": "damaged_top",
	"idle_down": "damaged_down",
	"attack_horizontal": "damaged_horizontal",
	"attack_top": "damaged_top",
	"attack_down": "damaged_down",
}

const COLLISION_ATTAK_POSITION = {
	"top": Vector2(2, -24),
	"down": Vector2(3, 1.5),
	"right": Vector2(17, -12),
	"left": Vector2(-9, -12)
}

var attack_direction = null

func play_movement_animation(velocity: Vector2):
	if velocity.x > 0:
		flip_h = false
		item_eject_direction = Vector2.RIGHT
		play("walk_horizontal")
	elif velocity.x < 0:
		flip_h = true
		item_eject_direction = Vector2.LEFT
		play("walk_horizontal")
	
	elif velocity.y > 0:
		flip_h = false
		item_eject_direction = Vector2.DOWN
		play("walk_down")
	elif velocity.y < 0:
		flip_h = false
		item_eject_direction = Vector2.UP
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
		
func play_mining_animation():
	var direction = animation.split("_")[1]
	attack_direction = direction
	play(DIRECTION_TO_MINING_ANIMATION[direction])
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
		
	if DIRECTION_TO_MINING_ANIMATION.values().has(animation):
		var animation_string = String(animation)
		var direction = DIRECTION_TO_MINING_ANIMATION.find_key(animation_string)
		
		play("idle_" + direction)
		attack_direction = null
		mining_animation_finished.emit()
		
	if TO_DAMAGE.values().has(animation):
		var direction = animation.split("_")[1]
		play("idle_" + direction)
		damage_animation_finished.emit()
