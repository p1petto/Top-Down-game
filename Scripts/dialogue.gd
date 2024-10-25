extends CanvasLayer

class_name Dialogue_system



var dialogue = []
var cur_dialogue_id = -1
var d_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NinePatchRect.visible = false
	
func start(d_file):
	if d_active:
		return
	d_active = true
	$NinePatchRect.visible = true
	dialogue = load_dialogue(d_file)
	next_script()
	#$NinePatchRect/Name.text = dialogue[0]['name']
	#$NinePatchRect/Chat.text = dialogue[0]['text']

func load_dialogue(d_file):
		
	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script():
	cur_dialogue_id += 1
	
	if cur_dialogue_id >= len(dialogue):
		d_active = false
		$NinePatchRect.visible = false
		return
	
	$NinePatchRect/Name.text = dialogue[cur_dialogue_id]['name']
	$NinePatchRect/Chat.text = dialogue[cur_dialogue_id]['text']
