"
# AIAYouTubeEpisode

`AIAYouTubeEpisode` represents the workflow for fetching, normalising, and storing transcript and metadata files for a single YouTube episode/video.

The class is intended to be used as part of a YouTube ingestion pipeline where a channel has already been identified and local storage conventions are managed elsewhere. An instance is configured with a channel name, then asked to fetch a transcript or metadata for a YouTube video id. The class delegates the actual download work to `yt-dlp`, reads the resulting subtitle file from disk, converts the VTT subtitle content into plain transcript text, and writes the final result into the configured channel directory.

## Purpose and role in the system

The main responsibility of `AIAYouTubeEpisode` is to turn a YouTube video id into local artefacts:

- a cleaned plain-text transcript file, named after the episode id;
- optionally, a metadata file containing selected fields from `yt-dlp`;
- temporary VTT subtitle files, which are downloaded and then removed after successful transcript extraction.

This class is useful when YouTube videos are treated as source material for later processing, such as:

- semantic indexing;
- summarisation;
- large language model prompting;
- archival of talks, interviews, podcasts, lectures, or narrated material;
- building a local corpus of channel episodes.

`AIAYouTubeEpisode` does not model the full YouTube domain. It is deliberately procedural and file-oriented: given a channel and an episode id, it attempts to obtain subtitles, clean them, and persist the result. Higher-level concerns such as discovering videos, maintaining channel catalogues, scheduling downloads, or analysing transcripts are expected to live elsewhere.

## Main collaborators and dependencies

### `AIAYouTubeChannel`

`AIAYouTubeEpisode` relies on `AIAYouTubeChannel` for channel-wide configuration:

- `AIAYouTubeChannel channelDictionary` supplies the base directory in which downloaded artefacts are stored.
- `AIAYouTubeChannel transcriptLanguages` supplies the ordered list of subtitle languages to try when fetching transcripts.

The order of `transcriptLanguages` is significant. `episodeFetch:` tries each language in sequence and returns as soon as one language produces a readable transcript.

### `yt-dlp`

The class shells out to `yt-dlp` to communicate with YouTube.

For transcript fetching, it uses `yt-dlp` with:

- `--write-auto-sub`;
- `--skip-download`;
- `--sub-lang <language>`;
- an output template based on the YouTube video id.

For metadata fetching, it uses `yt-dlp --print` to extract selected fields and redirect them into a metadata text file.

Because `yt-dlp` is an external executable, it must be installed and available on the operating system path used by the Pharo image.

### `LibC`

Shell commands are executed through `LibC runCommand:`. The class assumes that command-line execution is permitted in the host environment and that the Pharo image has suitable access to the filesystem and the `yt-dlp` executable.

### Filesystem

The class is tightly coupled to the local filesystem. It reads, writes, and deletes files using the paths derived from `AIAYouTubeChannel channelDictionary`, the current `channel`, the episode id, and the current subtitle `language`.

The expected output files are:

- `<channel-directory>/<episodeId>.txt` for the cleaned transcript;
- `<channel-directory>/<episodeId>_meta.txt` for metadata;
- `<base-directory>/<episodeId>.<language>.vtt` as the temporary VTT subtitle file.

## Important invariants and design constraints

### The `channel` must be set before fetching or writing episode files

An instance should be configured with `channel:` before calling methods that write channel-specific files. The channel is used to construct the transcript and metadata destination directory.

If `channel` is left as its default empty string, generated paths may point at the base channel dictionary rather than a specific channel subdirectory.

### The `language` slot is transient workflow state

The `language` instance variable is set internally while `episodeFetch:` iterates over `AIAYouTubeChannel transcriptLanguages`.

It determines the VTT filename expected by `episodeTranscript:` and `episodeVttPath:`. It should be treated as internal state of the fetching process rather than as a stable public property of the episode.

### Episode ids are expected to be YouTube video ids

Most instance-side methods expect a plain YouTube video id such as `jrP7buPo2yA`, not a full YouTube URL.

The class-side `episodeFetch:` method contains convenience logic for extracting the `v=` parameter from a YouTube URL, but the instance protocol is primarily id-based.

### The class assumes a particular VTT shape

`episodeTranscript:` performs a simple transformation over the downloaded VTT file:

- it removes the first three lines;
- it removes empty or blank lines;
- it keeps only lines containing markup;
- it removes alignment metadata lines;
- it strips HTML/XML-like tags;
- it inserts line breaks after sentence-ending full stops.

This works for the VTT structure produced by `yt-dlp` for many YouTube subtitles, especially auto-generated subtitles, but it is not a general-purpose VTT parser. If YouTube changes its subtitle format, or if manually authored subtitles differ significantly, the extraction may need to be revised.

### Failure is represented as transcript text

When transcript extraction fails, the class returns and writes a string beginning with:

`***YouTubeEpisode Error***`

This means callers should check for this prefix if they need to distinguish a successful transcript from an error report. The current design favours leaving a diagnostic artefact on disk over raising an exception to the caller.

### Temporary VTT files are deleted only after successful extraction

When `episodeFetch:` successfully extracts a transcript, it deletes the downloaded VTT file. If all language attempts fail, temporary VTT files may remain, depending on where the failure occurred.

### Directories are assumed to exist

The class writes to paths derived from the channel dictionary and channel name. It does not create missing directories. The caller or channel-management layer should ensure that the target directory structure exists and is writable.

### Shell command construction assumes trusted inputs

The command strings are built by concatenating the episode id, language, and paths into shell commands. These values should therefore be treated as trusted or sanitised before use. In particular, arbitrary user-supplied strings should not be passed directly as episode ids or channel names in a security-sensitive environment.

## Illustrative usage examples

### Fetch and store the transcript for a known video id

```smalltalk
| episode transcript |
episode := AIAYouTubeEpisode new.
episode channel: 'Computerphile'.

transcript := episode episodeFetch: 'jrP7buPo2yA'.
```

This attempts to download subtitles for the video id `jrP7buPo2yA`, trying the languages configured by `AIAYouTubeChannel transcriptLanguages` in order. The first successfully extracted transcript is written to the channel directory as:

```text
<channelDictionary>/Computerphile/jrP7buPo2yA.txt
```

The returned value is the transcript text, or an error string beginning with `***YouTubeEpisode Error***` if no configured language could be read.

### Fetch transcript and metadata for an episode

```smalltalk
| episode |
episode := AIAYouTubeEpisode new.
episode channel: 'Computerphile'.

episode episodeFetch: 'jrP7buPo2yA'.
episode episodeMeta: 'jrP7buPo2yA'.
```

This stores both the cleaned transcript and a metadata file for the same YouTube video. The metadata file contains selected fields printed by `yt-dlp`, including the title, uploader id, video id, duration, upload date, and description.

Use this pattern when building a local archive where each episode should have both human-readable transcript content and basic descriptive metadata available for later indexing or analysis.
"
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
