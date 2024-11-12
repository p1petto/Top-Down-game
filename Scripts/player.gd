extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimationController = $Sprite2D
@onready var health_system: HealthSystem = $HealthSystem
@onready var attak_collision: CollisionShape2D = $"Area2D/AttakCollision"
@onready var inventory: Inventory = $Inventory
@onready var inventory_ui: InventoryUI = $InventroryUI

const SPEED = 5000.0

@export var max_health: int

#var equipped_tool = false
#@export_enum("Pickaxe", "Sword", "NoType") 
#var tool_type: String = "NoType"

@export var hand_weapon: InventoryItem

var enemies_group = null
var knockback_direction = null
var knockback_power = 100
enum State { ATTACK, DAMAGED, WALKING, DIED, IDLE, MINING }
var current_state : State = State.IDLE : set = set_state

#var equipped = false
#var power: int = 0


func set_state(new_state: int) -> void:
	current_state = new_state

func _ready() -> void:
	health_system.init(max_health)
	health_system.died.connect(on_player_dead)
	health_system.damage_taken.connect(on_player_damage)
	animated_sprite_2d.damage_animation_finished.connect(on_damage_animation_finished)
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)
	animated_sprite_2d.mining_animation_finished.connect(on_mining_animation_finished)
	health_system.current_health = max_health
	health_system.health_changed.emit()


func _physics_process(delta: float) -> void:
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#print(current_state)
	match current_state:
		
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)
			attak_collision.disabled = true
			animated_sprite_2d.play_idle_animation()
			
		State.WALKING:
			velocity = direction * SPEED * delta
			if !direction:
				current_state = State.IDLE
			animated_sprite_2d.play_movement_animation(velocity)
			

		State.ATTACK:
			set_physics_process(false)
			set_process_input(false)
			animated_sprite_2d.play_attack_animation()
			attak_collision.disabled = false
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)

		State.MINING:
			set_physics_process(false)
			set_process_input(false)
			animated_sprite_2d.play_mining_animation()
			attak_collision.disabled = false
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)
			
		State.DIED:
			set_physics_process(false)
			set_process_input(false)
			animated_sprite_2d.play("died")	
		
			
		State.DAMAGED:
			set_physics_process(false)
			set_process_input(false)
			attak_collision.disabled = true
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.y = move_toward(velocity.y, 0, SPEED * delta)
			animated_sprite_2d.play_damaged_animation()
			
			
	
	if direction:
		if current_state != State.DAMAGED :
			current_state = State.WALKING		
	move_and_slide()
	
func on_player_dead():
	current_state = State.DIED
	
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.health_system.apply_damage(hand_weapon.damage)
		print("Enemy health: ", body.health_system.current_health)
		knockback_direction = body.global_position - global_position
		knockback_direction *= knockback_power 
		body.knockback(knockback_direction)
	elif body.is_in_group("UsefullResources") and hand_weapon.tool_type == "Pickaxe":
		body.apply_damage(hand_weapon.damage)
		
func _input(_event):
	if Input.is_action_just_pressed("left_hand_attack"):
		if hand_weapon != null:
			if hand_weapon.tool_type == "Sword":
				if current_state != State.DAMAGED and current_state != State.DIED:
					current_state = State.ATTACK
			if hand_weapon.tool_type == "Pickaxe":
				if current_state != State.DAMAGED and current_state != State.DIED:
					current_state = State.MINING
			
		
func on_player_damage():
	current_state = State.DAMAGED
	

func on_attack_animation_finished():
	attak_collision.disabled = true
	current_state = State.IDLE
	set_physics_process(true)
	set_process_input(true)

func on_damage_animation_finished():
	current_state = State.IDLE
	set_physics_process(true)
	set_process_input(true)

func on_mining_animation_finished():
	attak_collision.disabled = true
	current_state = State.IDLE
	set_physics_process(true)
	set_process_input(true)


func _on_area_pick_up_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		inventory.add_item(area.inventory_item, area.stacks)
		area.queue_free()
		
func set_active_weapon(weapon: InventoryItem, slot_to_equip: String):
	
	if slot_to_equip == "Weapon":
		hand_weapon = weapon
