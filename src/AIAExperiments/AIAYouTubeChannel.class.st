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
	#name : 'AIAYouTubeChannel',
	#superclass : 'Object',
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> episodeFetch: youtube [
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
AIAYouTubeChannel class >> novelChannels [
	"Returns an array of YouTube channel names for novel content"
    ^ { #DarkspaceAudio. 
        #'vitalAgehealth1-f1f'. 
        #GalaxyChroniclesX. 
        #EpicSpaceChronicles. 
        #hyf_chronicles_prime.
        #HFYZenith. 
		  #TheHYFUnleashed. 
        #'EarthbornLegends-y8o'. 
        #'Sci-Fi-Vault' }

]

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> subscriptionChannels [
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
AIAYouTubeChannel >> buildChannel: channelHandle [

	[
		| episodes |
		self channelBuildInFileSystem: channelHandle.
		episodes := self channelEpisodeIds: channelHandle count: 10.
		AIAYouTubeEpisode new buildEpisodes: episodes first videoIDs: episodes second ] fork
]

{ #category : 'channel' }
AIAYouTubeChannel >> channelBuildInFileSystem: channelHandle [
	"Ensures the directory and description file for a specified YouTube channel exist, creating them if necessary."
	self channelEnsureDirectory: channelHandle.
	self channelEnsureDescription: channelHandle.
]

{ #category : 'channel' }
AIAYouTubeChannel >> channelDirectory: channelHandle [
	"Returns the directory path for the specified channel handle."
	^ self class channelDictionary , channelHandle
]

{ #category : 'channel' }
AIAYouTubeChannel >> channelEnsureDescription: channelHandle [
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
AIAYouTubeChannel >> channelEnsureDirectory: channelHandle [
	"Ensures the directory for the specified channel handle exists, creating it if necessary."
	| dir |
	dir := self channelDirectory: channelHandle.
	(File named: dir) exists ifFalse: [ 
		LibC runCommand: 'mkdir -p "' , dir , '"' ]
]

{ #category : 'channel' }
AIAYouTubeChannel >> channelEpisodeIds: channelHandle [
	"Returns a collection of episode IDs for a specified YouTube channel."
    ^ self channelEpisodeIds: channelHandle count: 10

]

{ #category : 'channel' }
AIAYouTubeChannel >> channelEpisodeIds: channelHandle count: count [
	"Returns a collection of episode IDs for a specified YouTube channel, limited to a specified count."
	| yt  result |
	yt := 'yt-dlp --flat-playlist --playlist-end ', count asString,
      ' --print "%(id)s" "https://www.youtube.com/@', channelHandle, '/videos" > /tmp/yt_ids.txt'.
	Transcript << 'YT: ' << yt << String lf.
	LibC runCommand: yt.
	result := (File named: '/tmp/yt_ids.txt') readStream contents asString lines.
	^ {channelHandle. result}
]
