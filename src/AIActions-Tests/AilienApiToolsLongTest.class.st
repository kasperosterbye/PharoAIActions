Class {
	#name : 'AilienApiToolsLongTest',
	#superclass : 'AilienApiToolsTest',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'tests' }
AilienApiToolsLongTest >> testWebReaderTimeout [
    "Verify that Lynx reports an error when a server delays its response."

    | reader result |

    reader := ApiToolWebReader new.
    reader returnRaw: false.
    reader timeoutSeconds: 5.

    result := reader executeTool:
        { 'website' -> {
            'https://maarumlam.dk/kasper/wait10sec.php'
        } } asDictionary.

    self assert: (result includesSubstring: 'ERROR accessing').
    self deny: (result includesSubstring: 'Response after 10 seconds')
]
