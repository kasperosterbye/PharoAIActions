Class {
	#name : 'ManifestAIActions',
	#superclass : 'PackageManifest',
	#category : 'AIActions-Manifest',
	#package : 'AIActions',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIActions class >> ruleReGuardClauseRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#AIATestGenerator)) #'2025-07-23T12:54:26.010851+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleSelfSentNotImplementedRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#String #c #false)) #'2025-07-23T09:27:53.369678+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleUnclassifiedMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-07-21T10:30:28.236326+02:00') )
]
