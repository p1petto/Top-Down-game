extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimationController = $Sprite2D
#@onready var combat_system: CombatSystem = $CombatSystem
@onready var health_system: HealthSystem = $HealthSystem
@onready var attak_collision: CollisionShape2D = $"Area2D/AttakCollision"

const SPEED = 5000.0

@export var health = 100
var died = false
var enemies_group = null
var knockback_direction = null
var knockback_power = 100
var can_attack = true
enum State { ATTACK, DAMAGED, WALKING, DIED, IDLE }
var current_state = State.IDLE


func _ready() -> void:
	health_system.init(health)
	health_system.died.connect(on_player_dead)
	#health_system.damage_taken.connect(on_player_damage)
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		current_state = State.WALKING

	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)
			animated_sprite_2d.play_idle_animation()
			
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
			current_state = State.IDLE
			
	print(current_state)
	move_and_slide()
	
func on_player_dead():
	set_physics_process(false)
	set_process_input(false)
	if !died:
		animated_sprite_2d.play("died")
		died = true
	
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
		current_state = State.ATTACK
		
		
#func on_player_damage():
	#animated_sprite_2d.play_damaged_animation()

func on_attack_animation_finished():
	can_attack = true
	attak_collision.disabled = true
	#current_state = State.IDLE
