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

{ #category : 'as yet unclassified' }
AIAdrEpisode class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
	self error.
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
AIAdrEpisode >> ensureXMLParser [
	(Smalltalk globals includesKey: #XMLDOMParser) ifTrue: [ ^ self ].

	Metacello new
		baseline: 'XMLParser';
		repository: 'github://pharo-contributions/XML-XMLParser/src';
		load
]

{ #category : 'yt-dlp' }
AIAdrEpisode >> episodeDownloadVtt: episodeId [
	"Downloads the VTT subtitle file for a YouTube video using yt-dlp."
    | command |
self halt.
    command := 'yt-dlp --write-auto-sub --skip-download --sub-lang ', language,  
		' -o "', AIAYouTubeChannel channelDictionary,  
		'%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' , episodeId , '"'.
    LibC runCommand: command.

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
	
	text := self textFromAudioOpenAI: wavPath asFileReference.	

	txtPath := self episodePath , episodeId.
	(File named: txtPath , '.txt') writeStream
		<< text utf8Encoded << String lf ;
		close.
	(File named: wavPath) delete.
	(File named: audioPath) delete.
	^ txtPath , '.txt'
]

{ #category : 'as yet unclassified' }
AIAdrEpisode >> episodeHasAutoCaptions: episodeId [
    | command result |
self halt.
    command := 'yt-dlp --list-subs "https://www.youtube.com/watch?v=' , episodeId , '" > /tmp/yt_subs.txt'.
    LibC runCommand: command.
    result := (File named: '/tmp/yt_subs.txt') readStream contents asString.
    ^ (result includesSubstring: 'has no automatic captions') not
]

{ #category : 'as yet unclassified' }
AIAdrEpisode >> episodeIsRead: episodeId [
    | file lines |
    file := File named: (self episodePath: episodeId) , episodeId , '_meta.txt'.
    file exists ifFalse: [ ^ false ].
    lines := file readStream contents asString lines.
    ^ lines last = 'have read: true'
]

{ #category : 'yt-dlp' }
AIAdrEpisode >> episodeMarkAsRead: episodeId [
    "Adds 'have read: true' to the end of the meta file."
    | file contents |
    file := File named: (self episodePath: episodeId) , episodeId , '_meta.txt'.
    file exists ifFalse: [ ^ self ].
    contents := file readStream contents asString.
    (contents includesSubstring: 'have read: true') ifTrue: [ ^ self ].
	 file delete.
    file writeStream
        << contents << String lf << 'have read: true';
        close

]

{ #category : 'yt-dlp' }
AIAdrEpisode >> episodeMarkAsUnread: episodeId [
    "Removes 'have read: true' from the meta file."	 
    |  file contents cleaned |
    file := File named: (self episodePath: episodeId) , episodeId , '_meta.txt'.
	 file exists ifFalse: [ ^ self ].
    contents := file readStream contents asString.
    (contents includesSubstring: 'have read: true') ifFalse: [ ^ self ].
	 cleaned := contents copyReplaceAll: String lf, 'have read: true'  with: ''.
	 file delete.
    file writeStream << cleaned; close
]

{ #category : 'yt-dlp' }
AIAdrEpisode >> episodeMeta: episodeId [
	| item title author duration pubDate description meta |

	item := self episodeXMLItem: episodeId.

	title := (item elementAt: 'title') contentString trimBoth.
	author := (item elementAt: 'itunes:author') contentString trimBoth.
	duration := (item elementAt: 'itunes:duration') contentString trimBoth.
	pubDate := (item elementAt: 'pubDate') contentString trimBoth.
	description := (item elementAt: 'description') contentString trimBoth.

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

{ #category : 'episode' }
AIAdrEpisode >> episodePath: episodeId [
	"Returns the file path for the specified episode ID."
self halt.
    ^ AIAYouTubeChannel channelDictionary , channel, '/'

]

{ #category : 'episode' }
AIAdrEpisode >> episodeTranscript: episodeId [
	"Returns the transcript of a YouTube video, processing the VTT file to extract and clean the text."

	| lines result response|
	self halt.
	[ 
		lines := OrderedCollection newFromArray: (File named: (self episodeVttPath: episodeId)) readStream contents asString lines.
		lines removeFirst: 3.
		lines removeAllSuchThat: [ :line | line isEmpty or: [ line = ' ' ] ].
		lines removeAllSuchThat: [ :line | (line includes: $<) not ].
		lines removeAllSuchThat: [ :line | line includesAll: 'align:start position:0%' ].
		result := WriteStream on: ''.
		1 to: lines size do: [ :line | 
				result << ((lines at: line) copyWithRegex: '<[^>]*>' matchesReplacedWith: '') << ' ' ].
		response := result contents copyReplaceAll: '. ' with: '.' , String cr.
		response := response copyReplaceAll: '&gt;' with: ''.
		^ response ]
		on: Error
		do: [ ^ '***YouTubeEpisode Error*** The id: ' , episodeId , ' could not be read' ]
]

{ #category : 'episode' }
AIAdrEpisode >> episodeVttPath: episodeId [
	"Returns the file path for the VTT subtitle file of a YouTube video."
	self halt.
    ^ AIAYouTubeChannel channelDictionary , episodeId , '.', language , '.vtt'

]

{ #category : 'yt-dlp' }
AIAdrEpisode >> episodeXMLItem: episodeId [
	| document items |

	self ensureXMLParser.

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

{ #category : 'STT' }
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
