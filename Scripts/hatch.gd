extends Area2D

# Укажите путь к сцене, на которую нужно перейти
@export var next_scene: String = "res://Scenes/main.tscn"
@export var transition_duration: float = 0.5

var can_interact = false

func _ready() -> void:
	input_pickable = true

		
func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		transition_to_scene()

func transition_to_scene() -> void:
	var transition = ColorRect.new()
	transition.color = Color(0, 0, 0, 0)  
	transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition.position = Vector2(0, -200)
	get_tree().root.add_child(transition)
	
	var tween = create_tween()
	tween.tween_property(transition, "color:a", 1.0, transition_duration)
	await tween.finished
	transition.queue_free()
	get_tree().change_scene_to_file(next_scene)
	
	


func _on_body_entered(body: Node2D) -> void:
	print ("true")
	if body.name == 'Player':
		can_interact = true


func _on_body_exited(body: Node2D) -> void:
	print ("false")
	if body.name == 'Player':
		can_interact = false
