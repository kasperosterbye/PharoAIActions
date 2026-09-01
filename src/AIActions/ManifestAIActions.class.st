"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestAIActions',
	#superclass : 'PackageManifest',
	#category : 'AIActions-Manifest',
	#package : 'AIActions',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIActions class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#AIAHistoryFileStore #historyFromJson: #false)) #'2026-09-01T11:07:29.222431+02:00') #(#(#RGClassDefinition #(#AIAHistoryFileStore)) #'2026-09-01T11:07:42.113686+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#AIAHistoryFileStore)) #'2026-09-01T11:07:49.015643+02:00') )
]
