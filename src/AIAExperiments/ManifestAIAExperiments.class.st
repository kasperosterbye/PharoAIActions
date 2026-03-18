"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestAIAExperiments',
	#superclass : 'PackageManifest',
	#category : 'AIAExperiments-Manifest',
	#package : 'AIAExperiments',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIAExperiments class >> ruleUncommonMessageSendRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#AIATeacup)) #'2026-03-15T17:18:16.138401+01:00') )
]
