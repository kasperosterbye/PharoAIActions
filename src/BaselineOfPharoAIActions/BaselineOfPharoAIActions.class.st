"
Killroy visited...
"
Class {
	#name : 'BaselineOfPharoAIActions',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoAIActions',
	#package : 'BaselineOfPharoAIActions'
}

{ #category : 'baselines' }
BaselineOfPharoAIActions >> baseline: spec [
  <baseline>
  spec for: #common do: [
		Transcript << 'baseline: called with ' << spec asString << String cr.
		spec package: 'AIActions'.
      spec package: 'AIActions-Tests' 
          with: [ spec requires: #('AIActions') ].
      spec package: 'AIAExperiments' 
          with: [ spec requires: #('AIActions') ].
      spec package: 'AIATestExperiments' 
          with: [ spec requires: #('AIActions') ].
      spec package: 'AIAZipArchive' 
          with: [ spec requires: #('AIActions') ].
		"default"
      spec group: 'default' with: #('AIActions' 'AIActions-Tests').
      spec group: 'extended' with: #('default' 'AIAExperiments' 'AIATestExperiments').
      spec group: 'all' with: #('default' 'extended' 'AIAZipArchive').
  ]
]

{ #category : 'script' }
BaselineOfPharoAIActions >> postLoad [
    "Called after packages are loaded"
	Transcript << 'Baseline postLoad called' << String CR.
	KMRepository reset.
	(Smalltalk at: #AIAProvidersPresenter ifAbsent: [ nil ]) 
		ifNotNil: [ :aiList | aiList open ].
	
]
