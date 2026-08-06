"
# Class Comment for AIAYouTubeChannel

## Purpose and Role in the System

The `AIAYouTubeChannel` class is designed to facilitate the management and retrieval of YouTube channel data, particularly focusing on episode IDs and channel descriptions. It serves as a bridge between the local file system and YouTube, enabling the storage and retrieval of channel-specific information such as episode IDs and descriptions. This class is particularly useful for applications that need to interact with YouTube content programmatically, such as automated content aggregation, analysis, or archiving.

## Main Collaborators or Dependencies

The `AIAYouTubeChannel` class collaborates with several external tools and libraries:

1. **yt-dlp**: A command-line program used to download videos and extract metadata from YouTube. It is employed to fetch episode IDs and channel descriptions.
2. **LibC**: A library used to run shell commands, which is necessary for executing `yt-dlp` commands.
3. **File System**: The class interacts with the local file system to store and retrieve channel data, ensuring that the data is persisted between sessions.

## Important Invariants or Design Constraints

1. **Directory Structure**: The class assumes a specific directory structure for storing channel data. The root directory is defined by the `channelDictionary` method, and each channel's data is stored in a subdirectory named after the channel handle.
2. **File Naming**: Channel descriptions are stored in a file named `description.txt` within each channel's directory. This ensures consistency in file naming and location.
3. **Data Integrity**: The class ensures that the data fetched from YouTube is cleaned and stored in a consistent format. This includes removing non-ASCII characters to avoid encoding issues.

## Illustrative Usage Examples

### Example 1: Fetching Episode IDs

```smalltalk
| channelHandle episodeIds |
channelHandle := #TLDRnewsEU.
episodeIds := AIAYouTubeChannel new channelEpisodeIds: channelHandle count: 10.
Transcript show: episodeIds.
```

This example demonstrates how to fetch the IDs of the latest 10 episodes from the YouTube channel `TLDRnewsEU`. The `channelEpisodeIds:count:` method is used to retrieve the episode IDs, which are then printed to the transcript.

### Example 2: Ensuring Channel Data is Stored Locally

```smalltalk
| channelHandle |
channelHandle := #TLDRnewsEU.
AIAYouTubeChannel new channelBuildInFileSystem: channelHandle.
```

This example shows how to ensure that the local file system contains the necessary directory and description file for the YouTube channel `TLDRnewsEU`. The `channelBuildInFileSystem:` method handles the creation of the directory and the fetching and storage of the channel description.

By providing these detailed examples, users can understand how to effectively utilise the `AIAYouTubeChannel` class in their applications.
"
Class {
	#name : 'AIAdrChannel',
	#superclass : 'Object',
	#category : 'AIAExperiments-YouTube',
	#package : 'AIAExperiments',
	#tag : 'YouTube'
}

{ #category : 'accessing' }
AIAdrChannel class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'accessing' }
AIAdrChannel class >> drChannels [
	^ { #dr_radioavisen.
		#'dr_p1-debat'.
		#'dr_akkurat-med-clement' }
]

{ #category : 'accessing' }
AIAdrChannel class >> episodeUpdateLimit [
	^ 2 asString
]

{ #category : 'channel' }
AIAdrChannel >> channelBuildInFileSystem: channelHandle [
	"Ensures the directory and description file for a specified YouTube channel exist, creating them if necessary."
	self channelEnsureDirectory: channelHandle.
	self channelEnsureDescription: channelHandle.
]

{ #category : 'channel' }
AIAdrChannel >> channelDirectory: channelHandle [
	"Returns the directory path for the specified channel handle."
	^ self class channelDictionary , channelHandle
]

{ #category : 'dr access' }
AIAdrChannel >> channelEnsureDescription: channelHandle [
	"Ensures the channel description file exists, creating it if necessary."

	| path document channelElement title description |

	path := (self channelDirectory: channelHandle) , '/description.txt'.
	(File named: path) exists ifTrue: [ ^ self ].

	document := XMLDOMParser parseURL:
		('https://api.dr.dk/podcasts/v1/feeds/', (channelHandle asString allButFirst: 3)).

	channelElement := (document allElementsNamed: 'channel') first.

	title := (channelElement elementAt: 'title')
		contentString trimBoth.

	description := (channelElement elementAt: 'description')
		contentString trimBoth.

	"link := (channelElement elementAt: 'link')
		contentString trimBoth."
	(File named: path) writeStreamDo: [ :stream |
		stream
			<< '### ' << title << String lf
			<< description << String lf]
]

{ #category : 'channel' }
AIAdrChannel >> channelEnsureDirectory: channelHandle [
	"Ensures the directory for the specified channel handle exists, creating it if necessary."
	| dir |
	dir := self channelDirectory: channelHandle.
	(File named: dir) exists ifFalse: [ 
		LibC runCommand: 'mkdir -p "' , dir , '"' ]
]

{ #category : 'dr access' }
AIAdrChannel >> channelEpisodeIds: channelHandle [
	| feed document items ids |

	feed := 'https://api.dr.dk/podcasts/v1/feeds/',
		(channelHandle asString allButFirst: 3).

	document := XMLDOMParser parseURL: feed.

	items := document allElementsNamed: 'item'.

	ids := (items
		first: (self class episodeUpdateLimit asInteger min: items size))
		collect: [ :item |
			(item elementAt: 'guid')
				contentString trimBoth ].

	^ { channelHandle. ids }
]

{ #category : 'channel' }
AIAdrChannel >> channelEpisodesOnDisk: channelHandle [
	"Return a collection of episode IDs already downloaded for this channel."
	| dir |
	channelHandle ifNil: [ ^ #() ].
	dir := FileReference / (self channelDirectory: channelHandle).
	dir exists ifFalse: [ ^ #() ].
	^ (dir entries
		select: [ :entry | entry basename endsWith: '_meta.txt' ])
		collect: [ :entry | entry basename copyFrom: 1 to: entry basename size - '_meta.txt' size ]
]

{ #category : 'channel' }
AIAdrChannel >> channelUpdate: channelHandle [
	| result drIds localIds newIds episode |
	self channelBuildInFileSystem: channelHandle.
	result := self channelEpisodeIds: channelHandle.
	drIds := result second reject: [ :id | id trim isEmpty ].
	localIds := self channelEpisodesOnDisk: channelHandle.
	newIds := drIds reject: [ :id | localIds includes: id ].
	newIds isEmpty ifTrue: [ ^ self ].

	episode := AIAdrEpisode new.
	episode channel: channelHandle.

	newIds do: [ :id |
		episode episodeFetch: id.
		episode episodeMeta: id ]
]
