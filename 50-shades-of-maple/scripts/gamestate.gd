extends Node

var soundEffectLevel :float= 0.05
var chapters = {
	"Basics" : {
		"Aritmetik" : {
			"dependency" : []
		},
		"Variabler" : {
			"dependency" : ["Aritmetik"]
		}
	},
	"Funktioner" : {
		
	},
	"Units" : {
		
	}
}
const API_URL = "http://139.59.130.153:3000"  
const API_KEY = "x-api-key: crazyVildAPIKEYIDevelopment!"
var JWT_TOKEN = ""
