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
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'city' -> (Dictionary newFrom: {
                         'type' -> 'string'.
                         'description' -> desc1
                     })
                }).
                'required' -> { required }
            })
        })
    }
]

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> executeTool: aCityName [
    | url response |
    url := 'http://wttr.in/', aCityName urlEncoded, '?format=3'.
    [ response := ZnClient new get: url.
      ^ response trimBoth
    ] on: Error do: [ :ex |
        ^ 'Couldn''t fetch weather for ', aCityName, ': ', ex messageText ]
]

{ #category : 'initialization' }
ApiToolGetWeather >> initialize [
	name := 'getWeather'.
	required := 'city'
]
