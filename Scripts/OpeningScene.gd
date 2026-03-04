extends Node2D

@onready var dialogue_text = $DialogueBox/DialogueText
@onready var type_timer = $TypeTimer
@onready var background = $Background
@onready var click_prompt = $DialogueBox/ClickPrompt
@onready var rain_particles = $RainParticles
@onready var plant_image = $PlantContainer/PlantImage

var tex_office = preload("res://Assets/Images/bg_office.png")
var tex_room = preload("res://Assets/Images/bg_room.png")
var tex_greenhouse = preload("res://Assets/Images/bg_greenhouse.png")
var tex_soil = preload("res://Assets/Images/plant_soil.png")
var tex_sprout = preload("res://Assets/Images/plant_sprout.png")

var story_lines = [
	"지긋지긋한 야근, 텅 빈 사무실...",
	"\"나, 퇴사해. 내 자리 좀 정리해 줄래?\"",
	"언제나 기계 같았던 사수가 돌연 남긴 사직서와, 책상 위 덩그러니 놓인 다 말라죽어가는 화분 하나.",
	"왠지 버릴 수 없어 집으로 가져왔지만, 피곤한 일상에 치여 며칠을 방치해 두었다.",
	"비가 쏟아지는 주말의 밤, 어두운 방구석.",
	"문득 베란다 구석에 던져둔 그 흙만 남은 화분이 눈에 들어왔다.",
	"미안한 마음에 물을 한 컵 흠뻑 부어주었다.",
	"그리고 다음 날 아침...",
	"잿빛이던 내 방 베란다에서, 오직 그 화분 하나만이 눈부신 초록색 싹을 피워냈다.",
	"내 안의 멈춰있던 무엇인가가, 다시 뛰기 시작했다."
]

var current_line_index = 0
var is_typing = false
var full_text = ""
var visible_chars = 0

func _ready():
	dialogue_text.text = ""
	click_prompt.visible = false
	
	# 초기 씬: 사무실
	rain_particles.emitting = false
	background.texture = tex_office
	plant_image.texture = null # 초반엔 화분 안보임
	
	type_timer.connect("timeout", Callable(self, "_on_type_timer_timeout"))
	show_line()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance_dialogue()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		advance_dialogue()

func advance_dialogue():
	if is_typing:
		is_typing = false
		type_timer.stop()
		dialogue_text.visible_characters = -1
		click_prompt.visible = true
	else:
		current_line_index += 1
		if current_line_index < story_lines.size():
			show_line()
		else:
			start_game()

func show_line():
	click_prompt.visible = false
	var plant_container = $PlantContainer
	
	# ── 대사 진행에 따른 연출 ──
	# 좌표 기준: 게임 뷰포트 1152x648, 배경 이미지 1024x1024 (TextureRect가 늘려서 표시)
	# 비율 보정: x좌표 = 이미지상 x * (1152/1024) ≈ ×1.125
	#            y좌표 = 이미지상 y * (648/1024)  ≈ ×0.633
	
	if current_line_index == 2:
		# [사무실] 키보드 왼쪽 흰색 종이 위
		# 이미지상 (370, 530) → 뷰포트 (416, 336)
		plant_image.texture = tex_soil
		plant_image.scale = Vector2(0.12, 0.12)
		plant_container.position = Vector2(416, 336)
		plant_image.modulate = Color(0.7, 0.7, 0.7, 1)
		
	elif current_line_index == 3:
		# 집에 가져옴 → 사무실에서 서서히 사라지는 연출
		var fade = create_tween()
		fade.tween_property(plant_image, "modulate:a", 0.3, 0.8)
		
	elif current_line_index == 4:
		# [방] 베란다 유리문 앞 바닥, 달빛이 비치는 곳에 방치
		# 이미지상 (570, 620) → 뷰포트 (640, 393)
		background.texture = tex_room
		rain_particles.emitting = true
		plant_container.position = Vector2(640, 393)
		plant_image.scale = Vector2(0.10, 0.10)
		plant_image.modulate = Color(0.4, 0.4, 0.5, 0.5)
		
	elif current_line_index == 5:
		# 화분이 눈에 들어옴 → 달빛에 밝아지며 시선 끌기
		var notice = create_tween()
		notice.tween_property(plant_image, "modulate", Color(0.6, 0.6, 0.7, 1.0), 1.5)
		
	elif current_line_index == 6:
		# 물주기 → 물빛 푸른 틴트
		var t_tween = create_tween()
		t_tween.tween_property(plant_image, "modulate", Color(0.7, 0.8, 1.0, 1.0), 1.0)
		
	elif current_line_index == 7:
		# 다음날 아침 (비 그침)
		rain_particles.emitting = false
		plant_image.modulate = Color(1, 1, 1, 1)
		
	elif current_line_index == 8:
		# [베란다] 바닥 왼쪽 화분 4개 나란히 있는 바로 옆
		# 이미지상 (350, 870) → 뷰포트 (394, 551)
		var bg_tween = create_tween()
		bg_tween.tween_property(background, "modulate", Color(0.3, 0.3, 0.3, 1), 0.5)
		bg_tween.tween_callback(func(): background.texture = tex_greenhouse)
		bg_tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 2.0)
		
		plant_container.position = Vector2(394, 551)
		plant_image.texture = tex_sprout
		plant_image.scale = Vector2(0.03, 0.03)
		plant_image.modulate = Color(1, 1, 1, 1)
		var plant_tween = create_tween()
		plant_tween.tween_property(plant_image, "scale", Vector2(0.08, 0.08), 2.5).set_trans(Tween.TRANS_ELASTIC)
	
	full_text = story_lines[current_line_index]
	dialogue_text.text = full_text
	dialogue_text.visible_characters = 0
	visible_chars = 0
	is_typing = true
	type_timer.start()

func _on_type_timer_timeout():
	if is_typing:
		visible_chars += 1
		dialogue_text.visible_characters = visible_chars
		if visible_chars >= full_text.length():
			is_typing = false
			type_timer.stop()
			click_prompt.visible = true

func start_game():
	print("오프닝 종료 - 메인 게임 화면으로 이동합니다!")
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")

