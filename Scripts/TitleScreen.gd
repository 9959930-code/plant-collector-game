extends Node2D

@onready var title_logo = $UI/LogoRect
@onready var start_button = $UI/StartButton
@onready var option_button = $UI/OptionButton

func _ready():
	# 로고 약간의 둥실거림 (숨쉬기 애니메이션)
	var tween = create_tween().set_loops()
	tween.tween_property(title_logo, "position:y", 70.0, 1.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_logo, "position:y", 80.0, 1.5).set_trans(Tween.TRANS_SINE)
	# 시그널은 .tscn에서 이미 연결되어 있으므로 여기서 connect 하지 않음

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/OpeningScene.tscn")

func _on_option_pressed():
	if AudioServer.is_bus_mute(0):
		AudioServer.set_bus_mute(0, false)
		option_button.text = "🔊 사운드 ON"
	else:
		AudioServer.set_bus_mute(0, true)
		option_button.text = "🔇 사운드 OFF"
