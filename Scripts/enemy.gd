extends CharacterBody2D

class_name Enemy

@export var patrol_path: Array[Marker2D] = []
@export var speed: float = 100
@export var patrol_wait_time = 1.0

@onready var animated_sprite_2d: AnimationControllerEnemy = $AnimationPlayer

var current_patrol_target = 0
var wait_timer = 0.0

func _ready() -> void:
	if patrol_path.size() > 0:
		position = patrol_path[0].position

func _physics_process(delta: float) -> void:
	if patrol_path.size() > 1:
		move_along_path(delta)


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
