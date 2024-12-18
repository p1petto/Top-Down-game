extends CharacterBody2D

class_name Slime

@export var patrol_path: Array[Marker2D] = []
@export var speed: float = 100
@export var patrol_wait_time = 1.0
@export var max_health = 10
@export var chase_distance: float = 200.0

@export var dropped_resource: InventoryItem 
const PICKUP_ITEM_SCENE = preload("res://Scenes/pick_up_item.tscn")

@onready var animated_sprite_2d: AnimationControllerSlime = $AnimationPlayer
@onready var health_system_enemy: HealthSystemEnemy = $HealthSystem
@onready var collision_shape_2d:CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D



var current_patrol_target: int = 0
var wait_timer := 0.0
var last_animation = null

enum State { PATROL, DAMAGED, IDLE, CHASE }
var current_state : State = State.IDLE : 
	set(new_state):
		current_state = new_state
var acc = null

var player: Player

	
func _ready() -> void:
	health_system_enemy.init(max_health)
	health_system_enemy.died.connect(on_dead)
	if patrol_path.size() > 0:
		position = patrol_path[0].position
		current_state = State.PATROL
	acc = 0.05
	



func _physics_process(delta: float) -> void:
	
	match current_state:
		State.PATROL:
			move_along_path(delta)
		State.DAMAGED:
			animated_sprite_2d.play_damaged_animation()
			move_and_slide()
			velocity = velocity - velocity * acc 
			#print (velocity)
			#if abs(velocity - Vector2(0, 0)) <= Vector2(0.3, 0.3):
				#if patrol_path.size() > 0:
					#current_state = State.PATROL
				#else:
					#current_state = State.IDLE
				##print (velocity)
				
		State.IDLE:
			animated_sprite_2d.play_idle_animation()
		
		State.CHASE:
			chase_player()

func chase_player():
	print("CHASE")
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > chase_distance:
		if patrol_path.size() > 0:
			current_state = State.PATROL
		else:
			current_state = State.IDLE
	var direction = (player.global_position - global_position).normalized()
	animated_sprite_2d.play_movement_animation(direction)
	velocity = direction * speed
	move_and_slide()

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
	print ("knockback")
	velocity = dir.normalized() * speed
	current_state = State.DAMAGED

func on_dead():
	set_physics_process(false)
	collision_shape_2d.set_deferred("disabled", true)
	area_collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play("died")
	eject_item_into_the_ground() 



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		var animation = body.get_node("Sprite2D").animation
		if str(animation).contains("attack"):
			if $"../Player/Sprite2D".frame <= 1:
				return
		if current_state == State.DAMAGED:
			return
		body.health_system.apply_damage(3)
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "died":
		queue_free()
		pass
	if anim_name.contains("damaged"):
		current_state = State.CHASE
		#elif patrol_path.size() > 0:
			#current_state = State.PATROL
		#else:
			#current_state = State.IDLE
		
func eject_item_into_the_ground():
	if dropped_resource == null:
		return
	
	var item_to_eject_as_pickup = PICKUP_ITEM_SCENE.instantiate() as PickUpItem
	item_to_eject_as_pickup.inventory_item = dropped_resource
	item_to_eject_as_pickup.stacks = randi_range(1, 5)

	get_tree().root.call_deferred("add_child", item_to_eject_as_pickup)

	item_to_eject_as_pickup.call_deferred("disable_collision")  

	item_to_eject_as_pickup.global_position = global_position

	item_to_eject_as_pickup.call_deferred("enable_collision")


func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		current_state = State.CHASE 
		player = body
