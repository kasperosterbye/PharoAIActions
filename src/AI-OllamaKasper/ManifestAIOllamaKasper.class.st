"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestAIOllamaKasper',
	#superclass : 'PackageManifest',
	#category : 'AI-OllamaKasper-Manifest',
	#package : 'AI-OllamaKasper',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIOllamaKasper class >> ruleCascadedNextPutAllsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'AI-OllamaKasper')) #'2025-03-25T10:33:44.159325+01:00') )
]
