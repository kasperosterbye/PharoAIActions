"
## Purpose
If given the name of a Package, I will implement an overall comment for that package. I do this by gathering all classes and their methods, collect that into a huge text which is then given as the backgroung for asking AI what would be the right comments for the whole Package.

I am activated as AI_PackageComment comment: 'commentName'
"
Class {
	#name : 'AI_PackageComment',
	#superclass : 'AI_CommentBuilding',
	#instVars : [
		'packageSource'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'accessing - comment' }
AI_PackageComment class >> comment: commentName [
	^ self new comment: commentName 
]

{ #category : 'accessing' }
AI_PackageComment >> comment: aPackageName [
	| mistral  |
	packageSource := AI_PackagesAsOllamaSystem new for: { aPackageName }.
	prompt := 'This is a Pharo question. Can your give a package comment for ' , 
		aPackageName, '. It can be up to 2 pages. Please respond in markdown'.
	mistral := MistralApi new.
	mistral system: packageSource.
	response := mistral getResponseForPrompt: prompt.
	(Package named: aPackageName) packageComment: response 
]
