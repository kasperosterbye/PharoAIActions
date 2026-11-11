"
AIAHistoryMessagesPresenter is a presenter for displaying and interacting with a history of messages in a structured format.
"
Class {
	#name : 'AIAHistoryMessagesPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'history',
		'expandedIndices',
		'selectedIndex',
		'showTools'
	],
	#category : 'AIActions-UIPresenters',
	#package : 'AIActions',
	#tag : 'UIPresenters'
}

{ #category : 'examples' }
AIAHistoryMessagesPresenter class >> test01 [

	<example>
	| file history presenter |
	file := FileLocator home / 'D' / 'Pharo' / 'history' / 'H10081-issue-24-solved-kopi.json'.

	history := AIAHistoryFileStore loadFrom: file.

	presenter := AIAHistoryMessagesPresenter new.
	presenter history: history.
	presenter open
]

{ #category : 'initialization' }
AIAHistoryMessagesPresenter >> defaultLayout [
    "Answer an initially empty vertical layout."

    ^ SpBoxLayout newTopToBottom
]

{ #category : 'accessing' }
AIAHistoryMessagesPresenter >> heightForMessageAt: anIndex [
    "Estimate the height needed to display a Microdown message."

    | content richText morph width |

    content := ((self messageAt: anIndex) value
		lines collect: [ :line | line = '```' ifTrue: [ '```text' ] ifFalse: [ line ]])
		joinUsing: String lf.
    richText := Microdown asRichText: (Microdown parse: content).

    width := self adapter
        ifNil: [ 450 ]
        ifNotNil: [ :adapter | adapter widget width - 35 ].

    morph := TextMorph new.
    morph
        autoFit: true;
        width: (width max: 180);
        contentsWrapped: richText.

    ^ (morph height + 20) max: 40
]

{ #category : 'accessing' }
AIAHistoryMessagesPresenter >> history: aHistory [
    "Set the history and reset message selection and expansion."

    history := aHistory.
    expandedIndices := Set new.
    selectedIndex := nil.
    self rebuildMessagesLayout
]

{ #category : 'initialization' }
AIAHistoryMessagesPresenter >> initializePresenters [
    "Initialize the message display state."

    super initializePresenters.
    expandedIndices := Set new.
    selectedIndex := nil.
    showTools := true
]

{ #category : 'initialization' }
AIAHistoryMessagesPresenter >> messageAt: anIndex [
    "Return the visible message at the given index."

    ^ self visibleMessages at: anIndex
]

{ #category : 'initialization' }
AIAHistoryMessagesPresenter >> rebuildMessagesLayout [
    "Rebuild the message list with content-dependent heights."

    | layoutStructure container |

    layoutStructure := SpBoxLayout newTopToBottom.
    layoutStructure spacing: 2.
    history ifNotNil: [
        1 to: self visibleMessages size do: [ :index |
            | row |
            row := self rowAt: index.
"Transcript << index asString << ': ' << row first label asString << String lf << String lf.
self halt."
            layoutStructure add: row first height: 20.

            (expandedIndices includes: index) ifTrue: [
                layoutStructure add: row second
                    height: (self heightForMessageAt: index) ] ] ].
    container := SpPresenter new.
    container layout: layoutStructure.

    self layout: (SpScrollableLayout new
        child: container;
        withoutHScrollbar;
        yourself)
]

{ #category : 'initialization' }
AIAHistoryMessagesPresenter >> rowAt: anIndex [
    "Construct the clickable header and Microdown presenter for a message."

    | message role content preview link md |

    message := self messageAt: anIndex.
    role := message key.
    content := message value.
    preview := content first: (50 min: content size).

    link := self newLink.
	 link color: Color black.
    link label: ((expandedIndices includes: anIndex)
        ifTrue: [ role, ':' ]
        ifFalse: [ role, ': ', preview ]).
    link action: [
        self toggleExpandedAt: anIndex.
         ].
    link whenBuiltDo: [
        | style |
        style := SpDrawStyle new.
        style backgroundColor: #veryVeryLightGray.
		  style applyTo: link adapter widget
    ].
	 (content beginsWith: '[tool_call]')
		ifTrue: [ content := '```text' , String lf , content , String lf, '```', String lf ].
    md := MicrodownPresenter new.
	 md documentFromString: content.

    ^ { link. md }
]

{ #category : 'accessing' }
AIAHistoryMessagesPresenter >> scrollToSelectedMessage [
    "Scroll the selected message header into view."

    | offset |

    selectedIndex ifNil: [ ^ self ].

    offset := (selectedIndex - 1) * 30.

    expandedIndices do: [ :index |
        index < selectedIndex ifTrue: [
            offset := offset
                + (self heightForMessageAt: index)
                + 2 ] ].

    self layout withAdapterDo: [ :adapter |
        | pane maxScroll |

        pane := adapter widget.
        maxScroll := pane scrollTarget height - pane height.

        maxScroll > 0 ifTrue: [
            self layout scrollTo:
                0 @ ((offset / maxScroll) min: 1) ] ]
]

{ #category : 'accessing' }
AIAHistoryMessagesPresenter >> showTools: aBoolean [
    "Set whether tool interactions are visible."

    showTools = aBoolean ifTrue: [ ^ self ].

    showTools := aBoolean.
    expandedIndices := Set new.
    selectedIndex := nil.
    self rebuildMessagesLayout
]

{ #category : 'accessing' }
AIAHistoryMessagesPresenter >> toggleExpandedAt: anIndex [
    "Toggle the message and scroll to it when expanding."

    selectedIndex := anIndex.

    (expandedIndices includes: anIndex)
        ifTrue: [
            expandedIndices remove: anIndex.
            self rebuildMessagesLayout ]
        ifFalse: [
            expandedIndices add: anIndex.
            self rebuildMessagesLayout.
            self defer: [ self scrollToSelectedMessage ] ]
]

{ #category : 'accessing' }
AIAHistoryMessagesPresenter >> visibleMessages [
    "Return messages, optionally excluding tool interactions."

    | messages |

    history ifNil: [ ^ #() ].

    messages := history displayMessageList.

    showTools ifTrue: [ ^ messages ].

    ^ messages reject: [ :message |
        message key = 'assistant'
            and: [
                message value beginsWith: '[tool_call]' ] ]
]
