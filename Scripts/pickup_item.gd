extends Area2D

@onready var sprite = $Sprite2D

#enum Pickups { FOOD, CRAFT }
#
#@export var item_types: Array = [Pickups.FOOD, Pickups.CRAFT]

@export var item_name: String

func _ready() -> void:
	var texture_path = "res://Assets/objects/" + item_name + ".png"  
	var texture = load(texture_path) as Texture2D  

	if texture:
		sprite.texture = texture
	else:
		print("Ошибка: текстура не найдена по пути", texture_path)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
