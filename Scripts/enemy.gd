extends CharacterBody2D

class_name Enemy

@export var patrol_path: Array[Marker2D] = []

@export var enemy_data: EnemyType

@export var dropped_resource: Array[InventoryItem] = [] 

const PICKUP_ITEM_SCENE = preload("res://Scenes/pick_up_item.tscn")

@onready var animated_sprite_2d: AnimationControllerEnemy = $AnimatedSprite2D
@onready var health_system_enemy: HealthSystemEnemy = $HealthSystem
@onready var collision_shape_2d:CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $AttackCollision/CollisionShape2D
@onready var agro_area: CollisionShape2D = $AggroArea/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

var speed
var patrol_wait_time
var max_health 
var chase_distance

var current_patrol_target: int = 0
var wait_timer := 0.0
var last_animation = null
var player_on_enemy = false

enum State { PATROL, DAMAGED, IDLE, CHASE, DIED }
var current_state : State = State.IDLE : 
	set(new_state):
		current_state = new_state
var acc = null

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var player: Player

@export var target: Node2D = null
	
func _ready() -> void:
	speed = enemy_data.speed
	patrol_wait_time = enemy_data.patrol_wait_time
	max_health = enemy_data.max_health
	chase_distance = enemy_data.chase_distance
	
	navigation_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)

	health_system_enemy.init(max_health)
	#health_system_enemy.died.connect(on_dead)
	if patrol_path.size() > 0:
		position = patrol_path[0].position
		current_state = State.PATROL
	acc = 0.05
	animated_sprite_2d.sprite_frames = enemy_data.sprite_frames
	collision_shape_2d.shape = enemy_data.collision_shape
	area_collision_shape_2d.shape = enemy_data.attack_collision
	agro_area.shape = enemy_data.agro_collision
	call_deferred("seeker_setup")
	
func seeker_setup():
	await get_tree().physics_frame
	if target:
		navigation_agent.target_position = target.global_position
		
	
func _physics_process(delta: float) -> void:
	match current_state:
		
		State.PATROL:
			move_along_path(delta)
		State.DAMAGED:
			animated_sprite_2d.play_damaged_animation()
			move_and_slide()
			velocity = velocity - velocity * acc 
				
		State.IDLE:
			animated_sprite_2d.play_idle_animation()
		
		State.CHASE:
			chase_player(delta)
			
		State.DIED:
			print("DIED")
			animated_sprite_2d.play("died")
			set_physics_process(false)

func chase_player(delta):
	if player.current_state != player.State.DIED:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > chase_distance:
			if patrol_path.size() > 0:
				current_state = State.PATROL
			else:
				current_state = State.IDLE
		if is_instance_valid(target):
			navigation_agent.target_position = target.global_position
		if navigation_agent.is_navigation_finished():
			return
		var direction = (player.global_position - global_position).normalized()
		animated_sprite_2d.play_movement_animation(direction)
		var current_self_position = global_position
		var next_path_pos:= navigation_agent.get_next_path_position()
		velocity = current_self_position.direction_to(next_path_pos) * speed * delta

		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(velocity)

		
	else: current_state = State.PATROL

func move_along_path(delta: float):
	var target_position = patrol_path[current_patrol_target].global_position
	var direction = (target_position - position).normalized()
	var distance_to_target = position.distance_to(target_position)
	
	if distance_to_target > 1:
		animated_sprite_2d.play_movement_animation(direction)
		velocity = direction * speed * delta
		move_and_slide()
	else: 
		animated_sprite_2d.play_idle_animation()
		position = target_position
		wait_timer += delta
		if wait_timer >= patrol_wait_time:
			wait_timer = 0.0
			current_patrol_target = (current_patrol_target + 1) % patrol_path.size()

func knockback(dir, delta):
	print ("knockback")
	velocity = dir.normalized() * speed * delta
	if health_system_enemy.current_health <= 0:
		on_dead()
	else:
		current_state = State.DAMAGED

func on_dead():
	current_state = State.DIED
	collision_shape_2d.set_deferred("disabled", true)
	area_collision_shape_2d.set_deferred("disabled", true)
	eject_item_into_the_ground() 		
	print("dead enemy")
		
func eject_item_into_the_ground():
	if dropped_resource.is_empty():
		return
	
	for item in dropped_resource:
		var item_to_eject_as_pickup = PICKUP_ITEM_SCENE.instantiate() as PickUpItem
		item_to_eject_as_pickup.inventory_item = item
   	#item_to_eject_as_pickup.stacks = randi_range(1, 5)
	
		get_tree().root.call_deferred("add_child", item_to_eject_as_pickup)
		item_to_eject_as_pickup.call_deferred("disable_collision")
		
		var random_offset = Vector2(
			randf_range(-20, 20),
			randf_range(-20, 20))
		item_to_eject_as_pickup.global_position = global_position + random_offset
		item_to_eject_as_pickup.call_deferred("enable_collision")


func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		current_state = State.CHASE 
		player = body


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.DIED:
		queue_free()
		pass
	elif current_state == State.DAMAGED:
		
		current_state = State.CHASE


func _on_attack_collision_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		var animation = body.get_node("Sprite2D").animation
		if str(animation).contains("attack"):
			var sprite_player = player.get_node("Sprite2D")
			if sprite_player.frame <= 1:
				return
		if current_state == State.DAMAGED:
			return
		player_on_enemy = true	
		to_attack()
		

func to_attack():
	player.health_system.apply_damage(3)
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if player_on_enemy:
		to_attack()


func _on_attack_collision_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_on_enemy = false	

func _on_navigation_agent_2d_velocity_computed(new_velocity):
	velocity = new_velocity

	move_and_slide()
