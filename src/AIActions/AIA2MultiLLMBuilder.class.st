Class {
	#name : 'AIA2MultiLLMBuilder',
	#superclass : 'Object',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> build [
	| storeLines |
	storeLines := AIA2MultiLLMStorage storage storeRows.
	storeLines do: [ :sl |
		self buildResponseText: sl
		 ] 
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> buildResponseText: storeLine [
	(self turnsBlock at: storeLine turnPattern ) value: storeLine
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> response1Of: storeLine [
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		user: 'aaa is 2';
		assistant: 'OK';
		user: 'bbb is 3';
		assistant: 'OK';
		user: 'so aaa + bbb is what. Answer with ONLY the final result.';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> response2Of: storeLine [
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		user: 'aaa is 2';
		user: 'bbb is 3';
		user: 'so aaa + bbb is what. Answer with ONLY the final result.';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> response3Of: storeLine [
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		assistant: 'aaa is 2';
		assistant: 'bbb is 3';
		assistant: 'so aaa + bbb is what. Answer with ONLY the final result.';
		user: '?';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> response4Of: storeLine [
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		assistant: 'aaa is 2';
		assistant: 'bbb is 3';
		assistant: 'so aaa + bbb is what. Answer with ONLY the final result.';
		getResponse.
	storeLine responseText: hist response..
]

{ #category : 'context roles' }
AIA2MultiLLMBuilder >> responseType [
	^ 'Answer with ONLY the final result. Do not explain, do not add any text before or after, no reasoning, no quotes unless required.'
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> turnsBlock [
	^ { 
		#UAUAU -> [ :storeLine | self response1Of: storeLine ].
		#UUU -> [ :storeLine | self response2Of: storeLine ].
		#AAAU -> [ :storeLine | self response3Of: storeLine ].
		#AAA -> [ :storeLine | self response4Of: storeLine ].
		} asDictionary 
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMBuilder >> turnsBlockSource [
	^ { 
		#UAUAU -> #response1Of:.
		#UUU -> #response2Of:.
		#AAAU -> #response3Of:.
		#AAA -> #response4Of: .
		} asDictionary 
]
