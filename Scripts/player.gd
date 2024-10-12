extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimationController = $Sprite2D
@onready var combat_system: CombatSystem = $CombatSystem
@onready var health_system: HealthSystem = $HealthSystem


const SPEED = 5000.0

@export var health = 100

func _ready() -> void:
	health_system.init(health)
	health_system.died.connect(on_player_dead)
	#health_system.damage_taken.connect(on_player_damage)

func _physics_process(delta: float) -> void:
	
	if animated_sprite_2d.animation.contains("attack"):
		return
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction:
		velocity = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)

	if velocity != Vector2.ZERO:
		animated_sprite_2d.play_movement_animation(velocity)
	else:
		animated_sprite_2d.play_idle_animation()

	move_and_slide()
	
func on_player_dead():
	set_physics_process(false)
	combat_system.set_process_input(false)
	animated_sprite_2d.play("died")
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Enemy':
		$"../Enemy/HealthSystem".apply_damage(3)
		print("Enemy health: ", $"../Enemy/HealthSystem".current_health)
		
		
		
#func on_player_damage():
	#animated_sprite_2d.play_damaged_animation()
