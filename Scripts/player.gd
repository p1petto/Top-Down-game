extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimationController = $Sprite2D
@onready var health_system: HealthSystem = $HealthSystem
@onready var attak_collision: CollisionShape2D = $"Area2D/AttakCollision"
@onready var inventory: Inventory = $Inventory
@onready var inventory_ui: InventoryUI = $InventroryUI
@onready var on_screen_ui: OnScreenUI = $OnScreenUI
@onready var items 

@export var hand_weapon: InventoryItem

var enemies_group = null
var knockback_direction = null

enum State { ATTACK, DAMAGED, WALKING, DIED, IDLE, MINING }
var current_state : State = State.IDLE : 
	set(new_state):
		current_state = new_state

func _ready() -> void:
	## Используем stats из синглтона
	if not GameData.player_stats:
		GameData.player_stats = PlayerStats.new()
	print("Player ready ", GameData.player_stats.max_health)

	health_system.init(GameData.player_stats.max_health)
	health_system.current_health = GameData.player_stats.current_health
	
	health_system.died.connect(on_player_dead)
	health_system.damage_taken.connect(on_player_damage)
	animated_sprite_2d.damage_animation_finished.connect(on_damage_animation_finished)
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)
	animated_sprite_2d.mining_animation_finished.connect(on_mining_animation_finished)
	
	health_system.health_changed.emit()
	
	if GameData.player_inventory.size() > 0:
		inventory.items = GameData.player_inventory.duplicate()
		for item in inventory.items:
			inventory_ui.add_item(item) 
	if GameData.player_stats.hand_weapon:
		set_active_weapon(GameData.player_stats.hand_weapon, "Weapon")
		on_screen_ui.equip_item(GameData.player_stats.hand_weapon, "Weapon")
	


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	match current_state:
		State.IDLE:
			handle_idle_state(delta)
			
		State.WALKING:
			handle_walking_state(direction, delta)
			
		State.ATTACK:
			handle_attack_state(delta)
			
		State.MINING:
			handle_mining_state(delta)
			
		State.DIED:
			handle_died_state()
			
		State.DAMAGED:
			handle_damaged_state(delta)
	
	if direction and current_state != State.DAMAGED:
		current_state = State.WALKING
		
	move_and_slide()

func handle_idle_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, GameData.player_stats.speed * delta)
	velocity.y = move_toward(velocity.y, 0, GameData.player_stats.speed * delta)
	attak_collision.disabled = true
	animated_sprite_2d.play_idle_animation()

func handle_walking_state(direction: Vector2, delta: float) -> void:
	velocity = direction * GameData.player_stats.speed * delta
	if !direction:
		current_state = State.IDLE
	animated_sprite_2d.play_movement_animation(velocity)

func handle_attack_state(delta: float) -> void:
	set_physics_process(false)
	set_process_input(false)
	animated_sprite_2d.play_attack_animation()
	attak_collision.disabled = false
	velocity = Vector2.ZERO

func handle_mining_state(delta: float) -> void:
	set_physics_process(false)
	set_process_input(false)
	animated_sprite_2d.play_mining_animation()
	attak_collision.disabled = false
	velocity = Vector2.ZERO

func handle_died_state() -> void:
	set_physics_process(false)
	set_process_input(false)
	animated_sprite_2d.play("died")

func handle_damaged_state(delta: float) -> void:
	set_physics_process(false)
	set_process_input(false)
	attak_collision.disabled = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play_damaged_animation()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.health_system_enemy.apply_damage(hand_weapon.damage)
		knockback_direction = (body.global_position - global_position) * GameData.player_stats.knockback_power
		body.knockback(knockback_direction)
	elif body.is_in_group("UsefullResources") and hand_weapon.tool_type == "Pickaxe":
		body.apply_damage(hand_weapon.damage)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_hand_attack") and hand_weapon != null:
		if current_state != State.DAMAGED and current_state != State.DIED:
			if hand_weapon.tool_type == "Sword":
				current_state = State.ATTACK
			elif hand_weapon.tool_type == "Pickaxe":
				current_state = State.MINING

func on_player_dead() -> void:
	current_state = State.DIED
	GameData.player_stats.current_health = 0

func on_player_damage() -> void:
	current_state = State.DAMAGED
	GameData.player_stats.current_health = health_system.current_health

func on_attack_animation_finished() -> void:
	reset_state()

func on_damage_animation_finished() -> void:
	reset_state()

func on_mining_animation_finished() -> void:
	reset_state()

func reset_state() -> void:
	attak_collision.disabled = true
	current_state = State.IDLE
	set_physics_process(true)
	set_process_input(true)

func _on_area_pick_up_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		inventory.add_item(area.inventory_item, area.stacks)
		area.queue_free()

func set_active_weapon(weapon: InventoryItem, slot_to_equip: String) -> void:
	if slot_to_equip == "Weapon":
		hand_weapon = weapon
