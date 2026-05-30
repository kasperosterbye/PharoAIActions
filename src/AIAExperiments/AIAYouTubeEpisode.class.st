Class {
	#name : 'AIAYouTubeEpisode',
	#superclass : 'Object',
	#instVars : [
		'channel',
		'language'
	],
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'as yet unclassified' }
AIAYouTubeEpisode class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
	self error.
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'as yet unclassified' }
AIAYouTubeEpisode class >> episodeFetch: youtube [
    "AIAYouTube episodeFetch: 'https://www.youtube.com/watch?v=jrP7buPo2yA&t=87s'"
    | episodeId |
    episodeId := youtube.
    (episodeId first: 'https:' size) = 'https:'
        ifTrue: [ | vPos |
            vPos := (youtube indexOfSubCollection: 'v=' startingAt: 1) + 2.
            episodeId := youtube copyFrom: vPos to: vPos + 10 ].
    ^ self new episodeFetch: episodeId

]

{ #category : 'as yet unclassified' }
AIAYouTubeEpisode class >> episodeId: youtube [
    "AIAYouTube episodeFetch: 'https://www.youtube.com/watch?v=jrP7buPo2yA&t=87s'"
    
    self new 
		episodeFetch: youtube;
		episodeMeta: youtube.

]

{ #category : 'episode' }
AIAYouTubeEpisode >> channel: handler [
	channel := handler.
]

{ #category : 'yt-dlp' }
AIAYouTubeEpisode >> episodeDownloadVtt: episodeId [
	"Downloads the VTT subtitle file for a YouTube video using yt-dlp."
    | command |
    command := 'yt-dlp --write-auto-sub --skip-download --sub-lang ', language,  
		' -o "', AIAYouTubeChannel channelDictionary,  
		'%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' , episodeId , '"'.
    LibC runCommand: command.

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeFetch: episodeId [
	"Fetches and processes the transcript for a YouTube video using its episode ID."

	| transcript |
	(self episodeHasAutoCaptions: episodeId )
		ifTrue: [
	AIAYouTubeChannel transcriptLanguages
		detect: [ :lang |
				language := lang.
				self episodeDownloadVtt: episodeId.
				transcript := self episodeTranscript: episodeId.
				(transcript beginsWith: '***YouTubeEpisode Error***') not ]
		ifNone: [ ].
	(File named: (self episodeVttPath: episodeId)) delete]
		ifFalse: [ transcript := 'There is no transcript text available' ].
	(File named: (self episodePath: episodeId) , episodeId , '.txt') writeStream
		nextPutAll: transcript;
		close
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeFetch_new: episodeId [
    "Fetches and processes the transcript for a YouTube video using its episode ID."
    | transcript |
    AIAYouTubeChannel transcriptLanguages
        detect: [ :lang |
            language := lang.
            self episodeDownloadVtt: episodeId.
            transcript := self episodeTranscript: episodeId.
            (transcript beginsWith: '***YouTubeEpisode Error***') not ]
        ifNone: [ ].
    (File named: (self episodeVttPath: episodeId)) delete.
    (File named: (self episodePath: episodeId) , episodeId , '.txt') writeStream
                nextPutAll: transcript;
                close.
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeFetch_old: episodeId [
    "Fetches and processes the transcript for a YouTube video using its episode ID."
    | transcript |
    AIAYouTubeChannel transcriptLanguages do: [ :lang |
		language := lang.
        self episodeDownloadVtt: episodeId.
        transcript := self episodeTranscript: episodeId.
        (transcript beginsWith: '***YouTubeEpisode Error***') ifFalse: [
            (File named: (self episodePath: episodeId) , episodeId , '.txt') writeStream
                nextPutAll: transcript;
                close.
            (File named: (self episodeVttPath: episodeId)) delete.
            ^ transcript ] ].
	 (File named: (self episodePath: episodeId) , episodeId , '.txt') writeStream
                nextPutAll: transcript;
                close.
    ^ transcript 
]

{ #category : 'as yet unclassified' }
AIAYouTubeEpisode >> episodeHasAutoCaptions: episodeId [
    | command result |
    command := 'yt-dlp --list-subs "https://www.youtube.com/watch?v=' , episodeId , '" > /tmp/yt_subs.txt'.
    LibC runCommand: command.
    result := (File named: '/tmp/yt_subs.txt') readStream contents asString.
    ^ (result includesSubstring: 'has no automatic captions') not
]

{ #category : 'yt-dlp' }
AIAYouTubeEpisode >> episodeMeta: episodeId [
	"Fetches video metadata using yt dlp and saves it to a file for the specified episode"

	| items command  |
	items := String lf join: { '%(title)s'. '%(uploader_id)s'. '%(id)s'. 
		'%(duration)s'. '%(upload_date)s'. '%(description)s' }.
	command := 'yt-dlp --skip-download --print "' , items , 
		'" "https://www.youtube.com/watch?v=' , episodeId, 
		'" > ', self episodePath , episodeId asString,  '_meta.txt'.
	LibC runCommand: command.
	
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodePath [
	"Returns the file path for the specified episode ID."
    ^ AIAYouTubeChannel channelDictionary , channel, '/'

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodePath: episodeId [
	"Returns the file path for the specified episode ID."
    ^ AIAYouTubeChannel channelDictionary , channel, '/'

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTranscript: episodeId [
	"Returns the transcript of a YouTube video, processing the VTT file to extract and clean the text."

	| lines result |
	[ 
		lines := OrderedCollection newFromArray: (File named: (self episodeVttPath: episodeId)) readStream contents asString lines.
		lines removeFirst: 3.
		lines removeAllSuchThat: [ :line | line isEmpty or: [ line = ' ' ] ].
		lines removeAllSuchThat: [ :line | (line includes: $<) not ].
		lines removeAllSuchThat: [ :line | line includesAll: 'align:start position:0%' ].
		result := WriteStream on: ''.
		1 to: lines size do: [ :line | result << ((lines at: line) copyWithRegex: '<[^>]*>' matchesReplacedWith: '') << ' ' ].
		^ result contents copyReplaceAll: '. ' with: '.' , String cr ]
		on: Error
		do: [ ^ '***YouTubeEpisode Error*** The id: ' , episodeId , ' could not be read' ]
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeVttPath: episodeId [
	"Returns the file path for the VTT subtitle file of a YouTube video."
    ^ AIAYouTubeChannel channelDictionary , episodeId , '.', language , '.vtt'

]

{ #category : 'initialization' }
AIAYouTubeEpisode >> initialize [
	channel := ''.
]
