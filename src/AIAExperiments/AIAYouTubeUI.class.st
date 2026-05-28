"
`AIAYouTubeUI` is a Spec presenter that provides an interactive browser for locally cached YouTube channel data managed by the `AIAYouTubeChannel` infrastructure.

The presenter is intended to be the user-facing entry point for exploring YouTube channels grouped by channel type, viewing channel descriptions, listing downloaded episodes, inspecting episode metadata/transcripts, and optionally sending selected episode text to an AI summarisation workflow. It does not itself download or parse YouTube data from the network as its primary responsibility; instead, it presents and coordinates data that is stored on disk by `AIAYouTubeChannel`.

## Purpose and role in the system

`AIAYouTubeUI` acts as a desktop browser over a local YouTube archive.

It provides a three-stage navigation flow:

1. Select a channel type.
2. Select a channel within that type.
3. Select one or more episodes for inspection.

For each selected channel, the UI displays:

- the channel description, if it has been loaded;
- the list of locally available episodes;
- episode titles decorated with their publication dates;
- detailed episode metadata and transcript text.

The class is particularly useful when working with a collection of YouTube channels that have already been indexed or downloaded by `AIAYouTubeChannel`. It allows the user to inspect the material, compare episodes, open an episode in Safari, and submit episode text to an AI presenter for a short summary.

The presenter is therefore best understood as a coordination and presentation layer. It translates user selections into filesystem lookups, formats the resulting data as text or Microdown, and updates the visible panes accordingly.

## Main collaborators and dependencies

### `SpPresenter` and Spec widgets

`AIAYouTubeUI` is a subclass of `SpPresenter` and uses the Spec framework to build its interface.

Its main presenters are:

- `channelTypeList` — list of channel categories or types;
- `channelList` — list of channel handles belonging to the selected type;
- `episodeList` — list of episode identifiers for the selected channel;
- `descriptionText` — text pane showing the channel description;
- `episodeDetail` — text pane showing metadata and transcript content for selected episodes.

The layout is built with nested `SpPanedLayout` instances, giving the browser a split-pane structure with navigation on the left and episode detail on the right.

### `AIAYouTubeChannel`

`AIAYouTubeChannel` is the principal domain collaborator.

`AIAYouTubeUI` relies on it for:

- the configured channel catalogue via `AIAYouTubeChannel channels`;
- resolving a channel handle to its local directory via `channelDirectory:`;
- updating a channel when the user activates a channel entry via `channelUpdate:`.

The UI assumes that `AIAYouTubeChannel` owns the knowledge of where channel files live and how they are refreshed.

### Local filesystem

The presenter reads channel and episode data directly from files inside each channel directory.

Expected files include:

- `description.txt` — channel description;
- `<episodeId>_meta.txt` — episode metadata;
- `<episodeId>.txt` — episode transcript or text content.

The metadata file is expected to contain at least five lines. The implementation currently interprets:

- the first line as the episode title;
- the fifth line as the publication date in `YYYYMMDD` form;
- the sixth line, when present, as the episode description.

Missing or incomplete files are tolerated and displayed using fallback text such as `Not loaded yet`, `Meta incomplete`, or the raw episode identifier.

### `Microdown`

Selected episode details are converted with `Microdown asRichText:` before being placed in the episode detail text presenter. This allows headings, block quotes, and fenced transcript content to be displayed in a richer form when the text widget supports it.

### `AIAPresenter`

When the user submits the episode detail text, `AIAYouTubeUI` delegates to `AIAPresenter onText:` with a prompt asking for a concise summary of the supplied description/content. This makes the UI a bridge between the local YouTube archive and the AI-assisted summarisation tools used elsewhere in the system.

### `LibC`

Episode activation opens the selected episode in Safari by invoking:

- `open -a Safari ""https://www.youtube.com/watch?v=<episodeId>""`

This is platform-specific and assumes a macOS environment with Safari available.

## Important invariants and design constraints

### Channel handles must resolve to local directories

Most behaviour depends on the invariant that a selected channel handle can be resolved by:

`AIAYouTubeChannel new channelDirectory: aChannelHandle`

That directory is expected to contain the files for the channel. If the directory does not exist, the episode list is empty.

### Episode identifiers are file basenames

Episodes are represented internally by their YouTube episode identifiers. The UI derives them from files named:

`<episodeId>_meta.txt`

The visible label shown in the episode list is produced separately by reading metadata and formatting the episode title and date. Code using this presenter should not assume that the displayed title is the stored item; the stored list item remains the episode identifier.

### Metadata files have an expected line-oriented structure

