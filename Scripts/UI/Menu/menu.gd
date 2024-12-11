extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("start")
	$AnimatedSprite2D2.play("start")
	$AudioStreamPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "start":
		$AnimatedSprite2D.play("loop",)
		$AnimatedSprite2D2.play("loop")
		$AnimationPlayer.play("modulate")
		
func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file('res://Scenes/world/zero.tscn')
	pass

func _on_button_exit_pressed() -> void:
	get_tree().quit()
	pass