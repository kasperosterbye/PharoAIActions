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
        	package: 'AIActions-Tests' 
			with: [ spec requires: #('AIActions') ].
      "spec
			package: 'AIAExperiments' 
			with: [ spec requires: #('AIActions') ]."
		spec
			package: 'AIATestExperiments' 
			with: [ spec requires: #('AIActions') ].
    ]
]
