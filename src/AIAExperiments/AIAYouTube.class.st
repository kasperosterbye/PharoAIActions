Class {
	#name : 'AIAYouTube',
	#superclass : 'Object',
	#instVars : [
		'title'
	],
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'as yet unclassified' }
AIAYouTube class >> getNovel: youtube [
	"https://www.youtube.com/watch?v=jrP7buPo2yA&t=87s"
	| youtubeID |
	youtubeID := youtube.
	(youtubeID first: 'https:' size) = 'https:'
		ifTrue: [ | vPos |
			vPos := (youtube indexOfSubCollection: 'v=' startingAt: 1) + 2.
			youtubeID := youtube copyFrom: vPos to: vPos + 10.
			].
    ^ self new getNovel: youtubeID
]

{ #category : 'as yet unclassified' }
AIAYouTube >> getNovel: videoId [
    | novel |
    self ytdlp: videoId.
    novel := self parseVtt: videoId.
    (File named: (self novelPathFor: videoId)) writeStream 
        nextPutAll: novel;
        close.
	 (File named: (self vttPathFor: videoId)) delete.
    ^ novel
]

{ #category : 'as yet unclassified' }
AIAYouTube >> novelPathFor: videoId [
    ^ '/Users/kasper/Downloads/NV_' , videoId , '.txt'
]

{ #category : 'as yet unclassified' }
AIAYouTube >> parseVtt: videoId [
    | lines result |
    lines := OrderedCollection 
		newFromArray: 
			(File named: (self vttPathFor: videoId)) readStream contents asString lines.
	 lines removeFirst: 3.
	 lines removeAllSuchThat: [ :line | line isEmpty or: [ line = ' ' ] ].
	 lines removeAllSuchThat: [ :line | (line includes: $<) not ].
	 lines removeAllSuchThat: [ :line | line includesAll: 'align:start position:0%'].
    result := WriteStream on: ''.
	 1 to: lines size do: [ :line | 
		result << ((lines at: line) copyWithRegex: '<[^>]*>' matchesReplacedWith: '' ) << ' ' ].
    ^ result contents copyReplaceAll: '. ' with: ('.', String cr).
]

{ #category : 'as yet unclassified' }
AIAYouTube >> videoIdsForChannel: channelHandle [
    | lineNumbers lines |
	 lineNumbers := -1.
    LibC runCommand: 'yt-dlp --flat-playlist --playlist-end ', lineNumbers asString ,' --print "%(title)s$%(duration)s$%(id)s" "https://www.youtube.com/@' , channelHandle , '" > /tmp/yt_ids.txt'.
    lines := (File named: '/tmp/yt_ids.txt') readStream contents asString lines 
        reject: [ :line | line trim isEmpty ].
    ^ lines collect: [ :line | (line select: [ :char | char asciiValue < 128 ]) splitOn: $$ ]
]

{ #category : 'as yet unclassified' }
AIAYouTube >> vttPathFor: videoId [
    ^ '/Users/kasper/Downloads/YT_' , videoId , '.en.vtt'
]

{ #category : 'as yet unclassified' }
AIAYouTube >> ytdlp: videoId [
    | command |
    command := 'yt-dlp --write-auto-sub --skip-download --sub-lang en -o "/Users/kasper/Downloads/YT_%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' , videoId , '"'.
    LibC runCommand: command
]

{ #category : 'as yet unclassified' }
AIAYouTube >> ytdlpMeta: videoId [
    | raw |
    LibC runCommand: 'yt-dlp --skip-download --print "%(title)s$%(description)s" "https://www.youtube.com/watch?v=' , videoId , '" > /Users/kasper/Downloads/yt_meta.txt'.
    raw := (File named: '/Users/kasper/Downloads/yt_meta.txt') readStream contents asString.
    raw := raw select: [ :char | char asciiValue < 128 ].
	 raw := raw splitOn: $$.
	 ^ { 'title' -> raw first. 'description' -> raw second } asDictionary 
]
