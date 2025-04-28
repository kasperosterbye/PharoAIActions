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
	^ #(#(#(#RGMethodDefinition #(#OllamaApiExperiments01 #femForAlleModeller #false)) #'2025-04-25T08:14:23.471243+02:00') )
]

{ #category : 'code-critics' }
ManifestAIOllamaKasper class >> ruleCodeCruftLeftInMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'AI-OllamaKasper')) #'2025-04-26T18:28:49.617821+02:00') )
]

{ #category : 'code-critics' }
ManifestAIOllamaKasper class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#OllamaApiExperiments01 #femForAlleModeller #false)) #'2025-04-25T08:14:07.356408+02:00') #(#(#RGPackageDefinition #(#'AI-OllamaKasper')) #'2025-04-28T09:03:31.104576+02:00') )
]

{ #category : 'code-critics' }
ManifestAIOllamaKasper class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#OllamaApiExperiments #writeAsHTML:toFile: #false)) #'2025-04-25T14:23:56.712667+02:00') #(#(#RGMethodDefinition #(#OllamaApiExperiments01 #writeAsHTML:toFile: #false)) #'2025-04-25T15:36:04.461195+02:00') )
]

{ #category : 'code-critics' }
ManifestAIOllamaKasper class >> ruleStringConcatenationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#OllamaApiExperiments01 #femForAlleModeller #false)) #'2025-04-25T08:14:19.855603+02:00') )
]

{ #category : 'code-critics' }
ManifestAIOllamaKasper class >> ruleUnclassifiedMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#OllamaApiExperiments01 #femForAlleModeller #false)) #'2025-04-25T08:14:16.379263+02:00') #(#(#RGMethodDefinition #(#OllamaApiExperiments #html:on: #false)) #'2025-04-25T17:42:36.56681+02:00') )
]
