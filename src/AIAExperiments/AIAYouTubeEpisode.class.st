Class {
	#name : 'AIAYouTubeEpisode',
	#superclass : 'Object',
	#instVars : [
		'channel'
	],
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'as yet unclassified' }
AIAYouTubeEpisode class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
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
AIAYouTubeEpisode >> buildEpisodes: handler videoIDs: videoIDs [

	channel := handler.
	videoIDs do: [ :id |
		Transcript << channel << ' : ' << id << String lf.
		self episodeFetch: id.
		self episodeMeta: id.
		 ]
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeDownloadVtt: episodeId [
	"Downloads the VTT subtitle file for a YouTube video using yt-dlp."
    | command |
    command := 'yt-dlp --write-auto-sub --skip-download --sub-lang en -o "/Users/kasper/Downloads/YT_%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' , episodeId , '"'.
    LibC runCommand: command

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeFetch: episodeId [
	"Fetches and processes the transcript for a YouTube video using its episode ID."
    | transcript |
    self episodeDownloadVtt: episodeId.
    transcript := self episodeTranscript: episodeId.
    (File named: (self episodePath: episodeId), episodeId, '.txt') writeStream 
        nextPutAll: transcript;
        close.
    (File named: (self episodeVttPath: episodeId)) delete.
    ^ transcript
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeMeta: episodeId [
	"Returns metadata for a YouTube video using its episode ID."

	| items command  |
	items := String lf join: { '%(title)s'. '%(uploader_id)s'. '%(id)s'. 
		'%(duration)s'. '%(upload_date)s'. '%(description)s' }.
	command := 'yt-dlp --skip-download --print "' , items , 
		'" "https://www.youtube.com/watch?v=' , episodeId, 
		'" > ', self episodePath, episodeId asString,  '_meta.txt'.
	LibC runCommand: command.
	
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodePath [
	"Returns the file path for the specified episode ID."
    ^ '/Users/kasper/D/YouTube/', channel, '/'

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodePath: episodeId [
	"Returns the file path for the specified episode ID."
    ^ '/Users/kasper/D/YouTube/', channel, '/'

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTranscript: episodeId [
	"Returns the transcript of a YouTube video, processing the VTT file to extract and clean the text."

	| lines result |
	[ self halt.
		lines := OrderedCollection 
			newFromArray: (File named: (self episodeVttPath: episodeId)) readStream contents asString lines.
		lines removeFirst: 3.
		lines removeAllSuchThat: [ :line | line isEmpty or: [ line = ' ' ] ].
		lines removeAllSuchThat: [ :line | (line includes: $<) not ].
		lines removeAllSuchThat: [ :line | line includesAll: 'align:start position:0%' ].
		result := WriteStream on: ''.
		1 to: lines size do: [ :line | result << ((lines at: line) copyWithRegex: '<[^>]*>' matchesReplacedWith: '') << ' ' ].
		^ result contents copyReplaceAll: '. ' with: '.' , String cr ]
		on: Error
		do: [ ^ 'The id: ' , episodeId , ' could not be read' ", String lf, result contents "]
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeVttPath: episodeId [
	"Returns the file path for the VTT subtitle file of a YouTube video."
    ^ '/Users/kasper/Downloads/YT_' , episodeId , '.en.vtt'

]

{ #category : 'initialization' }
AIAYouTubeEpisode >> initialize [
	channel := ''.
]

{ #category : 'episode' }
AIAYouTubeEpisode >> old_episodeMeta: episodeId [
	"Returns metadata for a YouTube video using its episode ID."

	| items command  |
	items := String lf join: { '%(title)s'. '%(uploader_id)s'. '%(id)s'. 
		'%(duration)s'. '%(upload_date)s'. '%(description)s' }.
	command := 'yt-dlp --skip-download --print "' , items , 
		'" "https://www.youtube.com/watch?v=' , episodeId, 
		'" > /Users/kasper/Downloads/yt_meta.txt'.
	LibC runCommand: command.
	
]
