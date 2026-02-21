"
The class `ApiToolGetWeather` is designed to fetch the current weather for a specified city. It extends the functionality of `AilienApiTool` and is part of the 'AIActions' package. The class uses geocoding to convert a city name into latitude and longitude coordinates, then retrieves the current weather data for those coordinates. The tool handles potential errors during the geocoding and weather data retrieval processes and provides appropriate feedback. The class is tagged with 'AIApi' to indicate its role in an AI-related context.
"
Class {
	#name : 'ApiToolWebReader',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ApiToolWebReader >> evaluateTool [
	"Evaluates the tool with the given descriptions and returns a dictionary representation of the tool's configuration."
	| desc desc1 |
	desc := 'Can load any website, returning the html at that site. Always try https before http'.
	desc1 := 'The arrayed list of websites'.
    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'as yet unclassified' }
ApiToolWebReader >> evaluateTool: descs [
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
ApiToolWebReader >> executeTool: args [
	"Fetches the current weather for a city in any country"

	|  response websites  |
	 
	super executeTool: args .
	response := WriteStream on: ''.
	websites := args at: required.
	websites do: [ :aWebsite |
		[response << (ZnClient new url: aWebsite; get) << String lf]
			on: Error
			do: [ self halt. response << 'ERROR occured when trying to access ' << aWebsite << String lf   ]
	 ].
	^ response contents.
	
]

{ #category : 'initialization' }
ApiToolWebReader >> initialize [
	name := 'getWebSite'.
	required := 'website'
]
