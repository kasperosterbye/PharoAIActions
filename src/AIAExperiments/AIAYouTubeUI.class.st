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
	^ self new open
]

{ #category : 'initialization' }
AIAYouTubeUI >> channelChangeAction [
	channelList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [ self showChannel: selected ] ].
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
	| leftPanel1 leftPanel2 leftPanel  |
	leftPanel1 := SpPanedLayout newHorizontal 
		add: channelTypeList;
		add: channelList;
		yourself.
	leftPanel2 := SpPanedLayout newVertical
		add: descriptionText ;
		add: episodeList;
		yourself.
	leftPanel := SpPanedLayout newVertical add: leftPanel1 ; add: leftPanel2; yourself.
	^ SpPanedLayout newHorizontal
		add: leftPanel;
		add: episodeDetail;
		yourself.
]

{ #category : 'initialization' }
AIAYouTubeUI >> descriptionFor: aChannelHandle [
	"Read description.txt for the channel, or report not loaded."
	| path file |
	path := AIAYouTubeChannel new channelDirectory: aChannelHandle , '/description.txt'.
	file := File named: path.
	^ file exists
		ifTrue: [ file readStream contents asString ]
		ifFalse: [ 'Not loaded yet' ]
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeChangeAction [
	episodeList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [ self showEpisode: selected ] ].
	episodeList display: [ :episodeId |
		self episodeTitleFor: episodeId forChannel: channelList selectedItem ].
]

{ #category : 'initialization' }
AIAYouTubeUI >> episodeDetailFor: anEpisodeId forChannel: aChannelHandle [
	"Parse the meta file and return title, formatted date, and first paragraph."
	| details |
	details := 
		(self episodeMataDetailFor: anEpisodeId forChannel: aChannelHandle),
		(self episodeTextDetailFor: anEpisodeId forChannel: aChannelHandle).
	^ Microdown asRichText: details
]

{ #category : 'initialization' }
AIAYouTubeUI >> episodeMataDetailFor: anEpisodeId forChannel: aChannelHandle [
	"Parse the meta file and return title, formatted date, and first paragraph."
	| path file lines title date desc details |
	path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) ,
		'/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ 'Not loaded yet' ].
	lines := file readStream contents asString lines.
	lines size < 5 ifTrue: [ ^ 'Meta incomplete' ].
	title := '# ', lines first.
	date  := '> ', (self formatDate: lines fifth).
	desc := ' ', lines sixth.
	details := title , String lf , date , String lf , String lf , desc.
	^ details
]

{ #category : 'initialization' }
AIAYouTubeUI >> episodeTextDetailFor: anEpisodeId forChannel: aChannelHandle [
	"Parse the meta file and return title, formatted date, and first paragraph."
	| text file lines|
	text := (AIAYouTubeChannel new channelDirectory: aChannelHandle) ,
		'/' , anEpisodeId , '.txt'.
	file := File named: text.
	file exists ifFalse: [ ^ 'Not loaded yet' ].
	lines := file readStream contents asString.
	^ String lf, String lf, '## Episode contents', String lf, lines
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeTitleFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines |
	aChannelHandle ifNil: [ ^ anEpisodeId ].
	path := (AIAYouTubeChannel new channelDirectory: aChannelHandle), '/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ anEpisodeId ].
	lines := file readStream contents asString lines.
	lines isEmpty ifTrue: [ ^ anEpisodeId ].
	^ lines first.
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodesFor: aChannelHandle [
	| dir |
	aChannelHandle ifNil: [ ^ #() ].
	dir := FileLocator root / 'Users' / 'kasper' / 'D' / 'YouTube' / aChannelHandle.
	dir exists ifFalse: [ ^ #() ].
	^ (dir entries
		select: [ :entry | entry basename endsWith: '_meta.txt' ])
		collect: [ :entry | entry basename copyFrom: 1 to: entry basename size - '_meta.txt' size ]
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
	descriptionText := self newText.
	episodeDetail := self newText.
	channelTypeList items: #( 'Subscription' 'Novel' ) asOrderedCollection .
	self channelTypeChangeAction.
	self channelChangeAction.
	self episodeChangeAction.
]

{ #category : 'initialization' }
AIAYouTubeUI >> initializeWindow: aWindowPresenter [
	"Set the window title."
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'YouTube Browser'.
]

{ #category : 'initialization' }
AIAYouTubeUI >> old_defaultLayout [
	| leftPanel centerPanel rightPanel |
	leftPanel := SpPanedLayout newVertical
		add: channelTypeList;
		add: channelList;
		yourself.
	rightPanel := SpPanedLayout newVertical
		add: descriptionText;
		add: episodeDetail;
		yourself.
	centerPanel := SpPanedLayout newHorizontal
		add: episodeList;
		add: rightPanel;
		yourself.
	^ SpPanedLayout newHorizontal
		add: leftPanel;
		add: centerPanel;
		yourself.
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
	channels := aTypeString = 'Subscription'
		ifTrue: [ AIAYouTubeChannel subscriptionChannels ]
		ifFalse: [ AIAYouTubeChannel novelChannels ].
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
