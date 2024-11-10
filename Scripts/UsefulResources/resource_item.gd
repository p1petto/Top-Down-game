extends StaticBody2D

class_name ResourceItem

@export var useful_resource: UsefulResource

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var stacks: int = 1
var current_durability: int

@export var dropped_resource: InventoryItem 
const PICKUP_ITEM_SCENE = preload("res://Scenes/pick_up_item.tscn")

func _ready() -> void:
	sprite_2d.texture = useful_resource.texture
	collision_shape_2d.shape = useful_resource.ground_collision_shape
	current_durability = useful_resource.durability

func disable_collision():
	collision_shape_2d.disabled = true
	
func enable_collision():
	collision_shape_2d.disabled = false
	
func apply_damage(damage_amount: int) -> void:
	current_durability -= damage_amount
	if current_durability <= 0:
		handle_destruction()
		eject_item_into_the_ground()

func handle_destruction() -> void:
	call_deferred("disable_collision")
	call_deferred("queue_free")
	
func eject_item_into_the_ground():
	if dropped_resource == null:
		return
	
	var item_to_eject_as_pickup = PICKUP_ITEM_SCENE.instantiate() as PickUpItem
	item_to_eject_as_pickup.inventory_item = dropped_resource
	item_to_eject_as_pickup.stacks = stacks

	get_tree().root.call_deferred("add_child", item_to_eject_as_pickup)

	item_to_eject_as_pickup.call_deferred("disable_collision")  

	item_to_eject_as_pickup.global_position = global_position - Vector2(5,5)

	item_to_eject_as_pickup.call_deferred("enable_collision")
