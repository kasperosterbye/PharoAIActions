"
# Notes for building this

- Method comments in black (default) and white (aiaWhiteComment og setWhiteComment)
- The class side need to be cleaned, and tested
- The human language need to be tested
- There need to be a list of examples - it seems like simply starting the method name with example on the class side does the trick.
- There is a trick error for method comments

1. √ There are comments for Package, Class and Method. And no others!
2. √ 'PackageName' aiaComment, ClassName aiaComment, (ClassName >> #method) aiaComment.
3. √ Same as above, but setAIAComment for all three.
4. – AIACommentBuilder aiaComment: 'PackageName' , ClassName , (ClassName >> #method) selects based on the type of the argument - clumsey idea. #2 was better...
5. √ Unify the tree getComment methods - it seems like they do nearly the same. Split it into system and prompt setter, and the call to AIApi looks very similar too.
6. √ Set the system such that AIACommentBuilder is the only class to be used. Well, it is not necessary now.

"
Class {
	#name : 'AIACommentBuilding',
	#superclass : 'AIABuilder',
	#instVars : [
		'aiaApi'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'as yet unclassified' }
AIACommentBuilding class >> aiCommentMarker [
	"The aiCommentMarker method returns the special character $¤ used to mark AI-generated comments in the system."
	^ $¤
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIClassComment [
	self aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIMethodComment [
	(EpLog >> #priorEntriesFrom:do:) aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIPackageComment [
	'Epicea' aiaComment inspect
]

{ #category : 'accessing' }
AIACommentBuilding >> getResponse [
	"Method initiates AI process to retrieve response displaying progress and handling interruptions. Uses system progress morph to show progress and allows interruption. Returns response from AI API."
	
	aiaApi getResponse
]

{ #category : 'initialization' }
AIACommentBuilding >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	aiaApi := AilienApi provider new.
]

{ #category : 'accessing' }
AIACommentBuilding >> response [
	"Returns the AI-generated response from the API, formatted as a string. Handles errors and ensures valid output. Uses the configured AI model for processing."

	^ aiaApi response
]

{ #category : 'accessing' }
AIACommentBuilding >> system [

	^ aiaApi system
]

{ #category : 'accessing' }
AIACommentBuilding >> system: anObject [

	aiaApi system: anObject
]

{ #category : 'accessing' }
AIACommentBuilding >> user [

	^ aiaApi user
]

{ #category : 'accessing' }
AIACommentBuilding >> user: anObject [

	aiaApi user: anObject
]
