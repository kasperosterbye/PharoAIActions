Class {
	#name : 'AIAModelAvailabilityExperiment',
	#superclass : 'Object',
	#instVars : [
		'results',
		'runDirectory',
		'startedAt',
		'finishedAt'
	],
	#classVars : [
		'LastInstance'
	],
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'accessing' }
AIAModelAvailabilityExperiment class >> lastInstance [
    ^ LastInstance

]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment class >> run [
    ^ self new run
]

{ #category : 'run-directory creation' }
AIAModelAvailabilityExperiment >> createRunDirectory [
    | stamp |
    stamp := DateAndTime now asString
        copyReplaceAll: ':' with: '-'.

    runDirectory := self rootDirectory / ('run-', stamp).
    runDirectory ensureCreateDirectory
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> finishedAt [

	^ finishedAt
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> finishedAt: anObject [

	finishedAt := anObject
]

{ #category : 'initialization' }
AIAModelAvailabilityExperiment >> initialize [
    super initialize.
    results := OrderedCollection new.
    startedAt := DateAndTime now.
    LastInstance := self
]

{ #category : 'configuration' }
AIAModelAvailabilityExperiment >> prompt [
    ^ 'Is 7 a number or a character? Answer with one word.'

]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> results [

	^ results
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> results: anObject [

	results := anObject
]

{ #category : 'configuration' }
AIAModelAvailabilityExperiment >> rootDirectory [
    ^ AIAHistoryFileStore new rootDirectory
        / 'Model-availability-issue-23'
]

{ #category : 'run-directory creation' }
AIAModelAvailabilityExperiment >> run [
    self createRunDirectory.

    AilienApi providerAndModels do: [ :providerAndModels |
        | provider |
        provider := providerAndModels first.

        providerAndModels second do: [ :model |
            self runProvider: provider model: model ] ].

    finishedAt := DateAndTime now.
    ^ results
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> runDirectory [

	^ runDirectory
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> runDirectory: anObject [

	runDirectory := anObject
]

{ #category : 'run-directory creation' }
AIAModelAvailabilityExperiment >> runProvider: provider model: modelName [
    | api history |

    api := provider new.
    api
        model: modelName;
        responseWaitingInSecs: self timeout.

    history := AIAHistory new.
    history fileStore rootDirectory: runDirectory.
    history
        api: api;
        title: 'Availability - ',
            provider name asString, ' - ', modelName.

    [
        history
            user: self prompt;
            getResponse
    ]
    on: Error
    do: [ :error |
        | text |
        text := error class name asString.
        error messageText ifNotEmpty: [
            text := text, ': ', error messageText ].

        history comment: 'EXCEPTION: ', text
    ].

    results add: history.
    ^ history
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> startedAt [

	^ startedAt
]

{ #category : 'accessing' }
AIAModelAvailabilityExperiment >> startedAt: anObject [

	startedAt := anObject
]

{ #category : 'classification' }
AIAModelAvailabilityExperiment >> statusForResponse: answer [
    answer ifNil: [ ^ #empty ].
    answer trimBoth ifEmpty: [ ^ #empty ].
    (answer beginsWith: 'API Error:')
        ifTrue: [ ^ #apiError ].
    ^ #ok
]

{ #category : 'configuration' }
AIAModelAvailabilityExperiment >> timeout [
    ^ 60

]
