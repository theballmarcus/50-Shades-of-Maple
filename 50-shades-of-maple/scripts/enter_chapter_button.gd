extends Control

@onready var chapter_name = $ColorRect/ChapterName
@onready var button = $Button

@export var chapter_text: String:
	set(value):
		chapter_text = value
		update_text()

func _ready():
	button.pressed.connect(_on_button_pressed)

func update_text():
	if not is_inside_tree():
		await ready
	chapter_name.text = chapter_text

func _on_button_pressed():
	Gamestate.curChapter = chapter_name.text
	Gamestate.change_scene("res://instances/chapter.tscn")
