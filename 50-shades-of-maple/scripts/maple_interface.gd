extends Control

@onready var input_box = $UserInput
@onready var display = $Display
@onready var button = $Button
@onready var http_request = $HTTPRequest
@onready var output_box = $Output
@onready var cursor = $Display/Cursor

const API_URL = "http://139.59.130.153:3000/maple/eval"  
var font 
var curText
var displayText


func _ready():
	font = display.get_theme_font('normal_font')
	button.pressed.connect(_on_submit_pressed)
	http_request.request_completed.connect(_on_request_completed)
	
	display.bbcode_enabled = true
	input_box.text_changed.connect(_on_text_changed)

	# Optional: make the TextEdit text transparent so only the formatted one is visible
	input_box.add_theme_color_override("font_color", Color(1, 1, 1, 0)) 
	input_box.add_theme_color_override("caret_color", Color(0, 0, 0, 0))
	
	cursor.color = Color(1,1,1)
	cursor.size = Vector2(2, font.get_height())

func _process(delta: float) -> void:
	var line = input_box.get_caret_line()
	var column = input_box.get_caret_column()
	
	if curText != null:
		cursor.position = Vector2(font.get_string_size(displayText.substr(0,column)).x, (font.get_string_size(displayText).y) * (line))

func _on_text_changed():
	curText = input_box.text
	displayText = parse_math(curText)

	display.parse_bbcode(displayText)

func _on_submit_pressed():
	var user_text = input_box.text.strip_edges()
	if user_text == "":
		print("Textbox is empty.")
		return

	print("Sending text:", user_text)

	# Prepare data to send
	var data = {"code": user_text}
	var json_data = JSON.stringify(data)

	# Send the HTTP request
	var headers = ["Content-Type: application/json", "x-api-key: crazyVildAPIKEYIDevelopment!"]
	var response = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_data)

func _on_request_completed(result, response_code, headers, body):
	print("Response code:", response_code)
	if result != OK:
		print("Request failed!")
		return
	var response_text = body.get_string_from_utf8()

	var data = JSON.new()
	var response_json = data.parse(response_text)
	if response_json == OK:
		print("API Response:", data.data)
		output_box.text = data.data['stdout']
	else:
		print("Recieved invalid JSON from API")

# Helper functions
func parse_math(input: String) -> String:
	var output = ""
	var i = 0
	while i < input.length():
		var char = input[i]
		if char == "^" and i+1 < input.length():
			if input[i+1] == "(":
			# Superscript block
				var res = extract_block(input, i+2)
				var block_text = res[0]
				var end_index = res[1]
				output += convert_to_superscript(parse_math(block_text))
				i = end_index
			else:
				output += convert_to_superscript(input[i+1])
				i = i + 1
		elif char == "_" and i+1 < input.length():
			if  input[i+1] == "(":
				# Subscript block
				var res = extract_block(input, i+2)
				var block_text = res[0]
				var end_index = res[1]
				output += convert_to_subscript(parse_math(block_text))
				i = end_index
			else:
				output += convert_to_subscript(input[i+1])
				i=i+1
		else:
			output += char
		i += 1
	return output
	
# Extract content inside parentheses, handling nested ()
func extract_block(input: String, start_index: int) -> Array:
	var depth = 1
	var block = ""
	var i = start_index
	while i < input.length():
		var char = input[i]
		if char == "(":
			depth += 1
		elif char == ")":
			depth -= 1
			if depth == 0:
				break
		block += char
		i += 1
	return [block, i]

func convert_to_superscript(text: String) -> String:
	var result = ""
	for char in text:
		result += superscript_map.get(char, char)
	return result

func convert_to_subscript(text: String) -> String:
	var result = ""
	for char in text:
		result += subscript_map.get(char, char)
	return result

# Superscript mapping
var superscript_map = {
	"0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵",
	"6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
	"a": "ᵃ", "b": "ᵇ", "c": "ᶜ", "d": "ᵈ", "e": "ᵉ", "f": "ᶠ", "g": "ᵍ",
	"h": "ʰ", "i": "ⁱ", "j": "ʲ", "k": "ᵏ", "l": "ˡ", "m": "ᵐ", "n": "ⁿ",
	"o": "ᵒ", "p": "ᵖ", "r": "ʳ", "s": "ˢ", "t": "ᵗ", "u": "ᵘ", "v": "ᵛ",
	"w": "ʷ", "x": "ˣ", "y": "ʸ", "z": "ᶻ",
	"A": "ᴬ", "B": "ᴮ", "D": "ᴰ", "E": "ᴱ", "G": "ᴳ", "H": "ᴴ", "I": "ᴵ",
	"J": "ᴶ", "K": "ᴷ", "L": "ᴸ", "M": "ᴹ", "N": "ᴺ", "O": "ᴼ", "P": "ᴾ",
	"R": "ᴿ", "T": "ᵀ", "U": "ᵁ", "V": "ⱽ", "W": "ᵂ",
	"+": "⁺", "-": "⁻", "=": "⁼", "(": "⁽", ")": "⁾", " ": " "
}
# Subscript mapping
var subscript_map = {
	"0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄", "5": "₅",
	"6": "₆", "7": "₇", "8": "₈", "9": "₉",
	"a": "ₐ", "e": "ₑ", "h": "ₕ", "i": "ᵢ", "j": "ⱼ", "k": "ₖ", "l": "ₗ",
	"m": "ₘ", "n": "ₙ", "o": "ₒ", "p": "ₚ", "r": "ᵣ", "s": "ₛ", "t": "ₜ",
	"u": "ᵤ", "v": "ᵥ", "x": "ₓ",
	"+": "₊", "-": "₋", "=": "₌", "(": "₍", ")": "₎", " ": " "
}
