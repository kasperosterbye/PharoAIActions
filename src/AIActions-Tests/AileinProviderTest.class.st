Class {
	#name : 'AileinProviderTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAileinProvider'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AileinProviderTest >> setUp [
	refAileinProvider := AileinProvider
]

{ #category : 'tests' }
AileinProviderTest >> testDefaultProvider [
	self assert: refAileinProvider defaultProvider equals: MistralApi 
	
]

{ #category : 'tests' }
AileinProviderTest >> testInitialize [
	self assert: refAileinProvider provider isNotNil .
]

{ #category : 'tests' }
AileinProviderTest >> testProvider [
	self assert: refAileinProvider providers size equals: AilienApi subclasses size .
	self assert: (refAileinProvider providers includes: MistralApi )
]

{ #category : 'tests' }
AileinProviderTest >> testProviderSet [
	| orig exp|
	orig := refAileinProvider provider.
	exp := refAileinProvider providers first.
	refAileinProvider provider: exp.
	self assert: refAileinProvider provider equals: refAileinProvider providers first .
	refAileinProvider provider: Object.
	self assert: (refAileinProvider providers includes: MistralApi ).
	refAileinProvider provider: 2.
	self assert: refAileinProvider provider equals: refAileinProvider providers second .
	refAileinProvider provider: 17.
	self assert: refAileinProvider provider equals: MistralApi .
]

{ #category : 'tests' }
AileinProviderTest >> testProviders [
	self assert: refAileinProvider providers size equals: AilienApi subclasses size .
	self assert: (refAileinProvider providers includes: MistralApi )
]
