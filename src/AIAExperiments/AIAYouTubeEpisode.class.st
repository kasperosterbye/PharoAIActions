"
# Class: AIAYouTubeEpisode

`AIAYouTubeEpisode` handles the download and processing of individual YouTube video transcripts and metadata.

It uses `yt-dlp` to:
- Check for available auto-generated captions
- Download VTT subtitle files
- Extract and clean the transcript text
- Fetch and store basic video metadata (title, uploader, duration, upload date, description)

The class also tracks whether an episode has been marked as read, storing this status in a local `_meta.txt` file.

## Main responsibilities
- Fetching and cleaning auto-captions into plain text
- Managing local file storage for transcripts and metadata per channel
- Marking episodes as read / unread

## Dependencies
- Requires `yt-dlp` to be installed and available on the system path
- Relies on `AIAYouTubeUI channelDictionary` for the base storage path

## Typical usage
```smalltalk
AIAYouTubeEpisode episodeFetch: 'https://www.youtube.com/watch?v=jrP7buPo2yA'
```
"
Class {
	#name : 'AIAYouTubeEpisode',
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

{ #category : 'accessing' }
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
		' -o "', AIAYouTubeUI channelDictionary,  
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
AIAYouTubeEpisode >> episodeHasAutoCaptions: episodeId [
    | command result |
    command := 'yt-dlp --list-subs "https://www.youtube.com/watch?v=' , episodeId , '" > /tmp/yt_subs.txt'.
    LibC runCommand: command.
    result := (File named: '/tmp/yt_subs.txt') readStream contents asString.
    ^ (result includesSubstring: 'has no automatic captions') not
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeIsRead: episodeId [
    | file lines |
    file := File named: (self episodePath: episodeId) , episodeId , '_meta.txt'.
    file exists ifFalse: [ ^ false ].
    lines := file readStream contents asString lines.
    ^ lines last = 'have read: true'
]

{ #category : 'yt-dlp' }
AIAYouTubeEpisode >> episodeMarkAsRead: episodeId [
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
AIAYouTubeEpisode >> episodeMarkAsUnread: episodeId [
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
    ^ AIAYouTubeUI directoryForChannel: channel

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodePath: episodeId [
	"Returns the file path for the specified episode ID."
    ^ AIAYouTubeUI directoryForChannel: channel

]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTranscript: episodeId [
	"Returns the transcript of a YouTube video, processing the VTT file to extract and clean the text."

	| lines result response|
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
AIAYouTubeEpisode >> episodeVttPath: episodeId [
	"Returns the file path for the VTT subtitle file of a YouTube video."
    ^ AIAYouTubeUI channelDictionary , episodeId , '.', language , '.vtt'

]

{ #category : 'initialization' }
AIAYouTubeEpisode >> initialize [
	channel := ''.
]
