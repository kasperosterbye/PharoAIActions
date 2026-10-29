Class {
	#name : 'AIAHistorySuccessfulTestApi',
	#superclass : 'AIAHistorySlowTestApi',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'responses' }
AIAHistorySuccessfulTestApi >> loadResponse: aHistory [
    "Simulate an API request that completes successfully."
    aHistory assistant: 'Successful test response'
]
