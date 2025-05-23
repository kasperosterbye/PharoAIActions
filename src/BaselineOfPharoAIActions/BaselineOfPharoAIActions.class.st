Class {
	#name : 'BaselineOfPharoAIActions',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoAIActions',
	#package : 'BaselineOfPharoAIActions'
}

{ #category : 'baselines' }
BaselineOfPharoAIActions >> baseline: spec [
  <baseline>
  spec
    for: #common
    do: [
      spec package: 'AIActions'.
      spec
        	package: 'AIAgent-Tests' 
			with: [ spec requires: #('AIActions') ].
      spec
			package: 'AIActionExperiments' 
			with: [ spec requires: #('AIActions') ].
    ]
]
