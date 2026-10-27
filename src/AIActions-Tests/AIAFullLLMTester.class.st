Class {
	#name : 'AIAFullLLMTester',
	#superclass : 'Object',
	#classVars : [
		'CurrentJob',
		'TestResults'
	],
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'adding' }
AIAFullLLMTester class >> addTestResult: aResult [
    "Record a result in the current run and report it."

    self testResults isEmpty ifTrue: [
        self error: 'No test run has been started' ].

    self testResults last add: aResult.
    Transcript
        show: aResult printString;
        cr
]

{ #category : 'testing' }
AIAFullLLMTester class >> hasPassed: aSelector [
    "Answer whether this test passed in an earlier run."

    ^ self testResults anySatisfy: [ :run |
        run anySatisfy: [ :result |
            (result at: #test) = aSelector
                and: [ (result at: #status) = #passed ] ] ]
]

{ #category : 'testing' }
AIAFullLLMTester class >> hasPassed: aSelector provider: aProvider model: aModel [
    "Answer whether this test passed for the specified provider and model."

    ^ self testResults anySatisfy: [ :run |
        run anySatisfy: [ :result |
            (result at: #test) = aSelector
                and: [
                    (result at: #provider ifAbsent: [ nil ]) = aProvider
                        and: [
                            (result at: #model ifAbsent: [ nil ]) = aModel
                                and: [
                                    (result at: #status) = #passed ] ] ] ] ]
]

{ #category : 'adding' }
AIAFullLLMTester class >> initialize [
    "Clear all recorded test runs."

    TestResults := OrderedCollection new
]

{ #category : 'adding' }
AIAFullLLMTester class >> resetTestResults [
    "Clear all recorded test runs."

    TestResults := OrderedCollection new
]

{ #category : 'tests' }
AIAFullLLMTester class >> run [
    <example>
    "Execute the configured LLM experiments."

    ^ self
        runTests: self testSelectors
        on: self
]

{ #category : 'run-directory creation' }
AIAFullLLMTester class >> runAllProviders [
    "Run the tool-capability test for all available providers and models."

    ^ self
        runTests: #(testClassInfo:model:)
        on: AIAFullLLMTesterLiveTest
        providersAndModels: self selectedProvidersAndModels
]

{ #category : 'run-directory creation' }
AIAFullLLMTester class >> runProvider: aProvider [
    "Run the tool-capability test for every model of one provider."

    ^ self
        runTests: #(testClassInfo:model:)
        on: AIAFullLLMTesterLiveTest
        providersAndModels: (self
            selectedProviders: { aProvider }
            models: #())
]

{ #category : 'run-directory creation' }
AIAFullLLMTester class >> runProvider: aProvider model: aModel [
    "Run the tool-capability test for one provider and model."

    ^ self
        runTests: #(testClassInfo:model:)
        on: AIAFullLLMTesterLiveTest
        providersAndModels: {
            { aProvider. { aModel } } }
]

{ #category : 'tests' }
AIAFullLLMTester class >> runTests: selectors on: aTestClass [
    "Execute tests without a specific LLM provider or model."

    ^ self
        runTests: selectors
        on: aTestClass
        provider: nil
        model: nil
]

{ #category : 'testing' }
AIAFullLLMTester class >> runTests: selectors on: aTestClass provider: aProvider model: aModel [
    "Execute tests for one provider and model, retaining all results."

    ^ self
        runTests: selectors
        on: aTestClass
        providersAndModels: {
            { aProvider. { aModel } } }
]

{ #category : 'as yet unclassified' }
AIAFullLLMTester class >> runTests: selectors on: aTestClass providersAndModels: providersAndModels [
    "Execute all requested workloads in one cancellable Job,
    recording every result without skipping previous successes."

    | job combinations |

    combinations := OrderedCollection new.

    providersAndModels do: [ :entry |
        entry second do: [ :model |
            selectors do: [ :selector |
                combinations add: { selector. entry first. model } ] ] ].

    self startNewRun.

    job := [ :j |
        j interruptBlock: [
            Transcript show: 'Experiment stopped'; cr.
            j terminate ].

        [
            combinations withIndexDo: [ :each :index |
                | selector provider model started status details duration |

                selector := each first.
                provider := each second.
                model := each third.

                j
                    progress: index / combinations size
                    title: 'Running ', selector asString,
                        ' - ', provider asString,
                        ' - ', model asString.

                started := DateAndTime now.
                status := #passed.
                details := ''.

                [
                    selector numArgs = 2
                        ifTrue: [
                            aTestClass
                                perform: selector
                                with: provider
                                with: model ]
                        ifFalse: [
                            aTestClass perform: selector ]
                ]
                    on: Error
                    do: [ :error |
                        status := #failed.
                        details := error printString ].

                duration := (DateAndTime now - started)
                    asMilliSeconds / 1000.0.

                self addTestResult: (Dictionary new
                    at: #test put: selector;
                    at: #provider put: provider;
                    at: #model put: model;
                    at: #status put: status;
                    at: #duration put: duration;
                    at: #timestamp put: DateAndTime now;
                    at: #details put: details;
                    yourself)
            ]
         ] ensure: [
            CurrentJob == j ifTrue: [
                CurrentJob := nil ].
            self testResults last inspect ]
    ] asJob.

    CurrentJob := job.

    ^ [ job run ] forkAt: Processor userBackgroundPriority
]

{ #category : 'as yet unclassified' }
AIAFullLLMTester class >> selectProvidersAndModels: available providers: providers models: models [
    "Select provider/model combinations. Empty filters mean all."

    ^ (available collect: [ :entry |
        | provider selectedModels |

        provider := entry first.
        selectedModels := entry second.

        (providers isEmpty or: [ providers includes: provider ])
            ifTrue: [
                selectedModels := selectedModels select: [ :model |
                    models isEmpty or: [ models includes: model ] ].
                { provider. selectedModels } ]
            ifFalse: [ nil ]
    ]) reject: [ :entry |
        entry isNil or: [ entry second isEmpty ] ]
]

{ #category : 'as yet unclassified' }
AIAFullLLMTester class >> selectedProviders: providers models: models [
    "Answer available provider/model combinations matching the filters."

    ^ self
        selectProvidersAndModels: AilienApi providerAndModels
        providers: providers
        models: models
]

{ #category : 'as yet unclassified' }
AIAFullLLMTester class >> selectedProvidersAndModels [
    "Answer all available provider/model combinations."

    ^ self
        selectedProviders: #()
        models: #()
]

{ #category : 'as yet unclassified' }
AIAFullLLMTester class >> simulateModel: aProvider model: aModel [
    "Verify that a workload receives its provider and model."

    self assert: aProvider equals: #ProviderA.
    self assert: aModel equals: 'model1'
]

{ #category : 'adding' }
AIAFullLLMTester class >> startNewRun [
    "Create a new collection for the results of this run."

    self testResults add: CheckCollection new
]

{ #category : 'accessing' }
AIAFullLLMTester class >> stop [
    "Interrupt the currently running experiment."

    CurrentJob ifNotNil: [ :job |
        job interrupt ]
]

{ #category : 'adding' }
AIAFullLLMTester class >> testResults [
    "Answer the results of all test runs."

    ^ TestResults ifNil: [
        TestResults := OrderedCollection new ]
]

{ #category : 'tests' }
AIAFullLLMTester class >> testResults: aCollection [
    "Replace the current experiment results collection."

    TestResults := aCollection
]

{ #category : 'tests' }
AIAFullLLMTester class >> testSelectors [
    "Answer the tests to execute, in execution order."
    ^ #()
]
