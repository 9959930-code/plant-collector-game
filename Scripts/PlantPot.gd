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
		is_watered = false
		update_visuals()
		
		if current_stage == max_stage:
			grow_timer.stop()

func update_visuals():
	var label_text = ""
	
	if current_stage == 0:
		if is_watered:
			label_text = "[화분]\n촉촉함..."
		else:
			label_text = "[화분]\n물 필요"
		sprite.texture = preload("res://Assets/Images/plant_soil.png")
		sprite.scale = Vector2(0.2, 0.2)
	elif current_stage == 1:
		if is_watered:
			label_text = "[새싹]\n성장 중..."
		else:
			label_text = "[새싹]\n물 필요"
		sprite.texture = preload("res://Assets/Images/plant_sprout.png")
		sprite.scale = Vector2(0.2, 0.2)
	elif current_stage == 2:
		if is_watered:
			label_text = "[자라는 " + plant_type + "]\n성장 중..."
		else:
			label_text = "[자라는 " + plant_type + "]\n물 필요"
		sprite.texture = preload("res://Assets/Images/plant_alive.png")
		sprite.scale = Vector2(0.3, 0.3)
	elif current_stage == 3:
		label_text = "[만개한 " + plant_type + "]\n수확 가능!"
		sprite.texture = preload("res://Assets/Images/plant_alive.png")
		sprite.scale = Vector2(0.4, 0.4)
	
	status_label.text = label_text

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", self)
