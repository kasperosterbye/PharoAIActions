"
# Class Comment for AIAYouTube

## Purpose and Role in the System

The `AIAYouTube` class is designed to facilitate the retrieval, processing, and storage of YouTube video content, particularly focusing on educational and novel content channels. It leverages the `yt-dlp` tool to download video metadata, subtitles, and transcripts, and processes this data to provide structured and cleaned-up content. This class is integral to systems that require automated content aggregation, analysis, or archiving from YouTube, such as educational platforms, content curation services, or research tools.

## Main Collaborators or Dependencies

The `AIAYouTube` class collaborates with external tools and libraries, primarily `yt-dlp`, which is used to interact with YouTube's API and download video metadata and subtitles. It also interacts with the file system to store and retrieve processed data. The class depends on the availability and correct configuration of `yt-dlp` and the file system paths specified in the methods.

## Important Invariants or Design Constraints

1. **File System Paths**: The class relies on specific file system paths for storing and retrieving data. These paths are hardcoded in the methods, which may need to be adjusted for different environments.
2. **Character Encoding**: The class processes text data by filtering out non-ASCII characters, which may lead to the loss of certain characters in the original content.
3. **External Dependencies**: The functionality of the class is heavily dependent on the availability and correct operation of `yt-dlp` and the file system.

## Illustrative Usage Examples

### Example 1: Fetching and Processing a Video Transcript

```smalltalk
| youtube episodeId transcript |
youtube := AIAYouTube new.
episodeId := 'jrP7buPo2yA'.
transcript := youtube episodeFetch: episodeId.
```

This example demonstrates how to fetch and process the transcript of a YouTube video using its episode ID. The `episodeFetch:` method handles downloading the subtitles, processing the transcript, and storing the result.

### Example 2: Retrieving Channel Episode IDs

```smalltalk
| youtube channelHandle episodeIds |
youtube := AIAYouTube new.
channelHandle := 'DarkspaceAudio'.
episodeIds := youtube channelEpisodeIds: channelHandle count: 10.
```

This example shows how to retrieve a list of episode IDs for a specified YouTube channel. The `channelEpisodeIds:count:` method fetches the episode IDs and ensures the necessary directories and descriptions are in place.

## Usage Guidelines

- **Environment Setup**: Ensure that `yt-dlp` is installed and accessible from the command line. The file system paths used in the methods should be verified and adjusted as necessary.
- **Error Handling**: The class does not include comprehensive error handling for external tool failures or file system issues. Users should implement additional error handling as needed.
- **Performance**: Downloading and processing multiple videos can be time-consuming. Consider running these operations asynchronously or in batches to avoid performance issues.

