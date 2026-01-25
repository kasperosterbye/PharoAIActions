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
