"
# Class Comment for AIAYouTubeEpisode

## Purpose and Role in the System

The `AIAYouTubeEpisode` class is designed to facilitate the fetching, processing, and storage of YouTube video transcripts and metadata. It serves as a bridge between YouTube content and local storage, enabling users to download subtitles, extract transcripts, and manage video metadata efficiently. This class is particularly useful for applications that require automated processing of YouTube video content, such as transcript analysis, content summarisation, or archival purposes.

## Main Collaborators or Dependencies

The `AIAYouTubeEpisode` class collaborates with external tools and libraries to achieve its functionality:

1. **yt-dlp**: A command-line program used to download video subtitles and metadata from YouTube. The class utilises `yt-dlp` to fetch subtitles in VTT format and extract metadata.
2. **LibC**: A library used to execute shell commands from within Pharo. The class uses `LibC` to run `yt-dlp` commands and manage file operations.
3. **File System**: The class interacts with the local file system to store and retrieve downloaded subtitles, transcripts, and metadata.

## Important Invariants or Design Constraints

1. **File Paths**: The class relies on predefined file paths for storing and retrieving subtitles, transcripts, and metadata. These paths are hardcoded and must be accessible and writable by the application.
2. **Subtitle Language**: The class is specifically designed to download English subtitles (`--sub-lang en`). If subtitles in other languages are required, the class would need to be modified.
3. **Error Handling**: The class includes basic error handling to manage cases where the subtitle file cannot be read or processed. However, more robust error handling mechanisms could be implemented for production use.

## Illustrative Usage Examples

### Example 1: Fetching and Processing a YouTube Video Transcript

```smalltalk
| episode |
episode := AIAYouTubeEpisode new.
episode channel: 'exampleChannel'.
episode episodeFetch: 'jrP7buPo2yA'.
```

This example demonstrates how to create an instance of `AIAYouTubeEpisode`, set the channel name, and fetch the transcript for a YouTube video with the specified episode ID. The transcript is downloaded, processed, and saved to the local file system.

### Example 2: Fetching Metadata for a YouTube Video

```smalltalk
| episode |
episode := AIAYouTubeEpisode new.
episode channel: 'exampleChannel'.
episode episodeMeta: 'jrP7buPo2yA'.
```

This example shows how to fetch and save metadata for a YouTube video. The metadata includes details such as the video title, uploader ID, duration, upload date, and description. The metadata is saved to a file in the specified directory.

## Conclusion

The `AIAYouTubeEpisode` class provides a robust and efficient way to manage YouTube video content within a Pharo application. By leveraging external tools like `yt-dlp` and interacting with the local file system, it enables users to download, process, and store video transcripts and metadata seamlessly. The class is particularly useful for applications that require automated processing of YouTube content, such as transcript analysis, content summarisation, or archival purposes.
"
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
AIAYouTubeEpisode class >> episodeId: youtube [
    "AIAYouTube episodeFetch: 'https://www.youtube.com/watch?v=jrP7buPo2yA&t=87s'"
    
    self new 
		episodeFetch: youtube;
		episodeMeta: youtube.

]

{ #category : 'episode' }
AIAYouTubeEpisode >> buildEpisodes: handler videoIDs: videoIDs [

	channel := handler.
	videoIDs do: [ :id |
		Transcript << channel << ' : ' << id << String lf.
		self episodeFetch: id.
		self episodeMeta: id.
		 ]
]

{ #category : 'episode' }
AIAYouTubeEpisode >> channel: handler [
	channel := handler.
]

{ #category : 'yt-dlp' }
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

{ #category : 'yt-dlp' }
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
		do: [ ^ 'The id: ' , episodeId , ' could not be read' ", String lf, result contents " ]
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
