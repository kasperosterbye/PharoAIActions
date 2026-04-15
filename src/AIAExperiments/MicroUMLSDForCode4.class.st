Class {
	#name : 'MicroUMLSDForCode4',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'contextList',
		'actions',
		'messages',
		'astBuilder',
		'lastMethod'
	],
	#category : 'AIAExperiments-MicroURLMisc',
	#package : 'AIAExperiments',
	#tag : 'MicroURLMisc'
}

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example1 [
	<example>
	self new forCode: [ Exp1 exp1Method1: 7. 2 timesRepeat: [ Exp2 new exp2Method1: 17]  ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example1_1 [
	<example>
	self new forCode: [ Exp1 exp1Method1: 3. Exp1 exp1Method1: 7. Exp2 new exp2Method1: 21   ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example2 [
	<example>
	self new forCode: [ Microdown asRichText: '## Joe' ] inPackage: 'Microdown'
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example3 [
	<example>
	self new forCode: [ AIASourceCode forClass: MicroUMLSDForCode  ] inPackage: 'AIActions'
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example4 [
	<example>
	self new forCode: [ Exp3 new exp3Method2 ] inPackage: 'AIActions'
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast10BuildMessageList [
	| messageCandidate |
	contextList doWithIndex: [ :context :index | 
		(self ast12CheckPackageContext: context )
			ifTrue: [ 
				messageCandidate := { context sender methodClass. context method methodClass . 
							 context method selector . context isReturn. {index. contextList }}  .
				(self ast15AddCheck: messageCandidate ) ifTrue: [ messages add: messageCandidate ]
				 ].
		 ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast12CheckPackageContext: context [
	| boolean |
	boolean :=
		    	(context sender methodClass package name ) = packageName or: [
				(context method methodClass package name ) = packageName ].
	^ boolean
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast15AddCheck: messageCandidate [ 
	messages reverseDo: [ :trac |
		(messageCandidate first: 3) = (trac first: 3)
			ifTrue: [ ^ messageCandidate fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast20ActionsFromMessages [
	| me |
	me := self class name.
	messages := messages select: [ :m | m first name ~= me and: [ m second name ~= me ] ].
	messages do: [ :message |
		message first package name = packageName  ifTrue: [ 
			actions at: message first name asString put: message first ].
		message second package name = packageName ifTrue: [ 
			actions at: message second name asString put: message second ] ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast40Build [

	astBuilder := MicroUMLSDAstBuilder new. 
	self ast43BuildActors.
	self ast46BuildMessages.
	MicroUMLSequenceDiagram from: astBuilder .
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast43BuildActors [
	astBuilder , 'O'.
	actions do: [ :actorClass | 
		astBuilder , actorClass name asString ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast46BuildMessages [

	| firstPackage secondPackage |
	messages do: [ :message |
			firstPackage := message first package name.
			secondPackage := message second package name.
			(firstPackage ~= packageName or: [ secondPackage ~= packageName ])
				ifTrue: [ self ast47BuildPackageMessage: message ]
				ifFalse: [ self ast48BuildExternalMessage: message ] ]
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast47BuildPackageMessage: message [
	| ignoreList|
	ignoreList := { 'new'. 'new:' } asSet.
	message first package name ~= packageName 
		ifTrue: [ 
			message fourth
					ifFalse: [ astBuilder & 'O' -> message second name => message third. ]
					ifTrue: [ astBuilder & message second name -> 'O' --> message third ]]
		ifFalse: [ 
			(ignoreList includes: message third) ifFalse: [
				message fourth ifFalse: [
					astBuilder lastMethod: message fifth.
					astBuilder & message first name => ('Ø ', message third)] ]]

]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast48BuildExternalMessage: message [
	message first = message second
		ifTrue: [
				message fourth
					ifFalse: [ astBuilder & message first name => message third ]
					ifTrue: [ astBuilder & message first name --> message third ] ]
		ifFalse: [
				message fourth
					ifFalse: [ astBuilder & message first name -> message second name => message third ]
					ifTrue: [ astBuilder & message second name -> message first name --> message third ] ].
]

{ #category : 'external' }
MicroUMLSDForCode4 >> forCode: aBlock inPackage: pName [
	packageName := pName.
	thisContext runSimulated: aBlock  contextAtEachStep: [ :context |
			contextList add: context copy.
			].
	self ast10BuildMessageList.
	self ast20ActionsFromMessages.
	self ast40Build.
]

{ #category : 'external' }
MicroUMLSDForCode4 >> forContext: aContextList inPackage: pName [
    packageName := pName.
    contextList := aContextList.
    self ast10BuildMessageList.
    self ast20ActionsFromMessages.
    self ast40Build.
]

{ #category : 'initialization' }
MicroUMLSDForCode4 >> initialize [ 
	contextList := OrderedCollection new.
	actions := OrderedDictionary new.
	messages := OrderedCollection new.
]
