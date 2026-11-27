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

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeDownloadVtt: episodeId [
    "Prefer manual subtitles, then automatic subtitles.
    Continue to the next option if an attempt fails."

    | success |

    #('en' 'en-orig') do: [ :lang |

        language := lang.

        success := [
            self
                episodeTryDownloadVtt: episodeId
                language: lang
                automatic: lang = 'en-orig'
        ]
            on: Error
            do: [ false ].

        success ifTrue: [
            ^ self episodeVttPath: episodeId ]
    ].

    self error:
        'No usable YouTube subtitles for episode: ', episodeId
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeFetch: episodeId [
    "Fetch a transcript, preferring YouTube subtitles.
    Fall back to Gemini if necessary.
    Preserve existing files if both fail."

    | transcript path |

    transcript := self episodeTranscriptWithFallback: episodeId.

    path := (self episodePath: episodeId),
        episodeId, '.txt'.

    (File named: path) writeStream
        nextPutAll: transcript utf8Encoded;
        close.

    ^ path
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeFetch_old: episodeId [
	| transcript |
	transcript := [ 
			self episodeSplitSentences: 
				(GeminiApi transcribeYouTube: 'https://www.youtube.com/watch?v=' , episodeId )]
		on: Error
		do: [ :e | '***YouTubeEpisode Error*** ' , e messageText ].
	(File named: (self episodePath: episodeId) , episodeId , '.txt') writeStream
		nextPutAll: transcript utf8Encoded;
		close
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeGeminiTranscript: episodeId [
    "Transcribe a YouTube video using Gemini."

    | url transcript |

    url := 'https://www.youtube.com/watch?v=', episodeId.

    transcript := GeminiApi transcribeYouTube: url.

    (transcript isNil or: [ transcript trimBoth isEmpty ])
        ifTrue: [
            self error: 'Gemini returned an empty transcript' ].

    ^ self episodeSplitSentences: transcript
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
AIAYouTubeEpisode >> episodeReload: episodeId [
    "Reload an episode using YouTube subtitles or Gemini.
    Preserve the existing transcript if retrieval fails.
    Preserve the read/unread state."

    | transcript wasRead path |

    transcript := self episodeTranscriptWithFallback: episodeId.

    wasRead := self episodeIsRead: episodeId.

    self episodeMeta: episodeId.

    path := (self episodePath: episodeId),
        episodeId, '.txt'.

    (File named: path) writeStream
        nextPutAll: transcript utf8Encoded;
        close.

    wasRead ifTrue: [
        self episodeMarkAsRead: episodeId ].

    ^ path
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeReload_old: episodeId [
    "Reload an episode, preserving its existing transcript if Gemini fails."

    | transcript wasRead |

    transcript := self episodeSplitSentences:
        (GeminiApi transcribeYouTube:
            'https://www.youtube.com/watch?v=', episodeId).

    wasRead := self episodeIsRead: episodeId.

    self episodeMeta: episodeId.

    (File named: (self episodePath: episodeId), episodeId, '.txt')
        writeStream
            nextPutAll: transcript utf8Encoded;
            close.

    wasRead ifTrue: [
        self episodeMarkAsRead: episodeId ].
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeSplitSentences: aString [
	"Break after '. ' unless the word before the full stop is a known abbreviation."
	| abbreviations pieces |
	abbreviations := #('Dr' 'Mr' 'Mrs' 'Ms' 'Prof' 'St').
	pieces := aString splitOn: '. '.
	^ String streamContents: [ :stream |
		pieces allButLast do: [ :piece |
			stream nextPutAll: piece.
			(abbreviations includes: (piece substrings ifEmpty: [ #('') ]) last)
				ifTrue: [ stream nextPutAll: '. ' ]
				ifFalse: [ stream nextPut: $.; nextPut: Character lf ] ].
		stream nextPutAll: pieces last ]
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTextFromVtt: vttText [
    "Convert VTT subtitles into plain text, removing timestamps,
    formatting tags, and consecutive duplicate lines."

    | result previous text |

    result := OrderedCollection new.
    previous := ''.

    vttText lines do: [ :line |
        text := line trimBoth.

        ((text isEmpty)
            or: [ text = 'WEBVTT'
            or: [ (text beginsWith: 'Kind:')
            or: [ (text beginsWith: 'Language:')
            or: [ text includesSubstring: '-->' ] ] ] ])
            ifFalse: [
                text := text
                    copyWithRegex: '<[^>]*>'
                    matchesReplacedWith: ''.

                text := text
                    copyReplaceAll: '&gt;' with: '>';
                    copyReplaceAll: '&lt;' with: '<';
                    copyReplaceAll: '&amp;' with: '&'.

                text := text trimBoth.

                (text isNotEmpty and: [ text ~= previous ])
                    ifTrue: [
                        result add: text.
                        previous := text ] ] ].

    ^ String lf join: result
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTranscript: episodeId [
    "Read a downloaded VTT file and return its plain text."

    | file vttText |

    file := (self episodeVttPath: episodeId) asFileReference.

    file exists ifFalse: [
        self error: 'VTT file not found: ', file fullName ].

    vttText := file contents.

    ^ self episodeTextFromVtt: vttText
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTranscriptWithFallback: episodeId [
    "Prefer YouTube subtitles, falling back to Gemini."

    | transcript |

    transcript := [
        self episodeDownloadVtt: episodeId.
        self episodeTranscript: episodeId
    ]
        on: Error
        do: [ :error | nil ].

    (transcript isNotNil and: [
        transcript trimBoth isNotEmpty ])
        ifTrue: [ ^ transcript ].

    ^ self episodeGeminiTranscript: episodeId
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeTryDownloadVtt: episodeId language: lang automatic: isAutomatic [
    "Try downloading subtitles.
    Answer true only when the VTT file exists."

    | directory path file command options |

    language := lang.
    directory := self episodePath: episodeId.
    path := self episodeVttPath: episodeId.
    file := File named: path.

    file exists ifTrue: [ file delete ].

    options := isAutomatic
        ifTrue: [ '--write-auto-subs' ]
        ifFalse: [ '--write-subs' ].

    command := 'yt-dlp --skip-download ',
        options, ' ',
        '--sub-langs ', lang, ' ',
        '--sub-format vtt ',
        '-o "', directory, '/%(id)s.%(ext)s" ',
        '"https://www.youtube.com/watch?v=', episodeId, '"'.

    LibC runCommand: command.

    ^ file exists
]

{ #category : 'episode' }
AIAYouTubeEpisode >> episodeVttPath: episodeId [
    "Return the path of the downloaded VTT subtitle file."

    ^ (self episodePath: episodeId),
        '/', episodeId, '.', language, '.vtt'
]

{ #category : 'initialization' }
AIAYouTubeEpisode >> initialize [
    super initialize.
    channel := ''.
    language := 'en-orig'
]