The presenter assumes a simple line-based metadata format. At minimum, line 1 should be the title and line 5 should be the date. Some views also expect line 6 to contain a description.

If the metadata file has fewer than five lines, the episode is treated as incomplete. If line 6 is missing, methods that assume it exists may need to be made more defensive before using the UI with partially populated archives.

### Dates are sorted as `YYYYMMDD`

Episodes are sorted newest first by comparing the raw metadata date strings. This works because the expected date format is `YYYYMMDD`, whose lexicographical order matches chronological order.

The formatted date displayed to the user is produced separately as `YYYY-MM-DD`.

### UI updates and channel refreshes are separated

Selecting a channel displays already available local data.

Activating a channel triggers an update through `AIAYouTubeChannel>>channelUpdate:` in a background process, then reloads the channel view. This keeps ordinary browsing responsive while allowing an explicit refresh operation when needed.

### Multiple episode selection is supported

`episodeList` is configured for multiple selection. When the selection changes, the presenter combines the details of all selected episodes into a single Microdown document and displays it in `episodeDetail`.

This is useful for comparing episodes or submitting a combined body of text to the AI summariser.

### The class is a presenter, not a domain model

`AIAYouTubeUI` should not be used as the authoritative representation of channels, episodes, metadata, or transcripts. It is a UI coordinator. Domain logic such as channel discovery, updating, downloading, and directory policy belongs in `AIAYouTubeChannel` or related model/service classes.

## When to use this class

Use `AIAYouTubeUI` when you want an interactive desktop interface for browsing a local YouTube archive maintained by `AIAYouTubeChannel`.

It is appropriate for:

- inspecting whether a channel has been loaded;
- browsing downloaded episode metadata;
- reading transcripts or extracted episode text;
- opening a selected episode on YouTube;
- submitting selected episode material to an AI summarisation workflow;
- manually refreshing a channel and reviewing the updated result.

It is not appropriate as a headless API for batch processing YouTube data. For automated processing, use the underlying channel and filesystem services directly.

## Usage examples

### Open the YouTube browser

```smalltalk
AIAYouTubeUI open
```

This opens the browser window, initialises the channel type list from `AIAYouTubeChannel channels`, and waits for the user to choose a channel type and channel.

### Browse, refresh, and inspect a channel

A typical interactive session is:

1. Open the browser.
2. Select a channel type.
3. Select a channel handle.
4. Review the channel description and the list of locally available episodes.
5. Activate the channel entry to refresh it from the underlying `AIAYouTubeChannel` update mechanism.
6. Select one or more episodes to view their metadata and transcript.
7. Activate an episode to open it on YouTube in Safari.
8. Submit the episode detail text to request a concise AI-generated summary.
"
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
	| path file lines title date episodeId desc details |
	path := (AIAYouTubeChannel new channelDirectory: aChannelHandle) ,
		'/' , anEpisodeId , '_meta.txt'.
	file := File named: path.
	file exists ifFalse: [ ^ 'Not loaded yet' ].
	lines := file readStream contents utf8Decoded lines.
	lines size < 5 ifTrue: [ ^ 'Meta incomplete' ].
	title := '# Channel: ', aChannelHandle, String lf.
	title := title, '## Episode: ', lines first.
	date  := '> ', (self formatDate: lines fifth).
	episodeId := 'YouTupe id: ''', lines third , ''''.
	desc := ' ', lines sixth.
	details := title , String lf , date , String lf , String lf , episodeId, String lf, desc.
	^ details
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodeTextAction [
	episodeDetail whenSubmitDo: [ :a | 
		AIAPresenter onText: ('What is the essence of the descrition I gave you. Please let your response be at most 20 line. Start the title with the Cannel name and Episode Name'
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
	dir := FileReference / (AIAYouTubeChannel new channelDirectory: aChannelHandle).
	dir exists ifFalse: [ ^ #() ].
	entries := (dir entries
		select: [ :entry | entry basename endsWith: '_meta.txt' ])
		collect: [ :entry | entry basename copyFrom: 1 to: entry basename size - '_meta.txt' size ].
	^ entries sort: [ :a :b |
		(self episodeDateFor: a forChannel: aChannelHandle) >
		(self episodeDateFor: b forChannel: aChannelHandle) ]
]

{ #category : 'as yet unclassified' }
AIAYouTubeUI >> episodesFor_old: aChannelHandle [
	| dir entries |
	aChannelHandle ifNil: [ ^ #() ].
	dir := File named: (AIAYouTubeChannel new channelDirectory: aChannelHandle).
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
