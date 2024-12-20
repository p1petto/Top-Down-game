extends Area2D

# Укажите путь к сцене, на которую нужно перейти
@export var next_scene: String 
@export var transition_duration: float = 0.5
@export var blocking_object: ResourceItem

var can_interact = false
var disguised = true

func _ready() -> void:
	input_pickable = true
	if blocking_object:
		blocking_object.destroed.connect(hide_disguise)
	else:
		disguised = false

		
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
	
	
func hide_disguise():
	disguised = false

func _on_body_entered(body: Node2D) -> void:
	print ("true")
	if body.name == 'Player' and !disguised:
		can_interact = true


func _on_body_exited(body: Node2D) -> void:
	print ("false")
	if body.name == 'Player':
		can_interact = false
