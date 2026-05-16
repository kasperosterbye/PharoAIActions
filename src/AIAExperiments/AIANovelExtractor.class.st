Class {
	#name : 'AIANovelExtractor',
	#superclass : 'Object',
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'as yet unclassified' }
AIANovelExtractor class >> getNovel: videoId [
    ^ self new getNovel: videoId
]

{ #category : 'as yet unclassified' }
AIANovelExtractor >> getNovel: videoId [
    | novel |
    (File named: (self vttPathFor: videoId)) exists
        ifFalse: [ self ytdlp: videoId ].
    novel := self parseVtt: videoId.
    (File named: (self novelPathFor: videoId)) writeStream 
        nextPutAll: novel;
        close.
    ^ novel
]

{ #category : 'as yet unclassified' }
AIANovelExtractor >> novelPathFor: videoId [
    ^ '/Users/kasper/Downloads/NV_' , videoId , '.txt'
]

{ #category : 'as yet unclassified' }
AIANovelExtractor >> old_videoIdsForChannel: channelHandle [
    | result |
    result := ReadWriteStream on: String new.
    LibC runCommand: 'yt-dlp --flat-playlist --print id "https://www.youtube.com/@' , 
			channelHandle , '" > /tmp/yt_ids.txt'.
    ^ (File named: '/tmp/yt_ids.txt') readStream contents asString lines 
        reject: [ :line | line trimSeparators isEmpty ]
]

{ #category : 'as yet unclassified' }
AIANovelExtractor >> parseVtt: videoId [
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
AIANovelExtractor >> videoIdsForChannel: channelHandle [
    | lineNumbers lines |
	 lineNumbers := -1.
    LibC runCommand: 'yt-dlp --flat-playlist --playlist-end ', lineNumbers asString ,' --print "%(title)s$%(duration)s$%(id)s" "https://www.youtube.com/@' , channelHandle , '" > /tmp/yt_ids.txt'.
    lines := (File named: '/tmp/yt_ids.txt') readStream contents asString lines 
        reject: [ :line | line trim isEmpty ].
    ^ lines collect: [ :line | (line select: [ :char | char asciiValue < 128 ]) splitOn: $$ ]
]

{ #category : 'as yet unclassified' }
AIANovelExtractor >> vttPathFor: videoId [
    ^ '/Users/kasper/Downloads/YT_' , videoId , '.en.vtt'
]

{ #category : 'as yet unclassified' }
AIANovelExtractor >> ytdlp: videoId [
    | command |
    command := 'yt-dlp --write-auto-sub --skip-download --sub-lang en -o "/Users/kasper/Downloads/YT_%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' , videoId , '"'.
    LibC runCommand: command
]
