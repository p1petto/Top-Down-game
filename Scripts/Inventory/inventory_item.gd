extends Resource

class_name InventoryItem 

var stacks = 1

@export_enum("Weapon", "NotEquipable") 
var slot_type: String = "NotEquipable"

@export_enum("Pickaxe", "Sword", "NoType") 
var tool_type: String = "NoType"

@export var ground_collision_shape: CapsuleShape2D
@export var name: String = ""
@export var texture: Texture2D
@export var side_texture: Texture2D
@export var max_stacks: int
@export var price: int
@export var food: bool
@export var damage: int = 0
@export var weapon_item: WeaponItem
