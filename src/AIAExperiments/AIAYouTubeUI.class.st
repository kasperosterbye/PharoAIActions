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
	#classInstVars : [
		'episodeUpdateLimit'
	],
	#category : 'AIAExperiments-YouTube',
	#package : 'AIAExperiments',
	#tag : 'YouTube'
}

{ #category : 'accessing' }
AIAYouTubeUI class >> channelDictionary [
	"Returns the directory path for storing YouTube channel data"
    ^ '/Users/kasper/D/YouTube/'
]

{ #category : 'accessing - structure variables' }
AIAYouTubeUI class >> channels [
	^ self channelsFromFile
]

{ #category : 'accessing - structure variables' }
AIAYouTubeUI class >> channelsFromFile [
	| result currentChannelsGroup currentChannels file |

	file := (self channelDictionary , 'channels.txt') asFileReference.
	result := OrderedCollection new.
	currentChannelsGroup := '**empty**'.
	currentChannels := OrderedCollection new.

	file contents lines do: [ :line |
		(line beginsWith: '# ') ifTrue: [
				currentChannels ifNotEmpty: [
					result add: currentChannelsGroup -> currentChannels ].
				currentChannelsGroup := line allButFirst: 2.
				currentChannels := OrderedCollection new ].	
		((line beginsWith: '- ') or: [ line beginsWith: '% ' ])  ifTrue: [
				currentChannels add: (line allButFirst: 2) asSymbol ] ].

		result add: currentChannelsGroup -> currentChannels.

	^ result
]

{ #category : 'accessing - structure variables' }
AIAYouTubeUI class >> channelsManualOnly [
	"Channels marked with % are not included in Update All"
	^ ((self channelDictionary , 'channels.txt') asFileReference contents lines
		select: [ :line | line beginsWith: '% ' ])
		collect: [ :line | (line allButFirst: 2) asSymbol ]


]

{ #category : 'accessing - structure variables' }
AIAYouTubeUI class >> channelsToAutoUpdate [
	| manual all |
	manual := self channelsManualOnly.
	all := OrderedCollection new.
	self channels do: [ :group | all addAll: group value ].
	^ (all reject: [ :handle | manual includes: handle ])
]

{ #category : 'examples' }
AIAYouTubeUI class >> ensureXMLParser [
	
	(Smalltalk globals includesKey: #XMLDOMParser) ifTrue: [ ^ self ].
	
	Metacello new
  		baseline: 'XMLParser';
  		repository: 'github://pharo-contributions/XML-XMLParser/src';
  		load.
]

{ #category : 'accessing' }
AIAYouTubeUI class >> episodeUpdateLimit [
	episodeUpdateLimit ifNil: [ episodeUpdateLimit := 2 ].
	^ episodeUpdateLimit 
]

{ #category : 'accessing' }
AIAYouTubeUI class >> episodeUpdateLimit: newLimit [
	episodeUpdateLimit := newLimit 
]

{ #category : 'examples' }
AIAYouTubeUI class >> new [ 
	self ensureXMLParser.
	^ super new
]

{ #category : 'instance creation' }
AIAYouTubeUI class >> open [
	"Open the YouTube browser UI."
	
	<example>
	^ self new open
]

{ #category : 'channel' }
AIAYouTubeUI >> channelChangeAction [
	channelList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [
			self showChannel: selected ] ].

	channelList whenActivatedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [
			[
				self window title: 'Updating: ' , selected.
				(self channelClassFor: selected) new
					channelUpdate: selected.
				self window title: 'YouTube Browser'.
				self showChannel: selected
			]
				forkAt: Processor userBackgroundPriority
				named: 'Channel update: ' , selected ] ]
]

{ #category : 'channel' }
AIAYouTubeUI >> channelClassFor: aChannel [
	^ (aChannel asString beginsWith: 'dr_')
		ifTrue: [ AIAdrChannel ]
		ifFalse: [ AIAYouTubeChannel ]
]

{ #category : 'channel' }
AIAYouTubeUI >> channelTypeChangeAction [
	channelTypeList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItem.
		selected ifNotNil: [ self showChannelsForType: selected ] ].
]

{ #category : 'channel' }
AIAYouTubeUI >> channelUpdateAll [
	[ self channelUpdateAllJob ]
		forkAt: Processor userBackgroundPriority
		named: 'Update all channels'
]

{ #category : 'channel' }
AIAYouTubeUI >> channelUpdateAllButton [
	|all| 
	all := self newButton
		label: 'Update All';
		help: 'Update all channels not marked with % in file channels.txt';
		action: [ self channelUpdateAll ].
	^ all
]

{ #category : 'channel' }
AIAYouTubeUI >> channelUpdateAllJob [
	| channels |
	channels := self class channelsToAutoUpdate.
	[ :job |
		job interruptBlock: [
			self window title: 'YouTube Browser'.
			^ self ].
		channels withIndexDo: [ :handle :index |
			job
				title: 'Updating channel: ' , handle asString , ' (' , index asString
						, ' of ' , channels size asString , ')';
				progress: (index - 1) / channels size.
			(self channelClassFor: handle) new channelUpdate: handle ].
		job progress: 1 ] asJob run.
	self window title: 'YouTube Browser'.
	self showChannel: channelList selectedItem
]

{ #category : 'layout' }
AIAYouTubeUI >> defaultLayout [
	| topPanel leftPanel |
	topPanel := SpPanedLayout newVertical
		add: (SpPanedLayout newHorizontal
			add: (SpBoxLayout newVertical 
				add: channelTypeList;
				add: (SpBoxLayout newHorizontal 
					add: self channelUpdateAllButton expand: false;
					add: self episodeUpdateLimitButton expand: false ));
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

{ #category : 'misc' }
AIAYouTubeUI >> descriptionFor: aChannelHandle [
	| path file |
	path := self class channelDictionary , aChannelHandle , '/description.txt'.
	file := File named: path.
	^ file exists
		ifTrue: [ file readStream contents asString  ]
		ifFalse: [ 'Not loaded yet' ]
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeChangeAction [
	episodeList bindKeyCombination: $r command asKeyCombination
            toAction: [self episodeToggleRead ].
	
	episodeList whenSelectionChangedDo: [ :selection |
		| selected |
		selected := selection selectedItems.
		selected ifNotNil: [ self showEpisodes: selected ] ].
	episodeList display: [ :episodeId |
		self episodeTitleFor: episodeId forChannel: channelList selectedItem ].
	episodeList whenActivatedDo: [ :selection |
		| selected url channel raw channelName|
		selected := selection selectedItem.
		channel :=  channelList selectedItem.
		(channel beginsWith: 'dr_')
			ifTrue: [ 
				raw := self episodeRawMetaDetailFor: selected forChannel: channel.
				channelName := channel allButFirst: 3.
				url := 'https://www.dr.dk/lyd/p1/', channelName , '/' , channelName, '-', 
						(raw fifth first: 4), '/', 
						(raw first asLowercase copyReplaceAll: ' ' with: '-' ), '-', selected .]
			ifFalse: [ url := 'https://www.youtube.com/watch?v=' , selected ].
			
		LibC runCommand: 'open -a Safari "' , url , '"'  ].
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeDateFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines |
	"path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) , '/' , anEpisodeId , '_meta.txt'."
	path := self class channelDictionary , aChannelHandle  , '/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ '00000000' ].
	lines := file readStream contents asString lines.
	lines size < 5 ifTrue: [ ^ '00000000' ].
	^ lines at: 5
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeDetailFor: anEpisodeId forChannel: aChannelHandle [
	"Parse the meta file and return title, formatted date, and first paragraph."
	| details |
	details := 
		(self episodeMetaDetailFor: anEpisodeId forChannel: aChannelHandle),
		(self episodeTextDetailFor: anEpisodeId forChannel: aChannelHandle).
	^ "Microdown asRichText:" details
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeMetaDetailFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines title date episodeId desc details |
	path := self class channelDictionary , aChannelHandle  ,
		'/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ 'Not loaded yet' ].
	lines := file readStream contents utf8Decoded lines.
	lines size < 5 ifTrue: [ ^ 'Meta incomplete' ].
	title := '# Channel: ', aChannelHandle, String lf.
	title := title, '## Episode: ', lines first.
	date  := '> ', (self formatDate: lines fifth).
	episodeId := 'YouTube id: ''', lines third , ''''.
	desc := ' ', lines sixth.
	details := title , String lf , date , String lf , String lf , episodeId, String lf, desc.
	^ details
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeRawMetaDetailFor: anEpisodeId forChannel: aChannelHandle [
	| path file |
	path := self class channelDictionary , aChannelHandle  ,
		'/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ 'Not loaded yet' ].
	^ file readStream contents utf8Decoded lines
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeTextAction [
	episodeDetail bindKeyCombination: $r command asKeyCombination
				toAction: [ self episodeToggleRead ].
	episodeDetail whenSubmitDo: [ :a | 
		| aiResponse |
		aiResponse := ('Please summarize in details the prompt I gave you? 
			Ignore the text before "Episode contents" in your response. 
			Please let your response be in the same language as the description text'
		q0: [ a ]).
		AIAPresenter onText: (aiResponse copyReplaceAll: '$' with: '\$').
		].
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeTextDetailFor: anEpisodeId forChannel: aChannelHandle [
	| text file lines |
	text := self class channelDictionary , aChannelHandle ,
		'/' , anEpisodeId , '.txt'.
	file := File named: text.
	file exists ifFalse: [ ^ '' ].
	lines := file readStream contents utf8Decoded.
	^ String lf, String lf, '### Episode contents', String lf, '```text', String lf, lines, String lf, '```'
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeTitleFor: anEpisodeId forChannel: aChannelHandle [
	| path file lines date title hasBeenRead |
	aChannelHandle ifNil: [ ^ anEpisodeId ].
	"path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) , '/' , anEpisodeId , '_meta.txt'."
	path :=  self class channelDictionary, aChannelHandle , '/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ anEpisodeId ].
	lines := file readStream contents utf8Decoded lines.
	lines size < 5 ifTrue: [ ^ anEpisodeId ].
	date := self formatDate: (lines at: 5).
	title := lines first.
	hasBeenRead := lines last = 'have read: true'.
	^ hasBeenRead 
    ifTrue: [ '✓ ' , date , ' ' , title ]
    ifFalse: [ date , ' ' , title ]
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeToggleRead [
    | channel episode episodeId |
    channel := channelList selectedItem.
    episode := AIAYouTubeEpisode new channel: channel; yourself.
    episodeList selectionMode selectedIndexes do: [ :index |
        episodeId := episodeList items at: index.
        (episode episodeIsRead: episodeId)
            ifTrue: [ episode episodeMarkAsUnread: episodeId ]
            ifFalse: [ episode episodeMarkAsRead: episodeId ] ].
    episodeList refresh.
]

{ #category : 'episode' }
AIAYouTubeUI >> episodeUpdateLimitButton [
	| noOfEpisodeUpdates | 
	noOfEpisodeUpdates := self newDropList
		items: #(2 3 5 7 10);
		whenSelectedItemChangedDo: [:newLimit | self class episodeUpdateLimit: newLimit ].
	^ noOfEpisodeUpdates
]

{ #category : 'episode' }
AIAYouTubeUI >> episodesFor: aChannelHandle [
	| dir entries |
	aChannelHandle ifNil: [ ^ #() ].
	"dir := FileReference / (AIAYouTubeChannel new channelDirectory: aChannelHandle)."
	dir := FileReference / (self class channelDictionary , aChannelHandle).
	dir exists ifFalse: [ ^ #() ].
	entries := (dir entries
		select: [ :entry | entry basename endsWith: '_meta.txt' ])
		collect: [ :entry | entry basename copyFrom: 1 to: entry basename size - '_meta.txt' size ].
	^ entries sort: [ :a :b |
		(self episodeDateFor: a forChannel: aChannelHandle) >
		(self episodeDateFor: b forChannel: aChannelHandle) ]
]

{ #category : 'misc' }
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
	channelTypeList items: self class channels asOrderedDictionary keys.
	
	self channelTypeChangeAction.
	self channelChangeAction.
	self episodeChangeAction.
	self episodeTextAction.
]

{ #category : 'initialization' }
AIAYouTubeUI >> initializeWindow: aWindowPresenter [
	"Set the window title."
	super initializeWindow: aWindowPresenter.
	aWindowPresenter 
		title: 'YouTube Browser';
		initialExtent: 900 @ 700.
]

{ #category : 'misc' }
AIAYouTubeUI >> showChannel: aChannelHandle [
	aChannelHandle ifNil: [ ^ self ].
	descriptionText text: (self descriptionFor: aChannelHandle).
	episodeList items: (self episodesFor: aChannelHandle).
	episodeDetail text: ''.
]

{ #category : 'misc' }
AIAYouTubeUI >> showChannelsForType: aTypeString [
	| channels |
	aTypeString ifNil: [ ^ self ].
	"channels := AIAYouTubeChannel channels asDictionary at: aTypeString ."
	channels := self class channels asDictionary at: aTypeString .
	channelList items: channels.
	descriptionText text: ''.
	episodeList items: #().
	episodeDetail text: ''.
]

{ #category : 'misc' }
AIAYouTubeUI >> showEpisode: anEpisodeId [
	anEpisodeId ifNil: [ ^ self ].
	episodeDetail text: (self episodeDetailFor: anEpisodeId forChannel: channelList selectedItem).
]

{ #category : 'misc' }
AIAYouTubeUI >> showEpisodes: anEpisodeIdCollection [
	| combined |
	combined := anEpisodeIdCollection 
		inject: '' 
		into: [ :acc :id |
			acc , String lf, String lf,
			(self episodeDetailFor: id forChannel: channelList selectedItem) , String lf ].
	episodeDetail text: (Microdown asRichText: combined).
]
