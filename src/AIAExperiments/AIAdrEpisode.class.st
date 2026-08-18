Class {
	#name : 'AIAdrEpisode',
	#superclass : 'Object',
	#instVars : [
		'channel',
		'language'
	],
	#category : 'AIAExperiments-YouTube',
	#package : 'AIAExperiments',
	#tag : 'YouTube'
}

{ #category : 'accessing' }
AIAdrEpisode class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
	self error.
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'accessing' }
AIAdrEpisode class >> episodeFetch: youtube [
    "AIAYouTube episodeFetch: 'https://www.youtube.com/watch?v=jrP7buPo2yA&t=87s'"
    | episodeId |
    episodeId := youtube.
    (episodeId first: 'https:' size) = 'https:'
        ifTrue: [ | vPos |
            vPos := (youtube indexOfSubCollection: 'v=' startingAt: 1) + 2.
            episodeId := youtube copyFrom: vPos to: vPos + 10 ].
    ^ self new episodeFetch: episodeId

]

{ #category : 'episode' }
AIAdrEpisode >> channel: handler [
	channel := handler.
]

{ #category : 'episode' }
AIAdrEpisode >> episodeFetch: episodeId [
	| item enclosure url audioPath wavPath txtPath text |

	item := self episodeXMLItem: episodeId.
	enclosure := item elementAt: 'enclosure'.
	url := enclosure attributeAt: 'url'.
	audioPath := self episodePath , episodeId , '.audio'.

	LibC runCommand:
		'curl -L -o "' , audioPath , '" "' , url , '"'.

	wavPath := self episodePath , episodeId , '.wav'.
	LibC runCommand:
		'ffmpeg -y -i "' , audioPath ,
		'" -ar 16000 -ac 1 -c:a pcm_s16le "' ,
		wavPath , '"'.
	
	text := self textFromAudioXAI: wavPath asFileReference.	

	txtPath := self episodePath , episodeId.
	(File named: txtPath , '.txt') writeStream
		<< text utf8Encoded << String lf ;
		close.
	(File named: wavPath) delete.
	(File named: audioPath) delete.
	^ txtPath , '.txt'
]

{ #category : 'dr access' }
AIAdrEpisode >> episodeMeta: episodeId [
	| item title author duration pubDate description dates meta |
	item := self episodeXMLItem: episodeId.

	title := (item elementAt: 'title') contentString trimBoth.
	author := (item elementAt: 'itunes:author') contentString trimBoth.
	duration := (item elementAt: 'itunes:duration') contentString trimBoth.
	pubDate := (item elementAt: 'pubDate') contentString trimBoth.
	description := (item elementAt: 'description') contentString trimBoth.
	
	dates := pubDate substrings.
	pubDate := (Date
			year: dates fourth asInteger
			month: ((Date monthNames collect: [ :n | n first: 3 ]) indexOf: dates third)
			day: dates second asInteger) yyyymmdd copyReplaceAll: '-' with: ''.

	meta := String lf join: {
		title.
		author.
		episodeId.
		duration.
		pubDate.
		description
	}.
	(self episodePath , episodeId , '_meta.txt') asFileReference
		writeStreamDo: [ :stream |
			stream nextPutAll: meta ]
]

{ #category : 'episode' }
AIAdrEpisode >> episodePath [
	"Returns the file path for the specified episode ID."
    ^ AIAdrChannel channelDictionary , channel, '/'

]

{ #category : 'dr access' }
AIAdrEpisode >> episodeXMLItem: episodeId [
	| document items |

	document := XMLDOMParser parseURL:
		('https://api.dr.dk/podcasts/v1/feeds/', (channel asString allButFirst: 3)).

	items := document allElementsNamed: 'item'.

	^ items
		detect: [ :item |
			(item elementAt: 'guid')
				contentString trimBoth = episodeId ]
		ifNone: [
			self error:
				'No DR episode found with id ' , episodeId ]
]

{ #category : 'initialization' }
AIAdrEpisode >> initialize [
	channel := ''.
]

{ #category : 'dr access' }
AIAdrEpisode >> textFromAudioOpenAI: aFileReference [
	| entity part response parsed |

	part := ZnMimePart
		fieldName: 'file'
		fileName: aFileReference basename
		entity: (ZnEntity
			with: aFileReference binaryReadStream contents
			type: (ZnMimeType fromString: 'audio/wav')).

	entity := ZnMultiPartFormDataEntity new.
	entity
		addPart: part;
		addPart: (ZnMimePart
			fieldName: 'model'
			value: 'gpt-4o-mini-transcribe');
		addPart: (ZnMimePart
			fieldName: 'language'
			value: 'da');
		addPart: (ZnMimePart
			fieldName: 'response_format'
			value: 'json').

	response := ZnClient new
		url: 'https://api.openai.com/v1/audio/transcriptions';
		headerAt: 'Authorization'
			put: OpenAIApi openAI01;
		entity: entity;
		post;
		contents.

	parsed := STONJSON fromString: response.

	^ (parsed includesKey: 'text')
		ifTrue: [ parsed at: 'text' ]
		ifFalse: [
			self error:
				'OpenAI transcription failed: ' , parsed asString ]
]

{ #category : 'dr access' }
AIAdrEpisode >> textFromAudioXAI: aFileReference [
	| entity part response parsed |

	part := ZnMimePart
		fieldName: 'file'
		fileName: aFileReference basename
		entity: (ZnEntity
			with: aFileReference binaryReadStream contents
			type: (ZnMimeType fromString: 'audio/wav')).

	entity := ZnMultiPartFormDataEntity new.
	entity
		addPart: part;
		addPart: (ZnMimePart
			fieldName: 'language'
			value: 'da');
		addPart: (ZnMimePart
			fieldName: 'format'
			value: 'true').

	response := ZnClient new
		url: 'https://api.x.ai/v1/stt';
		headerAt: 'Authorization'
			put: 'Bearer ' , GrokApi grokKey;
		entity: entity;
		post;
		contents.

	parsed := STONJSON fromString: response.

	^ (parsed includesKey: 'text')
		ifTrue: [ parsed at: 'text' ]
		ifFalse: [ 'xAI transcription failed: ' , parsed asString ]
]
