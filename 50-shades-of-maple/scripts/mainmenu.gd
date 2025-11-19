extends Control

@onready var chapterContainer = $ChapterContainer

func _ready():
	var container_size = chapterContainer.size
	var chapter_button = preload("res://instances/ChapterButton.tscn")
	var chapter_button_size = chapter_button.instantiate().find_child("ColorRect").size
	var chapters = Gamestate.chapters
	var nChapters = chapters.size()

	var i = 0
	for chapter in chapters.keys():
		var curChapterButton = chapter_button.instantiate()
		curChapterButton.chapter_text = chapter
		chapterContainer.add_child(curChapterButton)
		curChapterButton.position = Vector2((container_size.x / (nChapters - 1))  * i,chapter_button_size.y / 2)

		i = i + 1
