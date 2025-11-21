extends Control

@onready var chapterContainer = $ChapterContainer
@onready var http_request = $HTTPRequest


func _ready():
	http_request.request_completed.connect(_on_request_completed)
	var send_headers = [
		"Authorization: Bearer %s" % Gamestate.JWT,
		"Content-Type: application/json",
		"x-api-key: crazyVildAPIKEYIDevelopment!"
	]
	var response = http_request.request(Gamestate.API_URL + "/chapter_states", send_headers, HTTPClient.METHOD_GET)
		
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

func _on_request_completed(result, response_code, headers, body):
	print("Response code:", response_code)
	if result != OK:
		print("Request failed!")
		return
	var response_text = body.get_string_from_utf8()

	var data = JSON.new()
	var response_json = data.parse(response_text)
	if response_json == OK:
		print(data.data)
