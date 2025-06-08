Class {
	#name : 'AIAPackageCommentTest',
	#superclass : 'TestCase',
	#instVars : [
		'packageCommenter'
	],
	#category : 'AIAgent-Tests-CommentBuilder-Tests',
	#package : 'AIAgent-Tests',
	#tag : 'CommentBuilder-Tests'
}

{ #category : 'running' }
AIAPackageCommentTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	packageCommenter := AIAPackageComment new.
]

{ #category : 'tests' }
AIAPackageCommentTest >> testAiaComment [
	packageCommenter := AIAPackageComment new aiaComment: 'AIAgent-Tests' .
	self assert: (packageCommenter response includesSubstring: '# Package: AIAgent-Tests').
	self assert: (packageCommenter response includesSubstring: '## Overview')
]

{ #category : 'tests' }
AIAPackageCommentTest >> testSetComment [
	(Package named: 'AIAgent-Tests') packageComment:  'Comment inserted for testing'.
	self assert:(  (PackageOrganizer default packageNamed: 'AIAgent-Tests') 
			packageComment includesSubstring: 'ent ins').
]
