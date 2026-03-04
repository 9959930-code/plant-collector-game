extends Area2D

@onready var sprite = $Sprite
@onready var grow_timer = $GrowTimer
@onready var status_label = $StatusLabel

var plant_type = "씨앗"
var current_stage = 0
var max_stage = 3 # 0: 씨앗, 1: 새싹, 2: 성장, 3: 만개
var grow_time_per_stage = 10.0 # 스테이지당 10초 (테스트용)
var is_watered = false

signal clicked(pot_node)

func _ready():
	update_visuals()
	grow_timer.connect("timeout", Callable(self, "_on_grow_timer_timeout"))

func plant_seed(type: String):
	plant_type = type
	current_stage = 0
	is_watered = false
	update_visuals()
	
func water():
	if not is_watered and current_stage < max_stage:
		is_watered = true
		grow_timer.start(grow_time_per_stage)
		update_visuals()

func _on_grow_timer_timeout():
	if current_stage < max_stage:
		current_stage += 1
		is_watered = false # 다음 성장을 위해 물이 다시 필요함
		update_visuals()
		
		# 만약 만개했다면 타이머 정지
		if current_stage == max_stage:
			grow_timer.stop()

func update_visuals():
	status_label.text = status_label.text % plant_type
	
	if current_stage == 0:
		status_label.text = "[화분]\n물 필요" if not is_watered else "[화분]\n촉촉함..."
		sprite.texture = preload("res://Assets/Images/plant_soil.png") # 흙만 있는 화분
		sprite.scale = Vector2(0.2, 0.2)
	elif current_stage == 1:
		status_label.text = "[새싹]\n물 필요" if not is_watered else "[새싹]\n성장 중..."
		sprite.texture = preload("res://Assets/Images/plant_sprout.png") # 앙증맞은 새싹
		sprite.scale = Vector2(0.2, 0.2)
	elif current_stage == 2:
		status_label.text = "[자라는 %s]\n물 필요" if not is_watered else "[자라는 %s]\n성장 중..."
		sprite.texture = preload("res://Assets/Images/plant_alive.png") # 무럭무럭 자라는 중
		sprite.scale = Vector2(0.3, 0.3)
	elif current_stage == 3:
		status_label.text = "[만개한 %s]\n수확 가능!"
		sprite.texture = preload("res://Assets/Images/plant_alive.png") # 완전히 자람
		sprite.scale = Vector2(0.4, 0.4)
		
	status_label.text = status_label.text % plant_type

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", self)
