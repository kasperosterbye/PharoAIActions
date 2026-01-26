Class {
	#name : 'ApiToolGetWeather',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> evaluateTool [
	| desc desc1 |
	desc := 'Fetches the current weather for a city in any country. '.
	desc1 := 'The city name, e.g., London'.
    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> executeTool: args [

	| aCityName url response |
	super executeTool: args.
	aCityName := args at: required.
	url := 'http://wttr.in/' , aCityName urlEncoded , '?format=3'.
	[
		response := ZnClient new get: url.
		^ response trimBoth ]
		on: Error
		do: [ :ex | ^ 'Couldn''t fetch weather for ' , aCityName , ': ' , ex messageText ]
]

{ #category : 'initialization' }
ApiToolGetWeather >> initialize [
	name := 'getWeather'.
	required := 'city'
]

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> temperatureFromOpenMeteo: aCityName [
	"Returns the current temperature in Celsius for a given city using the Open-Meteo API.
	This involves two steps: 1. Geocoding the city name. 2. Fetching the weather."
	| geoUrl geoResponse geoData lat lon weatherUrl weatherResponse weatherData temperature |
	
	"Step 1: Geocoding - Convert city name to latitude and longitude"
	geoUrl := 'https://geocoding-api.open-meteo.com/v1/search?name={1}&count=1' format: { aCityName urlEncoded }.
	
	[ geoResponse := ZnClient new url: geoUrl; get.
self halt.
	"geoResponse isSuccess ifFalse: [ self error: 'Geocoding failed' ]."
	
	geoData := STONJSON fromString: geoResponse contents.
	(geoData includesKey: #results) ifFalse: [ self error: 'City not found' ].
	
	lat := (geoData at: #results) first at: #latitude.
	lon := (geoData at: #results) first at: #longitude.
	"Step 2: Weather - Get current weather for the coordinates"
	weatherUrl := 'https://api.open-meteo.com/v1/forecast?latitude={1}&longitude={2}&current_weather=true' 
		format: { lat . lon }.
	
	weatherResponse := ZnClient new url: weatherUrl; get.
	weatherResponse isSuccess ifFalse: [ self error: 'Weather fetch failed' ].
	
	weatherData := STONJSON fromString: weatherResponse contents.
	temperature := weatherData atPath: #(current_weather temperature).
	
	^ temperature ]
	on: Error do: [ :ex | 
		Transcript show: 'Error fetching weather for ', aCityName, ': ', ex description; cr.
		^ nil ].
]
