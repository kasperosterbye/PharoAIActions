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
ManifestAIAExperiments class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIAExperiments)) #'2026-04-01T09:44:31.940142+02:00') )
]

{ #category : 'code-critics' }
ManifestAIAExperiments class >> ruleStringConcatenationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIAExperiments)) #'2026-04-01T09:44:17.15332+02:00') )
]
