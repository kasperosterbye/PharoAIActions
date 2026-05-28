Class {
	#name : 'AIAYouTubeUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'channelTypeList',
		'channelList',
		'episodeList',
		'descriptionText',
		'episodeDetail'
	],
	#category : 'AIAExperiments-Novels',
	#package : 'AIAExperiments',
	#tag : 'Novels'
}

{ #category : 'instance creation' }
AIAYouTubeUI class >> open [
	"Open the YouTube browser UI."
	
	<example>
	^ self new open
]

{ #category : 'initialization' }
AIAYouTubeUI >> channelChangeAction [
	channelList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [ self showChannel: selected ] ].
	channelList whenActivatedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [
			[
				self window title: 'Updating: ' , selected.
				AIAYouTubeChannel new channelUpdate: selected.
				self window title: 'YouTube Browser'.
				self showChannel: selected ]
					forkAt: Processor userBackgroundPriority
					named: 'YouTube update: ' , selected ] ].
]

{ #category : 'initialization' }
AIAYouTubeUI >> channelTypeChangeAction [
	channelTypeList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [ self showChannelsForType: selected ] ].
]

{ #category : 'initialization' }
AIAYouTubeUI >> defaultLayout [
	| topPanel leftPanel |
	topPanel := SpPanedLayout newVertical
		add: (SpPanedLayout newHorizontal
			add: channelTypeList;
			add: channelList;
			yourself);
		add: descriptionText;
		positionOfSlider: 200;
		yourself.
	leftPanel := SpPanedLayout newVertical
		add: topPanel;
		add: episodeList;
		yourself.
	^ SpPanedLayout newHorizontal
		add: leftPanel;
		add: episodeDetail;
		yourself.
]

{ #category : 'initialization' }
AIAYouTubeUI >> descriptionFor: aChannelHandle [
	| path file |
	path := AIAYouTubeChannel new channelDirectory: aChannelHandle , '/description.txt'.
	file := File named: path.
	^ file exists
		ifTrue: [ file readStream contents utf8Decoded ]
		ifFalse: [ 'Not loaded yet' ]
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeChangeAction [
	episodeList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItems.
		selected ifNotNil: [ self showEpisodes: selected ] ].
	episodeList display: [ :episodeId |
		self episodeTitleFor: episodeId forChannel: channelList selectedItem ].
	episodeList whenActivatedDo: [ :selection |
		| selected url |
		selected := selection selectedItem.
		selected ifNotNil: [
			url := 'https://www.youtube.com/watch?v=' , selected.
			LibC runCommand: 'open -a Safari "' , url , '"' ] ].
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeDateFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines |
	path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) , '/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ '00000000' ].
	lines := file readStream contents asString lines.
	lines size < 5 ifTrue: [ ^ '00000000' ].
	^ lines at: 5
]

{ #category : 'initialization' }
AIAYouTubeUI >> episodeDetailFor: anEpisodeId forChannel: aChannelHandle [
	"Parse the meta file and return title, formatted date, and first paragraph."
	| details |
	details := 
		(self episodeMataDetailFor: anEpisodeId forChannel: aChannelHandle),
		(self episodeTextDetailFor: anEpisodeId forChannel: aChannelHandle).
	^ "Microdown asRichText:" details
]

{ #category : 'initialization' }
AIAYouTubeUI >> episodeMataDetailFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines title date desc details |
	path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) ,
		'/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ 'Not loaded yet' ].
	lines := file readStream contents utf8Decoded lines.
	lines size < 5 ifTrue: [ ^ 'Meta incomplete' ].
	title := '# Channel: ', aChannelHandle, String lf.
	title := title, '## Episode: ', lines first.
	date  := '> ', (self formatDate: lines fifth).
	desc := ' ', lines sixth.
	details := title , String lf , date , String lf , String lf , desc.
	^ details
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeTextAction [
	episodeDetail whenSubmitDo: [ :a | 
		AIAPresenter onText: ('What is the essence of the descrition I gave you. Please let your response be at most 10 line. Start the title with the Cannel name and Episode Name'
		q0: [ a ])]
]

{ #category : 'initialization' }
AIAYouTubeUI >> episodeTextDetailFor: anEpisodeId forChannel: aChannelHandle [
	| text file lines |
	text := (AIAYouTubeChannel new channelDirectory: aChannelHandle) ,
		'/' , anEpisodeId , '.txt'.
	file := File named: text.
	file exists ifFalse: [ ^ '' ].
	lines := file readStream contents utf8Decoded.
	^ String lf, String lf, '### Episode contents', String lf, '```text', String lf, lines, String lf, '```'
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeTitleFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines date title |
	aChannelHandle ifNil: [ ^ anEpisodeId ].
	path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) , '/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ anEpisodeId ].
	lines := file readStream contents utf8Decoded lines.
	lines size < 5 ifTrue: [ ^ anEpisodeId ].
	date := self formatDate: (lines at: 5).
	title := lines first.
	^ date , ' ' , title
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodesFor: aChannelHandle [
	| dir entries |
	aChannelHandle ifNil: [ ^ #() ].
	dir := FileLocator root / 'Users' / 'kasper' / 'D' / 'YouTube' / aChannelHandle.
	dir exists ifFalse: [ ^ #() ].
	entries := (dir entries
		select: [ :entry | entry basename endsWith: '_meta.txt' ])
		collect: [ :entry | entry basename copyFrom: 1 to: entry basename size - '_meta.txt' size ].
	^ entries sort: [ :a :b |
		(self episodeDateFor: a forChannel: aChannelHandle) >
		(self episodeDateFor: b forChannel: aChannelHandle) ]
]

{ #category : 'initialization' }
AIAYouTubeUI >> formatDate: aDateString [
	"Convert YYYYMMDD to DD-MM-YYYY."
	aDateString size < 8 ifTrue: [ ^ aDateString ].
	^ (aDateString copyFrom: 1 to: 4) , '-'
		, (aDateString copyFrom: 5 to: 6) , '-'
		, (aDateString copyFrom: 7 to: 8)
]

{ #category : 'initialization' }
AIAYouTubeUI >> initializePresenters [
	super initializePresenters.
	channelTypeList := self newList.
	channelList := self newList.
	episodeList := self newList.
	episodeList beMultipleSelection.
	descriptionText := self newText.
	episodeDetail := self newText.
	channelTypeList items: AIAYouTubeChannel channels asOrderedDictionary keys.
	self channelTypeChangeAction.
	self channelChangeAction.
	self episodeChangeAction.
	self episodeTextAction.
]

{ #category : 'initialization' }
AIAYouTubeUI >> initializeWindow: aWindowPresenter [
	"Set the window title."
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'YouTube Browser'.
]

{ #category : 'initialization' }
AIAYouTubeUI >> showChannel: aChannelHandle [
	aChannelHandle ifNil: [ ^ self ].
	descriptionText text: (self descriptionFor: aChannelHandle).
	episodeList items: (self episodesFor: aChannelHandle).
	episodeDetail text: ''.
]

{ #category : 'initialization' }
AIAYouTubeUI >> showChannelsForType: aTypeString [
	| channels |
	aTypeString ifNil: [ ^ self ].
	channels := AIAYouTubeChannel channels asDictionary at: aTypeString .
	channelList items: channels.
	descriptionText text: ''.
	episodeList items: #().
	episodeDetail text: ''.
]

{ #category : 'initialization' }
AIAYouTubeUI >> showEpisode: anEpisodeId [
	anEpisodeId ifNil: [ ^ self ].
	episodeDetail text: (self episodeDetailFor: anEpisodeId forChannel: channelList selectedItem).
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> showEpisodes: anEpisodeIdCollection [
	| combined |
	combined := anEpisodeIdCollection 
		inject: '' 
		into: [ :acc :id |
			acc , String lf, String lf,
			(self episodeDetailFor: id forChannel: channelList selectedItem) , String lf ].
	episodeDetail text: (Microdown asRichText: combined).
]
