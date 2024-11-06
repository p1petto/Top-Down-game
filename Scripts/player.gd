extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimationController = $Sprite2D
#@onready var combat_system: CombatSystem = $CombatSystem
@onready var health_system: HealthSystem = $HealthSystem
@onready var attak_collision: CollisionShape2D = $"Area2D/AttakCollision"
@onready var inventory: Inventory = $Inventory

const SPEED = 5000.0

@export var max_health: int
var enemies_group = null
var knockback_direction = null
var knockback_power = 100
var can_attack = true
enum State { ATTACK, DAMAGED, WALKING, DIED, IDLE }
var current_state : State = State.IDLE : set = set_state

func set_state(new_state: int) -> void:
	#var previous_state := current_state
	current_state = new_state
	if current_state == State.ATTACK:
		animated_sprite_2d.play_attack_animation()

func _ready() -> void:
	health_system.init(max_health)
	health_system.died.connect(on_player_dead)
	health_system.damage_taken.connect(on_player_damage)
	animated_sprite_2d.damage_animation_finished.connect(on_damage_animation_finished)
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	

	match current_state:
		
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)
			attak_collision.disabled = true
			animated_sprite_2d.play_idle_animation()
			if direction:
				current_state = State.WALKING
		
		State.WALKING:
			velocity = direction * SPEED * delta
			if !direction:
				current_state = State.IDLE
			animated_sprite_2d.play_movement_animation(velocity)
			

		State.ATTACK:
			if !can_attack:
				return
			can_attack = false
			animated_sprite_2d.play_attack_animation()
			attak_collision.disabled = false

			
		State.DIED:
			set_physics_process(false)
			set_process_input(false)
			animated_sprite_2d.play("died")	
		
			
		State.DAMAGED:
			can_attack = false
			attak_collision.disabled = true
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)
			animated_sprite_2d.play_damaged_animation()
			
			
	move_and_slide()
	
func on_player_dead():
	current_state = State.DIED
	
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.health_system.apply_damage(3)
		print("Enemy health: ", body.health_system.current_health)
		#print("Positions ", body.position, " ", position,  " ",body.position - position)
		knockback_direction = body.global_position - global_position
		knockback_direction *= knockback_power 
		#knockback_direction *= Vector2(1, 1)
		body.knockback(knockback_direction)
		
func _input(_event):
	if Input.is_action_just_pressed("left_hand_attack"):
		if current_state != State.DAMAGED and current_state != State.DIED:
			current_state = State.ATTACK
		
		
func on_player_damage():
	current_state = State.DAMAGED
	

func on_attack_animation_finished():
	attak_collision.disabled = true
	current_state = State.IDLE

func on_damage_animation_finished():
	current_state = State.IDLE



func _on_area_pick_up_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		inventory.add_item(area.inventory_item, area.stacks)
		area.queue_free()
