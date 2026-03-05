extends Area2D

signal pot_interacted(pot_data)

var data: Dictionary = {}
var _pending_data: Dictionary = {}
var is_ready = false

@onready var sprite = $Sprite2D
@onready var condition_label = $ConditionLabel

func _ready():
	is_ready = true
	# 화분 스프라이트 (씨앗 단계 기본)
	sprite.texture = preload("res://Assets/Images/balcony_props.png")
	sprite.region_enabled = true
	
	if not _pending_data.is_empty():
		_apply_data(_pending_data)

func setup(p_data: Dictionary):
	data = p_data
	_pending_data = p_data
	if is_ready:
		_apply_data(p_data)

func _apply_data(p_data: Dictionary):
	if p_data["stage"] == 0:
		# 아직 다 자라지 않은 화분 스프라이트 파트
		sprite.region_rect = Rect2(59, 137, 60, 60) 
	else:
		# 잎이 자란 화분 (대략적)
		sprite.region_rect = Rect2(65, 59, 60, 70)
		
	var status_text = "[center]"
	if p_data["stage"] == 0:
		status_text += "[화분]\n"
	else:
		status_text += "[새싹화분]\n"
		
	if not p_data["watered"]:
		status_text += "물 필요[/center]"
	else:
		status_text += "촉촉함[/center]"
		
	condition_label.text = status_text

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("pot_interacted", data)
