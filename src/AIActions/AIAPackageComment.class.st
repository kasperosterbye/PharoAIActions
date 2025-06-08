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
	"The method sets a package comment using Mistral API."
	self system:  (AIASourceCodeBuilder new for: { aPackageName }).
	self prompt: 'This is a Pharo question. Can your give a package comment for ' , 
		aPackageName, '. It can be up to 1 page. Please respond in markdown. Please response in ',
		AIACommentBuilding language.
	self getResponse.
	^ self.
]

{ #category : 'accessing' }
AIAPackageComment >> setComment: aPackageName [
	self aiaComment: aPackageName.
	(Package named: aPackageName) packageComment: self response 
]
