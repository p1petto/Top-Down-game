extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimationController = $Sprite2D
@onready var health_system: HealthSystem = $HealthSystem
@onready var hunger_system: HungerSystem = $HungerSystem
@onready var attak_collision: CollisionShape2D = $"Area2D/AttakCollision"
@onready var inventory: Inventory = $Inventory
@onready var inventory_ui: InventoryUI = $InventroryUI
@onready var on_screen_ui: OnScreenUI = $OnScreenUI
@onready var items 
@onready var sound: SoundPlayer =  $AudioStreamPlayer

@onready var slots: Array


@export var hand_weapon: InventoryItem

var enemies_group = null
var knockback_direction = null

enum State { ATTACK, DAMAGED, WALKING, DIED, IDLE, MINING }
var current_state : State = State.IDLE : 
	set(new_state):
		# print_debug("Changing State from %s to %s" % [current_state, new_state])
		current_state = new_state
		
var current_delta: float = 0.0

func _ready() -> void:
	## Используем stats из синглтона
	if not GameData.player_stats:
		GameData.player_stats = PlayerStats.new()
	print("Player ready ", GameData.player_stats.max_health)

	health_system.init(GameData.player_stats.max_health)
	health_system.current_health = GameData.player_stats.current_health
	
	health_system.died.connect(on_player_dead)
	health_system.damage_taken.connect(on_player_damage)
	health_system.health_changed.emit()
	
	animated_sprite_2d.damage_animation_finished.connect(on_damage_animation_finished)
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)
	animated_sprite_2d.mining_animation_finished.connect(on_mining_animation_finished)
	
	hunger_system.init(GameData.player_stats.max_satiety)
	hunger_system.current_satiety = GameData.player_stats.current_satiety
	
	hunger_system.hunger_die.connect(on_player_dead)
	
	inventory.item_health.connect(_on_health_item_eated)

	var grid = inventory_ui.get_node("%GridContainer")
	slots = grid.get_children()
	for slot in slots:
		slot.eat_item.connect(func ():eating(slot))
	
	
	# if GameData.player_inventory.size() > 0:
	# 	inventory.items = GameData.player_inventory.duplicate()
	# 	for item in inventory.items:
	# 		inventory_ui.add_item(item) 
	if GameData.player_stats.hand_weapon:
		set_active_weapon(GameData.player_stats.hand_weapon)
		on_screen_ui.equip_item(GameData.player_stats.hand_weapon,)
	


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	current_delta = delta
	#print (current_state)
	match current_state:
		State.IDLE:
			handle_idle_state(delta)
			
		State.WALKING:
			handle_walking_state(direction, delta)
			
		State.ATTACK:
			handle_attack_state(delta)
			
		State.MINING:
			handle_mining_state(delta)
			
		State.DAMAGED:
			handle_damaged_state(delta)
			
		State.DIED:
			print("DIED")
			handle_died_state()
			
		
	
	if direction and (current_state != State.DAMAGED or current_state != State.DIED):
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
	current_state = State.DIED
	set_physics_process(false)
	set_process_input(false)
	animated_sprite_2d.play("died")
	sound.play_death_sound()

func handle_damaged_state(delta: float) -> void:
	set_physics_process(false)
	set_process_input(false)
	attak_collision.disabled = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play_damaged_animation()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		print ("bo")
		body.health_system_enemy.apply_damage(hand_weapon.damage)
		knockback_direction = (body.global_position - global_position) * GameData.player_stats.knockback_power
		body.knockback(knockback_direction, current_delta)
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
	print ("on_player_dead")
	current_state = State.DIED
	#GameData.player_stats.current_health = 0
	
func _on_health_item_eated(amount: int):
	print("HEAL")
	health_system.heal(amount)
	hunger_system.eat(100)

func on_player_damage() -> void:
	current_state = State.DAMAGED
	GameData.player_stats.current_health = health_system.current_health
	sound.play_damage_sound()

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

func set_active_weapon(weapon: InventoryItem) -> void:
	if weapon.slot_type == "Weapon":
		hand_weapon = weapon
	else:
		printerr("Неправильный тип предмета")
		
func eating(slot):
	print(slot)
