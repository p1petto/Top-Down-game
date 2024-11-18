extends AudioStreamPlayer

var background_music = "res://Assets/music/background/Minifantasy_Dungeon_Music/Music/Goblins_Dance_(Battle).wav" # Измените путь на ваш
const SAVE_PATH = "res://Assets/music/background/background_music.save"

func _ready() -> void:
	stream = load(background_music)
	volume_db = -10  
	bus = "Music"    
	
	play()

func fade_in(duration: float = 1.0) -> void:
	var tween = create_tween()
	volume_db = -80
	tween.tween_property(self, "volume_db", -10, duration)
	play()

func fade_out(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, duration)
	tween.tween_callback(stop)

func change_music(music_path: String, fade_duration: float = 1.0) -> void:
	fade_out(fade_duration)
	await get_tree().create_timer(fade_duration).timeout
	stream = load(music_path)
	fade_in(fade_duration)
	
func save_settings():
	var settings = {
		"music_volume": volume_db
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(settings)

func load_settings():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var settings = file.get_var()
		volume_db = settings.get("music_volume", -10)
