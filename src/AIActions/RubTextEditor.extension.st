Extension { #name : 'RubTextEditor' }

{ #category : '*AIActions' }
RubTextEditor class >> buildSpeakShortcutsOn: aBuilder [
	<keymap>
	"KMRepository reset."
	(aBuilder shortcut: #speakIt)
		category: self name
		default: $a meta shift
		do: [ :target | target editor speakIt: nil ]
		description: 'Speak the selection'.
	(aBuilder shortcut: #pauseOrResumeSpeaking)
		category: self name
		default: $w meta shift
		do: [ :target | target editor pauseOrResumeSpeaking: nil ]
		description: 'Pause or resume speech'
]

{ #category : '*AIActions' }
RubTextEditor >> pauseOrResumeSpeaking: aKeyboardEvent [
	"Pause say if it is speaking; resume it if it is paused."
	(LibC runCommand: 'ps -axco stat=,comm= | grep -q "^T.*say$"') = 0
		ifTrue: [ LibC runCommand: 'killall -CONT say' ]
		ifFalse: [ LibC runCommand: 'killall -STOP say' ].
	^ true
]

{ #category : '*AIActions' }
RubTextEditor >> speakIt: aKeyboardEvent [
	"Speak the selection (or current line) with macOS say, replacing any ongoing speech."
	| rate voice text file |
	rate := 250.
	voice := 'Ava'.
	"Going by what I know, which may be out of date:
American: Ava (Premium) is widely considered the best non-Siri voice. Zoe (Premium) and Evan (Premium) are alternatives.
British: Jamie (Premium) and Serena (Premium) are the main Premium options."
	self lineSelectAndEmptyCheck: [ ^ true ].
	text := self selection asString.
	LibC runCommand: 'killall -KILL say'.
	file := FileLocator temp / 'pharo-speak.txt'.
	file ensureDelete.
	file writeStreamDo: [ :s | s nextPutAll: text ].
	LibC runCommand: 'say -v "' , voice , '" -r ' , rate printString , ' -f "' , file fullName , '" &'.
	^ true
]
