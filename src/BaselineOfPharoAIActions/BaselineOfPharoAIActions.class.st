Class {
	#name : 'BaselineOfPharoAIActions',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoAIActions',
	#package : 'BaselineOfPharoAIActions'
}

{ #category : 'baselines' }
BaselineOfPharoAIActions class >> baseline: spec [
  <baseline>
  spec
    for: #common
    do: [
      spec
        package: 'AIActions' with: [ spec requires: #() ].
      spec
        package: 'AIAgent-Tests' with: [ spec requires: #('AIActions') ].
      spec
        package: 'AIActionsExperiments' with: [ spec requires: #('AIActions') ].

      spec group: 'default' with: #('AIActions').
      spec group: 'tests' with: #('AIAgent-Tests').
      spec group: 'withExperiments' with: #('AIActions' 'AIActionsExperiments')
    ]
]

{ #category : 'baselines' }
BaselineOfPharoAIActions class >> baseline_old: spec [
  <baseline>
  spec
    for: #common
    do: [
      spec
        repository: 'github://kasperosterbye/PharoAIActions:main/src';
        load: 'default'.

      spec
        package: 'AIActions' with: [ spec requires: #() ].
      spec
        package: 'AIAgent-Tests' with: [ spec requires: #('AIActions') ].
      spec
        package: 'AIActionsExperiments' with: [ spec requires: #('AIActions') ].

      spec
        group: 'default' with: #('AIActions').
      spec
        group: 'tests' with: #('AIAgent-Tests').
      spec
        group: 'withExperiments' with: #('AIActions' 'AIActionsExperiments')
    ].
]