By adhering to these guidelines and understanding the invariants and dependencies, users can effectively utilise the `AIAYouTube` class to manage and process YouTube video content within their applications.
"
Class {
	#name : 'AIAYouTube',
	#superclass : 'Object',
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'as yet unclassified' }
AIAYouTube class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'as yet unclassified' }
AIAYouTube class >> episodeFetch: youtube [
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
AIAYouTube class >> novelChannels [
	"Returns an array of YouTube channel names for novel content"
    ^ { #DarkspaceAudio. 
        #'vitalAgehealth1-f1f'. 
        #GalaxyChroniclesX. 
        #EpicSpaceChronicles. 
        #hyf_chronicles_prime.
        #HFYZenith. #TheHYFUnleashed. 
        #'EarthbornLegends-y8o'. 
        #'Sci-Fi-Vault' }

]

{ #category : 'as yet unclassified' }
AIAYouTube class >> subscriptionChannels [
	"Returns an array of YouTube channel names for subscription"
    ^ { #TLDRnewsEU. 
        #TwoBitDaVinci. 
        #JustHaveaThink. 
        #SabineHossenfelder. 
        #UKSTUG. 
        #ZirothTech. 
        #UndecidedTechnology. 
        #parthknowsai. 
        #PracticalEngineeringChannel. 
        #ThunderboltsProject. 
        #SeethePattern }
]

{ #category : 'channel' }
AIAYouTube >> channelDirectory: channelHandle [
	"Returns the directory path for the specified channel handle."
	^ self class channelDictionary , channelHandle
]

{ #category : 'channel' }
AIAYouTube >> channelEnsureDescription: channelHandle [
	"Ensures the channel description file exists, creating it if necessary."

	| path command raw |
	path := (self channelDirectory: channelHandle) , '/description.txt'.
	(File named: path) exists ifTrue: [ ^ self ].
	command := 'yt-dlp -I 0 --print "playlist:description" "https://www.youtube.com/@' , 
		channelHandle , '" > /tmp/yt_channel.txt'.
	LibC runCommand: command.
	raw := (File named: '/tmp/yt_channel.txt') readStream contents asString.
	raw := raw select: [ :char | char asciiValue < 128 ].
	(File named: path) writeStream
		<< '### @' << channelHandle  << String lf << raw;
		close
]

{ #category : 'channel' }
AIAYouTube >> channelEnsureDirectory: channelHandle [
	"Ensures the directory for the specified channel handle exists, creating it if necessary."
	| dir |
	dir := self channelDirectory: channelHandle.
	(File named: dir) exists ifFalse: [ 
		LibC runCommand: 'mkdir -p "' , dir , '"' ]
]

{ #category : 'channel' }
AIAYouTube >> channelEpisodeIds: channelHandle [
	"Returns a collection of episode IDs for a specified YouTube channel."
    ^ self channelEpisodeIds: channelHandle count: 25

]

{ #category : 'channel' }
AIAYouTube >> channelEpisodeIds: channelHandle count: count [
	"Returns a collection of episode IDs for a specified YouTube channel, limited by the specified count."
	| lines result |
	self channelEnsureDirectory: channelHandle.
	self channelEnsureDescription: channelHandle.
	LibC runCommand:
		'yt-dlp --flat-playlist --playlist-end ' , count asString , ' --print "%(id)s" "https://www.youtube.com/@' , channelHandle
		, '" > /tmp/yt_ids.txt'.
	lines := (File named: '/tmp/yt_ids.txt') readStream contents asString lines
		reject: [ :line | line trim isEmpty ].
	result := lines collect: [ :line | line select: [ :char | char asciiValue < 128 ] ].
	^ result
]

{ #category : 'episode' }
AIAYouTube >> episodeDownloadVtt: episodeId [
	"Downloads the VTT subtitle file for a YouTube video using yt-dlp."
    | command |
    command := 'yt-dlp --write-auto-sub --skip-download --sub-lang en -o "/Users/kasper/Downloads/YT_%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' , episodeId , '"'.
    LibC runCommand: command

]

{ #category : 'episode' }
AIAYouTube >> episodeFetch: episodeId [
	"Fetches and processes the transcript for a YouTube video using its episode ID."
    | transcript |
    self episodeDownloadVtt: episodeId.
    transcript := self episodeTranscript: episodeId.
    (File named: (self episodePath: episodeId)) writeStream 
        nextPutAll: transcript;
        close.
    (File named: (self episodeVttPath: episodeId)) delete.
    ^ transcript
]

{ #category : 'episode' }
AIAYouTube >> episodeMeta: episodeId [
	"Returns metadata for a YouTube video using its episode ID."
    | items command raw |
    items := String lf join: {'%(title)s'. '%(uploader_id)s'. '%(id)s'. '%(duration)s'. '%(description)s'}.
    command := 'yt-dlp --skip-download --print "', items,
        '" "https://www.youtube.com/watch?v=' , episodeId , 
        '" > /Users/kasper/Downloads/yt_meta.txt'.
    LibC runCommand: command.
    raw := (File named: '/Users/kasper/Downloads/yt_meta.txt') readStream contents asString.
    raw := raw select: [ :char | char asciiValue < 128 ].
    raw := raw lines.
    ^ { 'title' -> raw first. 
        'uploader_id' -> raw second allButFirst.
        'id' -> raw third.
        'duration' -> raw fourth.
        'description' -> raw fifth } asOrderedDictionary
]

{ #category : 'episode' }
AIAYouTube >> episodePath: episodeId [
	"Returns the file path for the specified episode ID."
    ^ self class channelDictionary , episodeId , '.txt'

]

{ #category : 'episode' }
AIAYouTube >> episodeTranscript: episodeId [
	"Returns the transcript of a YouTube video, processing the VTT file to extract and clean the text."
    | lines result |
    lines := OrderedCollection 
        newFromArray: 
            (File named: (self episodeVttPath: episodeId)) readStream contents asString lines.
    lines removeFirst: 3.
    lines removeAllSuchThat: [ :line | line isEmpty or: [ line = ' ' ] ].
    lines removeAllSuchThat: [ :line | (line includes: $<) not ].
    lines removeAllSuchThat: [ :line | line includesAll: 'align:start position:0%'].
    result := WriteStream on: ''.
    1 to: lines size do: [ :line | 
        result << ((lines at: line) copyWithRegex: '<[^>]*>' matchesReplacedWith: '' ) << ' ' ].
    ^ result contents copyReplaceAll: '. ' with: ('.', String cr).
]

{ #category : 'episode' }
AIAYouTube >> episodeVttPath: episodeId [
	"Returns the file path for the VTT subtitle file of a YouTube video."
    ^ '/Users/kasper/Downloads/YT_' , episodeId , '.en.vtt'

]
