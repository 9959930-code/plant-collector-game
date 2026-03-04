extends Node2D

@onready var title_label = $UI/TitleLabel
@onready var start_button = $UI/StartButton
@onready var option_button = $UI/OptionButton

func _ready():
	# 제목 반짝임 애니메이션
	var tween = create_tween().set_loops()
	tween.tween_property(title_label, "modulate:a", 0.6, 1.5)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)
	
	start_button.connect("pressed", Callable(self, "_on_start_pressed"))
	option_button.connect("pressed", Callable(self, "_on_option_pressed"))

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/OpeningScene.tscn")

func _on_option_pressed():
	# 간단한 옵션 토글 (사운드 On/Off 등)
	if AudioServer.is_bus_mute(0):
		AudioServer.set_bus_mute(0, false)
		option_button.text = "🔊 사운드 ON"
	else:
		AudioServer.set_bus_mute(0, true)
		option_button.text = "🔇 사운드 OFF"
