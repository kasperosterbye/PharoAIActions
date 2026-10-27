Class {
	#name : 'AIAFullLLMTesterTest',
	#superclass : 'TestCase',
	#instVars : [
		'savedResults'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'adding' }
AIAFullLLMTesterTest class >> simulateFailure [
	"Simulate a test that raises an error."

	| newInstance |
	newInstance := self new.

	100 milliSeconds wait.
	newInstance error: 'Simulated test failure'
]

{ #category : 'as yet unclassified' }
AIAFullLLMTesterTest class >> simulateModel: aProvider model: aModel [
    "Verify that the workload receives the expected provider and model."

    (aProvider = #ProviderA and: [ aModel = 'model1' ])
        ifFalse: [ self error: 'Incorrect provider or model' ]
]

{ #category : 'adding' }
AIAFullLLMTesterTest class >> simulateSlow [
    "Simulate a long-running test that can be interrupted."

    5 seconds wait
]

{ #category : 'adding' }
AIAFullLLMTesterTest class >> simulateSuccess [
    "Simulate a successful test."

    100 milliSeconds wait
]

{ #category : 'running' }
AIAFullLLMTesterTest >> setUp [
    "Preserve existing experiment results before testing."

    super setUp.
    savedResults := AIAFullLLMTester testResults.
    AIAFullLLMTester initialize
]

{ #category : 'running' }
AIAFullLLMTesterTest >> tearDown [
    "Restore experiment results after testing."

    AIAFullLLMTester testResults: savedResults.
    super tearDown
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testCancellation [
    "Verify that cancellation stops the current 
		workload and preserves completed results."

    | process results |

    process := AIAFullLLMTester
        runTests: #(simulateSuccess simulateSlow simulateSuccess)
        on: self class.

    500 milliSeconds wait.

    AIAFullLLMTester stop.
    self waitFor: process.

    results := AIAFullLLMTester testResults last.

    self assert: results size equals: 1.
    self assert: (results first at: #test) equals: #simulateSuccess.
    self assert: (results first at: #status) equals: #passed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testCompletedTestsAreRepeated [
    "Verify that repeated executions run again and retain both results."

    | process runs |

    process := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class.
    self waitFor: process.

    process := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class.
    self waitFor: process.

    runs := AIAFullLLMTester testResults.

    self assert: runs size equals: 2.
    self assert: runs first size equals: 1.
    self assert: runs second size equals: 1.

    self assert: (runs first first at: #status) equals: #passed.
    self assert: (runs second first at: #status) equals: #passed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testDifferentModelsAreTested [
    "Verify that a successful test for one model does not skip another model."

    | runner results |

    runner := AIAFullLLMTester.

    runner startNewRun.
    runner addTestResult: (Dictionary new
        at: #test put: #simulateSuccess;
        at: #provider put: OpenAIApi;
        at: #model put: 'model-A';
        at: #status put: #passed;
        yourself).

    results := runner hasPassed: #simulateSuccess
        provider: OpenAIApi
        model: 'model-B'.

    self deny: results.

    self assert: (runner
        hasPassed: #simulateSuccess
        provider: OpenAIApi
        model: 'model-A')
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testFailedExecution [
    "Verify that failures are recorded and subsequent tests continue."

    | process results |

    process := AIAFullLLMTester
        runTests: #(simulateFailure simulateSuccess)
        on: self class.

    self waitFor: process.

    results := AIAFullLLMTester testResults last.

    self assert: results size equals: 2.

    self assert: (results first at: #test) equals: #simulateFailure.
    self assert: (results first at: #status) equals: #failed.
    self assert: ((results first at: #details)
        includesSubstring: 'Simulated test failure').

    self assert: (results second at: #test) equals: #simulateSuccess.
    self assert: (results second at: #status) equals: #passed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testFailedTestsAreRetried [
    "Verify that failed tests are retried and previous results retained."

    | process runs |

    process := AIAFullLLMTester
        runTests: #(simulateFailure)
        on: self class.
    self waitFor: process.

    process := AIAFullLLMTester
        runTests: #(simulateFailure)
        on: self class.
    self waitFor: process.

    runs := AIAFullLLMTester testResults.

    self assert: runs size equals: 2.
    self assert: runs first size equals: 1.
    self assert: runs second size equals: 1.

    self assert: (runs first first at: #test)
        equals: #simulateFailure.
    self assert: (runs first first at: #status)
        equals: #failed.

    self assert: (runs second first at: #test)
        equals: #simulateFailure.
    self assert: (runs second first at: #status)
        equals: #failed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testModelSpecificExecution [
    "Verify that repeated model executions produce separate results."

    | process runs |

    #('model-A' 'model-B' 'model-A') do: [ :model |
        process := AIAFullLLMTester
            runTests: #(simulateSuccess)
            on: self class
            provider: OpenAIApi
            model: model.
        self waitFor: process ].

    runs := AIAFullLLMTester testResults.

    self assert: runs size equals: 3.
    self assert: (runs allSatisfy: [ :run | run size = 1 ]).

    self assert: (runs first first at: #model) equals: 'model-A'.
    self assert: (runs second first at: #model) equals: 'model-B'.
    self assert: (runs third first at: #model) equals: 'model-A'
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testMultipleModelsInSingleRun [
    "Verify that multiple models execute within one run,
    with separate results for each model."

    | process runs results models |

    models := {
        { #ProviderA. #('model1' 'model2') }
    }.

    process := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class
        providersAndModels: models.

    self waitFor: process.

    runs := AIAFullLLMTester testResults.

    self assert: runs size equals: 1.

    results := runs first.
    self assert: results size equals: 2.

    self assert: (results collect: [ :each |
        each at: #model ])
        asArray equals: #('model1' 'model2').

    self assert: (results allSatisfy: [ :each |
        (each at: #status) = #passed ]).

    self assert: (results allSatisfy: [ :each |
        (each at: #provider) = #ProviderA ])
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testMultipleRuns [
    "Verify that successive experiments preserve separate result collections."

    | firstProcess secondProcess runs |

    firstProcess := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class.

    self waitFor: firstProcess.

    secondProcess := AIAFullLLMTester
        runTests: #(simulateFailure)
        on: self class.

    self waitFor: secondProcess.

    runs := AIAFullLLMTester testResults.

    self assert: runs size equals: 2.
    self assert: (runs first first at: #status) equals: #passed.
    self assert: (runs second first at: #status) equals: #failed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testResultsAreGroupedByRun [
    "Verify that separate runs retain their own results."

    AIAFullLLMTester startNewRun.
    AIAFullLLMTester addTestResult: 'Foo completed'.

    AIAFullLLMTester startNewRun.
    AIAFullLLMTester addTestResult: 'Bar completed'.

    self assert: AIAFullLLMTester testResults size equals: 2.
    self
        assert: AIAFullLLMTester testResults first asArray
        equals: #('Foo completed').
    self
        assert: AIAFullLLMTester testResults second asArray
        equals: #('Bar completed')
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSelectAllProvidersAndModels [
    "Verify that empty filters preserve all available providers and models."

    | available selected |

    available := {
        { #ProviderA. #('model1' 'model2') }.
        { #ProviderB. #('model3' 'model4') }
    }.

    selected := AIAFullLLMTester
        selectProvidersAndModels: available
        providers: #()
        models: #().

    self assert: selected equals: available
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSelectModelsAcrossProviders [
    "Verify that model filtering works across providers and excludes nonmatching providers."

    | available selected |

    available := {
        { #ProviderA. #('model1' 'model2') }.
        { #ProviderB. #('model2' 'model3') }.
        { #ProviderC. #('model4') }
    }.

    selected := AIAFullLLMTester
        selectProvidersAndModels: available
        providers: #()
        models: #('model2').

    self assert: selected equals: {
        { #ProviderA. #('model2') }.
        { #ProviderB. #('model2') }
    }
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSelectProvidersAndModels [
    "Verify that provider and model filtering work independently."

    | available selected |

    available := {
        { #ProviderA. #('model1' 'model2') }.
        { #ProviderB. #('model3' 'model4') }
    }.

    selected := AIAFullLLMTester
        selectProvidersAndModels: available
        providers: #(ProviderA)
        models: #('model2').

    self assert: selected equals: {
        { #ProviderA. #('model2') }
    }
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSelectedProvidersAndModels [
    "Verify that model selection returns the available providers and models."

    | selected available |
    selected := AIAFullLLMTester selectedProvidersAndModels.
    available := AilienApi providerAndModels.

    self assert: selected equals: available
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSelectedProvidersDelegatesCorrectly [
    "Verify that unfiltered selection matches the available providers and models."

    | expected actual |

    expected := AilienApi providerAndModels.

    actual := AIAFullLLMTester
        selectedProviders: #()
        models: #().

    self assert: actual equals: expected.
    self assert: AIAFullLLMTester selectedProvidersAndModels
        equals: expected
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSuccessfulExecution [
    "Verify that a successful workload produces a structured result."

    | process result |

    process := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class.

    self waitFor: process.

    self assert: AIAFullLLMTester testResults size equals: 1.

    result := AIAFullLLMTester testResults last first.

    self assert: (result at: #test) equals: #simulateSuccess.
    self assert: (result at: #status) equals: #passed.
    self assert: (result at: #duration) >= 0.
    self assert: (result at: #details) equals: ''
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testWorkloadReceivesProviderAndModel [
    "Verify that the runner supplies provider and model to a workload."

    | process results |

    process := AIAFullLLMTester
        runTests: #(simulateModel:model:)
        on: self class
        providersAndModels: {
            { #ProviderA. #('model1') } }.

    self waitFor: process.

    results := AIAFullLLMTester testResults last.

    self assert: results size equals: 1.
    self assert: (results first at: #status) equals: #passed
]

{ #category : 'helpers' }
AIAFullLLMTesterTest >> waitFor: aProcess [
    "Wait for a background process to terminate, with a safety timeout."

    | deadline |

    deadline := DateAndTime now + 10 seconds.

    [ aProcess isTerminated or: [
        DateAndTime now >= deadline ] ] whileFalse: [
            10 milliSeconds wait ].

    self assert: aProcess isTerminated
        description: 'Experiment did not finish within ten seconds'
]
