extends StaticBody2D

class_name ResourceItem

@export var useful_resource: UsefulResource

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var stacks: int = 1

func _ready() -> void:
	sprite_2d.texture = useful_resource.texture
	collision_shape_2d.shape = useful_resource.ground_collision_shape

func disable_collision():
	collision_shape_2d.disabled = true
	
func enable_collision():
	collision_shape_2d.disabled = false
