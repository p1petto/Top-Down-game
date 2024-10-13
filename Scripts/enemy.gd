extends CharacterBody2D

class_name Enemy

@export var patrol_path: Array[Marker2D] = []
@export var speed: float = 100
@export var patrol_wait_time = 1.0
@export var health = 10

@onready var animated_sprite_2d: AnimationControllerEnemy = $AnimationPlayer
@onready var health_system: HealthSystem = $HealthSystem
@onready var collision_shape_2d:CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var current_patrol_target: int = 0
var wait_timer := 0.0
var last_animation = null

enum State { PATROL, DAMAGED }
var current_state = State.PATROL
var acc = null

	
func _ready() -> void:
	health_system.init(health)
	health_system.died.connect(on_dead)
	if patrol_path.size() > 0:
		position = patrol_path[0].position
	acc = 0.05
	



func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			if patrol_path.size() > 1:
				move_along_path(delta)
		State.DAMAGED:
			animated_sprite_2d.play_damaged_animation()
			move_and_slide()
			velocity = velocity - velocity * acc 
			#print (velocity)
			if abs(velocity - Vector2(0, 0)) <= Vector2(0.3, 0.3):
				current_state = State.PATROL
				#print (velocity)
		


func move_along_path(delta: float):
	var target_position = patrol_path[current_patrol_target].global_position
	var direction = (target_position - position).normalized()
	var distance_to_target = position.distance_to(target_position)
	
	if distance_to_target > speed * delta:
		animated_sprite_2d.play_movement_animation(direction)
		velocity = direction * speed 
		move_and_slide()
	else: 
		animated_sprite_2d.play_idle_animation()
		position = target_position
		wait_timer += delta
		if wait_timer >= patrol_wait_time:
			wait_timer = 0.0
			current_patrol_target = (current_patrol_target + 1) % patrol_path.size()

func knockback(dir):
	velocity = dir.normalized() * speed
	current_state = State.DAMAGED

func on_dead():
	set_physics_process(false)
	collision_shape_2d.set_deferred("disabled", true) 
	area_collision_shape_2d.set_deferred("disabled", true) 
	animated_sprite_2d.play("died")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		var animation = $"../Player/Sprite2D".animation
		if str(animation).contains("attack"):
			if $"../Player/Sprite2D".frame <= 1:
				return
		if current_state == State.DAMAGED:
			return
		$"../Player/HealthSystem".apply_damage(3)
		print("Player health: ", $"../Player/HealthSystem".current_health)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "died":
		queue_free()
		pass
