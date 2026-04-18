Extension { #name : 'BlockClosure' }

{ #category : '*AIAExperiments' }
BlockClosure >> sd [
	self sd: ''.
]

{ #category : '*AIAExperiments' }
BlockClosure >> sd: packageName [
	MicroUMLSDForCode5 new forCode: self inPackage: packageName .
]
