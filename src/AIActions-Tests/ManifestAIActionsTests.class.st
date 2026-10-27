"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestAIActionsTests',
	#superclass : 'PackageManifest',
	#category : 'AIActions-Tests-Manifest',
	#package : 'AIActions-Tests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIActionsTests class >> ruleBadMessageRule2V1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#'AIAFullLLMTester class' #runTests:on: #true)) #'2026-10-22T14:31:37.054793+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActionsTests class >> ruleTempVarOverridesInstVarRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'AIActions-Tests')) #'2026-10-27T09:06:17.852845+01:00') )
]
