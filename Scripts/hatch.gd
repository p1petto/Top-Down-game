extends Area2D

# Укажите путь к сцене, на которую нужно перейти
@export var next_scene: String = "res://Scenes/main.tscn"
@export var transition_duration: float = 0.5

func _ready() -> void:
	input_pickable = true

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			transition_to_scene()

func transition_to_scene() -> void:
	# Создаем анимацию затемнения
	var transition = ColorRect.new()
	transition.color = Color(0, 0, 0, 0)  # Начинаем с прозрачного
	transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(transition)
	
	# Создаем tween для плавного перехода
	var tween = create_tween()
	tween.tween_property(transition, "color:a", 1.0, transition_duration)
	await tween.finished
	
	# Меняем сцену
	get_tree().change_scene_to_file(next_scene)
	
	# Удаляем transition
	transition.queue_free()
