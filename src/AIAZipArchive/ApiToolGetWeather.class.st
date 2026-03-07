"
The class `ApiToolGetWeather` is designed to fetch the current weather for a specified city. It extends the functionality of `AilienApiTool` and is part of the 'AIActions' package. The class uses geocoding to convert a city name into latitude and longitude coordinates, then retrieves the current weather data for those coordinates. The tool handles potential errors during the geocoding and weather data retrieval processes and provides appropriate feedback. The class is tagged with 'AIApi' to indicate its role in an AI-related context.
"
Class {
	#name : 'ApiToolGetWeather',
	#superclass : 'AilienApiTool',
	#category : 'AIAZipArchive-AIApiTools',
	#package : 'AIAZipArchive',
	#tag : 'AIApiTools'
}

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> describeWeatherCode: code [
    code = 0 ifTrue: [ ^ 'clear sky' ].
    (code between: 1 and: 3) ifTrue: [ ^ 'partly cloudy' ].
    (code between: 51 and: 67) ifTrue: [ ^ 'rain' ].
    (code between: 71 and: 77) ifTrue: [ ^ 'snow' ].
    (code between: 80 and: 82) ifTrue: [ ^ 'rain showers' ].
    (code between: 95 and: 99) ifTrue: [ ^ 'thunderstorm' ].
    ^ 'overcast'
]

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> evaluateTool [
	"Evaluates the tool with the given descriptions and returns a dictionary representation of the tool's configuration."
	| desc desc1 |
	desc := 'Fetches the current weather for a city in any country. '.
	desc1 := 'The city name, e.g., London'.
    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'as yet unclassified' }
ApiToolGetWeather >> evaluateTool: descs [
	"Evaluates the tool with the given descriptions and returns a dictionary representation of the tool's configuration."
	| desc desc1|
	desc := descs first.
	desc1 := descs second.
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    required -> (Dictionary newFrom: {
                        'type' -> 'array'.
							  'items' -> (Dictionary newFrom: { 'type' -> 'string'}).
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]

{ #category : 'Protocol (as yet unclassified) - 4 selector(s)' }
ApiToolGetWeather >> executeTool: args [
	"Fetches the current weather for a city in any country"

	|  response cityNames  |
	 
	super executeTool: args .
	response := WriteStream on: ''.
	cityNames := args at: required.
	cityNames do: [ :aCityName |
		response << (self weatherAt: aCityName) << String lf
	 ].
	Transcript << '>>> ' << response contents << String lf.
	^ response contents.
	
]

{ #category : 'initialization' }
ApiToolGetWeather >> initialize [
	name := 'getWeather'.
	required := 'city'
]

{ #category : 'accessing' }
ApiToolGetWeather >> weatherAt: aCity [
    | geoUrl geoResponse geoData lat lon weatherUrl weatherResponse weatherData current temperature windspeed weathercode |
    [
        geoUrl := 'https://geocoding-api.open-meteo.com/v1/search?name={1}&count=1'
                format: { aCity urlEncoded }.
        geoResponse := ZnClient new url: geoUrl; get.
        geoData := STONJSON fromString: geoResponse contents.
        (geoData includesKey: #results) ifFalse: [ ^ 'City not found' ].
        lat := (geoData at: #results) first at: #latitude.
        lon := (geoData at: #results) first at: #longitude.

        weatherUrl := 'https://api.open-meteo.com/v1/forecast?latitude={1}&longitude={2}&current_weather=true&hourly=precipitation'
                format: { lat . lon }.
        weatherResponse := ZnClient new url: weatherUrl; get.
        weatherData := STONJSON fromString: weatherResponse contents.
        current := weatherData at: 'current_weather'.
        temperature := (current at: 'temperature') rounded.
        windspeed := ((current at: 'windspeed') / 3.6) rounded.
        weathercode := (current at: 'weathercode') .
        ^ '{1} ºC, {2}, wind {3} m/s'
                format: { temperature asString . (self describeWeatherCode: weathercode) . windspeed asString }
    ]
    on: Error do: [ :ex |
        ^ 'Error fetching weather for ' , aCity , ': ' , ex description ].
]
