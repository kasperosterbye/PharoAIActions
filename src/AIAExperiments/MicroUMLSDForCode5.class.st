Class {
	#name : 'MicroUMLSDForCode5',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'contextList',
		'actions',
		'messages',
		'astBuilder',
		'lastMethod'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSDForCode5 class >> example1 [
	<example>
	self new forCode: [ Exp1 exp1Method1: 7. 2 timesRepeat: [ Exp2 new exp2Method1: 17]  ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode5 class >> example1_1 [
	<example>
	self new forCode: [ Exp1 exp1Method1: 3. Exp1 exp1Method1: 7. Exp2 new exp2Method1: 21   ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode5 class >> example2 [
	<example>
	self new forCode: [ Microdown asRichText: '## Joe' ] inPackage: 'Microdown'
]

{ #category : 'examples' }
MicroUMLSDForCode5 class >> example3 [
	<example>
	self new forCode: [ AIASourceCode forClass: MicroUMLSDForCode  ] inPackage: 'AIActions'
]

{ #category : 'examples' }
MicroUMLSDForCode5 class >> example4 [
	<example>
	self new forCode: [ Exp3 new exp3Method2 ] inPackage: 'AIActions'
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast10BuildMessageList [
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
MicroUMLSDForCode5 >> ast12CheckPackageContext: context [
	| boolean |
	boolean :=
		(self classNameCheck: context sender methodClass ) or: [
		self classNameCheck: context method methodClass  ].
	^ boolean
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast15AddCheck: messageCandidate [ 
	messages reverseDo: [ :trac |
		(messageCandidate first: 3) = (trac first: 3)
			ifTrue: [ ^ messageCandidate fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast20ActionsFromMessages [
	| me |
	me := self class name.
	messages := messages select: [ :m | m first name ~= me and: [ m second name ~= me ] ].
	messages do: [ :message |
		(self classNameCheck: message first)  ifTrue: [ 
			actions at: message first name asString put: message first ].
		(self classNameCheck: message second) ifTrue: [ 
			actions at: message second name asString put: message second ] ].
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast40Build [
	| sd |
	astBuilder := MicroUMLSDAstBuilder new. 
	self ast43BuildActors.
	self ast46BuildMessages.
	sd := MicroUMLSequenceDiagram from: astBuilder.
	sd uiTitle: 'Package: ', packageName.
	sd build
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast43BuildActors [
	astBuilder , 'O' .
	actions do: [ :actorClass | 
		astBuilder , actorClass name asString @ [ AIAPresenter onComment: actorClass comment]].
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast46BuildMessages [
    messages do: [ :message |
		  ((self classNameCheck: message first) and: [ self classNameCheck: message second ])
            ifTrue: [ self ast48BuildExternalMessage: message ]
            ifFalse: [ self ast47BuildPackageMessage: message ] ]
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast47BuildPackageMessage: message [
	| ignoreList|
	ignoreList := { 'new'. 'new:' } asSet.
	(self classNameCheck: message first)
		ifTrue: [ 
			(ignoreList includes: message third) ifFalse: [
				message fourth ifFalse: [
					astBuilder lastMethod: message fifth.
					astBuilder & message first name => message third 
						@ [ self umlSPFor: message ]] ]]
		ifFalse: [ 
			message fourth
					ifFalse: [ astBuilder & 'O' -> message second name => message third. ]
					ifTrue: [ astBuilder & message second name -> 'O' --> message third ]]
		

]

{ #category : 'internals' }
MicroUMLSDForCode5 >> ast48BuildExternalMessage: message [
	message first = message second
		ifTrue: [
				message fourth
					ifFalse: [ astBuilder & message first name => message third ] ]
		ifFalse: [
				message fourth
					ifFalse: [ astBuilder & message first name -> message second name => message third ]
					ifTrue: [ astBuilder & message second name -> message first name --> message third ] ].
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> classNameCheck: aClass [
	packageName ifEmpty: [ ^ true ].
	^ aClass package name  = packageName
	
]

{ #category : 'external' }
MicroUMLSDForCode5 >> forCode: aBlock inPackage: pName [
	packageName := pName.
	thisContext runSimulated: aBlock  contextAtEachStep: [ :context |
			contextList add: context copy.
			].
	self ast10BuildMessageList.
	self ast20ActionsFromMessages.
	self ast40Build.
]

{ #category : 'external' }
MicroUMLSDForCode5 >> forContext: aContextList inPackage: pName [
    packageName := pName.
    contextList := aContextList.
    self ast10BuildMessageList.
    self ast20ActionsFromMessages.
    self ast40Build.
]

{ #category : 'initialization' }
MicroUMLSDForCode5 >> initialize [ 
	contextList := OrderedCollection new.
	actions := OrderedDictionary new.
	messages := OrderedCollection new.
]

{ #category : 'internals' }
MicroUMLSDForCode5 >> old_ast47BuildPackageMessage: message [
	| ignoreList|
	ignoreList := { 'new'. 'new:' } asSet.
	(self classNameCheck: message first)
		ifTrue: [ 
			(ignoreList includes: message third) ifFalse: [
				message fourth ifFalse: [
					astBuilder lastMethod: message fifth.
					astBuilder & message first name => message third 
						@ [ | idx cList subList |
    idx := message fifth first.
    cList := message fifth second.
    subList := cList copyFrom: idx to: cList size.
    MicroUMLSDForCode5 new 
        forContext: subList 
        inPackage: message second package name ]] ]]
		ifFalse: [ 
			message fourth
					ifFalse: [ astBuilder & 'O' -> message second name => message third. ]
					ifTrue: [ astBuilder & message second name -> 'O' --> message third ]]
		

]

{ #category : 'inline' }
MicroUMLSDForCode5 >> umlSPFor: message [ 
| idx cList subList |
    idx := message fifth first.
    cList := message fifth second.
    subList := cList copyFrom: idx to: cList size.
    self class new 
        forContext: subList 
        inPackage: message second package name 
]
