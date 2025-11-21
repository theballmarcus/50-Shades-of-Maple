extends Control

@onready var chapterContainer = $ChapterContainer
@onready var curChapterLabel = $"50-Shades-of-Maple"

var finishedColor = Color(0.263, 0.494, 0.0, 1.0)

func _ready():
	curChapterLabel.text = Gamestate.menuChapter
	var container_size = chapterContainer.size
	var chapter_button = preload("res://instances/EnterChapterButton.tscn")
	var chapter_button_size = chapter_button.instantiate().find_child("ColorRect").size
	var chapters = Gamestate.chapters[Gamestate.menuChapter]
	var nChapters = chapters.size()

	var i = 0
	for chapter in chapters.keys():
		var curChapterButton = chapter_button.instantiate()
		curChapterButton.chapter_text = chapter
		chapterContainer.add_child(curChapterButton)
		curChapterButton.position = Vector2((container_size.x / (nChapters - 1))  * i,chapter_button_size.y / 2)

		i = i + 1
		for recievedChapter in Gamestate.userChapterStates["chapters"]:
			if recievedChapter["chapter_id"] == chapters[chapter]["id"]:
				curChapterButton.find_child("ColorRect").color = finishedColor
