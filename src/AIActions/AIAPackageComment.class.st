"
## Purpose
If given the name of a Package, I will implement an overall comment for that package. I do this by gathering all classes and their methods, collect that into a huge text which is then given as the backgroung for asking AI what would be the right comments for the whole Package.

I am activated as AI_PackageComment comment: 'commentName'
"
Class {
	#name : 'AIAPackageComment',
	#superclass : 'AIACommentBuilding',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIAPackageComment >> aiaComment: aPackageName [
	"The method aiaComment: generates a package comment for a given package name using AI. It checks if the package is a test package and adjusts the source code accordingly."

	(aPackageName endsWith: '-Tests')
		ifFalse: [
				self system: (AIASourceCodeBuilder new for: {
							 aPackageName.
							 (aPackageName , '-Tests') }) ]
		ifTrue: [ self system: (AIASourceCodeBuilder new for: { aPackageName }) ].
	self
		user: 'This is a Pharo question. Can your give a package comment for ' , aPackageName;
		user: '. It can be up to 1 page. Please respond in markdown. Please response in ' , 
			AIACommentBuilding language.
	self getResponse
]

{ #category : 'accessing' }
AIAPackageComment >> aiaCommentMany: aPackageNames [
	"The method sets a package comment using Mistral API."
	self system:  (AIASourceCodeBuilder new for: aPackageNames).
	self user: 'This is a Pharo question. 
		Please write a single package comment that covers the
		purpose and relationship between the following packages: {#' ,
		('. #' join: aPackageNames), 
		'}. Start with the most package without experiements and without tests. 
		Keep the response within two pages. Please use markdown format and respond in ', 
	AIACommentBuilding language.
	self getResponse.
	^ self
]

{ #category : 'accessing' }
AIAPackageComment >> setComment: aPackageName [
	"Sets a package comment using AI-generated content and updates the package's metadata."
	self aiaComment: aPackageName.
	(Package named: aPackageName) packageComment: self response 
]
