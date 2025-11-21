extends Node

# Global variables
var soundEffectLevel :float= 0.05
var JWT = ""
var menuChapter
var curChapter
var curChapterSolved = false

# Constants
const chapters = {
	"Basics" : {
		"Intro" : {
			"text" :" [h]Velkommen til Maple[/h][br][br]Maple er et matematikprogram, der kan hjælpe med at løse de matematiske problemer, du står over for i skolen.[br][br]Til højre er der en boks, som kan køre maple kode. For at komme videre, skriv [c]2+2[/c] og klik submit.",
			"correct_answers" : ["4"],
			"id" : 1
		},
		"Aritmetik" : {
			"dependency" : ["Intro"],
			"text" : "blabla",
			"correct_answers" : [],
			"id" : 2
		},
		"Variabler" : {
			"dependency" : ["Aritmetik"],
			"text" : "blabla",
			"correct_answers" : [],
			"id" : 3
		}
	},
	"Funktioner" : {
		
	},
	"Units" : {
		
	}
}

const API_URL = "http://139.59.130.153:3000"  
const API_KEY = "x-api-key: crazyVildAPIKEYIDevelopment!"
var headers = ["Content-Type: application/json", Gamestate.API_KEY]

# User data
var username = ""
var user_id = ""

var userChapterStates = {
	
}
