extends Node2D

class_name CombatSystem

@onready var animated_sprite_2d: AnimationController = $"../Sprite2D"
@onready var attak_collision: CollisionShape2D = $"../Area2D/AttakCollision"

var can_attack = true



func _ready() -> void:
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)


func _input(event):
	
	if Input.is_action_just_pressed("left_hand_attack"):
		
		if !can_attack:
			return
		can_attack = false
		animated_sprite_2d.play_attack_animation()
		attak_collision.disabled = false
	
		 
	

func on_attack_animation_finished():
	can_attack = true
	attak_collision.disabled = true
	
