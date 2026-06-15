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
AIAYouTubeChannel class >> channels [
	"Returns an array of YouTube channel names for novel content"
    ^ { 
		'Subscription' -> self subscriptionChannels . 
		'Novel' -> self novelChannels . 
		'Smalltalk' -> self smalltalkChannels . 
		'@esugboard' -> self esugboardPlaylists.
		'Misc' -> { 'Misc' } } asOrderedCollection 

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
AIAYouTubeChannel class >> episodeUpdateLimit [
	^ 25 asString
]

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> esugboardPlaylists [
	"yt-dlp --flat-playlist --print ""%(id)s %(title)s"" ""https://www.youtube.com/@esugboard/playlists"" "
	| lists |
	lists := 'ESUG 2025$PLJ5nSnWzQXi94CahnvTIO0F69oOdGJ3Xb
ESUG 2024: Show Us Your Project$PLJ5nSnWzQXi89jwnBCmGPh9xG6shuvuwb
ESUG 2024$PLJ5nSnWzQXi-uyYOZIVgXg1up_bclQc7e
ESUG 2023$PLJ5nSnWzQXi8-w5MAt_Rf-OjNDtBME7nK
ESUG 20222 - ShowUsYourProject$PLJ5nSnWzQXi-QLQViXAR41B0KdsSb4-nq
ESUG 2022$PLJ5nSnWzQXi_7LGwiSa-8VwYXELwFQLBt
ESUG 2018$PLJ5nSnWzQXi9RhA8zyKw_qelUpVVlumV9
ESUG 2019$PLJ5nSnWzQXi8DPNpy1jCkjE4yE0WUtDP2
ESUG 2017$PLJ5nSnWzQXi_THfKwhzxFwbXy00YTi0uv
IWST16$PLJ5nSnWzQXi-hDyGVkyohvKqAgGxQyloy
ESUG 2016$PLJ5nSnWzQXi8pkvGyi1ZniLcAu_J8OFRs
ESUG 2015$PLJ5nSnWzQXi9rnk77bTf-juPt5I6-ered
IWST 2014$PLJ5nSnWzQXi-xeYIVRM2kxPbdCtccmNcj
ESUG 2014$PLJ5nSnWzQXi_6yyRLsMMBqG8YlwfhvB0X
ESUG 2013$PLJ5nSnWzQXi_K_cQxWOLadk3TQTsS4Rys
Smalltalk Misc$PL53E5DACB81D86034
ESUG 2009$PL74E35D8EC7E756AE
ESUG 2010$PL431285A978F581BB
ESUG 2008$PL4A297B9019B3884D
Deep into Smalltalk$PL843D1D545F9F52B6
ESUG 2011$PL813665D04A2E4C0A
Favorites$FLO-vBhaKVZf0al-ISMMPvRw
IWST2011$PLBFA36B5236B77AD7' lines.
	^ lists collect: [ :l | (l splitOn: $$) first ]
	
]

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> novelChannels [
	"Returns an array of YouTube channel names for novel content"
    ^ { #MiscSciFi.
		  #DarkspaceAudio. 
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
AIAYouTubeChannel class >> smalltalkChannels [
	"Returns an array of YouTube channel names for novel content"
    ^ {
		#'Pharo-projectOrg'.
		#esugboard. 
		#UKSTUG.
		#inrialearninglab.
		#CincomSmalltalk.
		#gtoolkit }

]

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> subscriptionChannels [
	"Returns an array of YouTube channel names for subscription"
    ^ { #HouseofEl.
		  #'HouseofEl-AI'.
		  #TLDRnewsEU.
		  #'dw_podcasts'.
        #TwoBitDaVinci. 
        #JustHaveaThink. 
        #SabineHossenfelder. 
        #UKSTUG.
		  #esugboard.
        #UndecidedTechnology. 
        #parthknowsai. 
        #PracticalEngineeringChannel. 
        #ThunderboltsProject. 
        #SeethePattern }
]

{ #category : 'as yet unclassified' }
AIAYouTubeChannel class >> transcriptLanguages [ 
	^ { 'en'. 'fr'. 'es'. 'pt' }
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

{ #category : 'yt-dlp' }
AIAYouTubeChannel >> channelEnsureDescription: channelHandle [
	"Ensures the channel description file exists, creating it if necessary."

	| path command raw |
	path := (self channelDirectory: channelHandle) , '/description.txt'.
	"(File named: path) exists ifTrue: [ ^ self ]."
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

{ #category : 'yt-dlp' }
AIAYouTubeChannel >> channelEpisodeIds: channelHandle [
	"Returns a collection of episode IDs for a specified YouTube channel, limited to a specified count."
	| yt  result |
	yt := 'yt-dlp --flat-playlist --playlist-end ', AIAYouTubeChannel episodeUpdateLimit,
      ' --print "%(id)s" "https://www.youtube.com/@', channelHandle, '/videos" > /tmp/yt_ids.txt'.
	LibC runCommand: yt.
	result := (File named: '/tmp/yt_ids.txt') readStream contents asString lines.
	^ {channelHandle. result}
]

{ #category : 'yt-dlp' }
AIAYouTubeChannel >> channelEpisodeIds: channelHandle count: count [
	"Returns a collection of episode IDs for a specified YouTube channel, limited to a specified count."
	| yt  result |
	yt := 'yt-dlp --flat-playlist --playlist-end ', count asString,
      ' --print "%(id)s" "https://www.youtube.com/@', channelHandle, '/videos" > /tmp/yt_ids.txt'.
	LibC runCommand: yt.
	result := (File named: '/tmp/yt_ids.txt') readStream contents asString lines.
	^ {channelHandle. result}
]

{ #category : 'channel' }
AIAYouTubeChannel >> channelEpisodesOnDisk: channelHandle [
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
AIAYouTubeChannel >> channelUpdate: channelHandle [
	"Fetch recent episode IDs from YouTube and download those not already on disk."
	
	| result youtubeIds localIds newIds episode |
	self channelBuildInFileSystem: channelHandle.
	result := self channelEpisodeIds: channelHandle.
	youtubeIds := result second reject: [ :id | id trim isEmpty ].
	localIds := self channelEpisodesOnDisk: channelHandle.
	newIds := youtubeIds reject: [ :id | localIds includes: id ].
	newIds isEmpty ifTrue: [ ^ self ].
	episode := AIAYouTubeEpisode new.
	episode channel: channelHandle.
	newIds do: [ :id |
		episode episodeFetch: id.
		episode episodeMeta: id ].
]
