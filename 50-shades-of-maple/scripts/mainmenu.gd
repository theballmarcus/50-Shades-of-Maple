extends Control

@onready var chapterContainer = $ChapterContainer
@onready var http_request = $HTTPRequest

var nonStartedColor = Color(0.263, 0.263, 0.263, 1.0)
var nonFinishedColor = Color(0.601, 0.503, 0.0, 1.0)
var finishedColor = Color(0.263, 0.494, 0.0, 1.0)

var config

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	var send_headers = [
		"Authorization: Bearer %s" % Gamestate.JWT,
		"Content-Type: application/json",
		"x-api-key: crazyVildAPIKEYIDevelopment!"
	]
	if Gamestate.userChapterStates == {}:
		var response = http_request.request(Gamestate.API_URL + "/chapter_states", send_headers, HTTPClient.METHOD_GET)
	else:
		create_buttons()
		
	config = ConfigFile.new()
	var err = config.load("user://user_data.cfg")

func create_buttons():
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

		var finished_chapters = 0
		
		# Check if chapters inside is finished or not.
		for subChapter in chapters[chapter].keys():
			for recievedChapter in Gamestate.userChapterStates["chapters"]:
				if recievedChapter["chapter_id"] == chapters[chapter][subChapter]["id"] and recievedChapter["completed"] == true:
					finished_chapters = finished_chapters + 1
			
		if finished_chapters == 0:
			curChapterButton.find_child("ColorRect").color = nonStartedColor
			continue

		if finished_chapters < chapters[chapter].keys().size():
			curChapterButton.find_child("ColorRect").color = nonFinishedColor
		elif finished_chapters == chapters[chapter].keys().size():
			curChapterButton.find_child("ColorRect").color = finishedColor


func _on_request_completed(result, response_code, headers, body):
	print("Response code:", response_code)
	if result != OK:
		print("Request failed!")
		return
	var response_text = body.get_string_from_utf8()

	var data = JSON.new()
	var response_json = data.parse(response_text)
	if response_json == OK:
		if not "chapters" in data.data.keys():
			return

		print(data.data)
		Gamestate.userChapterStates = data.data
	else:
		return
	
	create_buttons()


func _on_button_pressed() -> void:
	Gamestate.JWT = "" # Replace with function body.
	config.erase_section("UserInfo")
	config.save("user://user_data.cfg")
	Gamestate.change_scene("res://instances/loginpage.tscn")
	Gamestate.clear_scene_history()
