extends Node2D

@onready var chapterText = $ChapterText

var header_text = ["[font_size=20][b]", "[/b][/font_size]"]
var code_text = ["[bgcolor=#444444][color=#804d00]", "[/color][/bgcolor]"]

var input=Gamestate.chapters[Gamestate.menuChapter][Gamestate.curChapter].text

func _ready() -> void:
	input = input.replace("[h]",header_text[0])
	input = input.replace("[/h]",header_text[1])
	
	input = input.replace("[c]",code_text[0])
	input = input.replace("[/c]",code_text[1])
	chapterText.text = input
