"
# Class Comment for MicroUMLSequenceDiagram

The `MicroUMLSequenceDiagram` class is designed to create and display sequence diagrams in Pharo. Sequence diagrams are a type of UML diagram that illustrate how processes operate in terms of a sequence of messages exchanged between objects over time.

## Key Features

- **Actor Management**: Add actors to the diagram with the `addActor:` method.
- **Message Management**: Add messages between actors using `addMessage:from:to:` and `addReturn:from:to:`.
- **Visualisation**: Construct and display the sequence diagram on a canvas using the `build` method.

## Usage Example

Here is an example of how to create and display a sequence diagram in the Pharo Playground:

```st
| sd |
sd := MicroUMLSequenceDiagram new.
sd addActor: 'Client'.
sd addActor: 'Server'.
sd addMessage: 'request' from: 'Client' to: 'Server'.
sd addReturn: 'response' from: 'Server' to: 'Client'.
sd build.
```

This example creates a sequence diagram with two actors, 'Client' and 'Server', and a message exchange between them. The `build` method constructs and displays the diagram on a canvas.

## Design Decisions

- The class is designed to be used interactively in the Pharo Playground.
- The `build` method returns a class builder that does not install the class but can be used to inspect the diagram.
- The `install` method is used to install the class in the system.

By following these guidelines, you can create and visualise sequence diagrams effectively using the `MicroUMLSequenceDiagram` class.
"
Class {
	#name : 'MicroUMLSequenceDiagram',
	#superclass : 'Object',
	#instVars : [
		'actors',
		'messages',
		'actorGap',
		'lifelineHeight',
		'canvas'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSequenceDiagram class >> diagram01 [
	"Creates a sequence diagram with two actors and a message exchange"
	<example>

    | sd |
    sd := self new.
    sd addActor: 'Login System'. 
    sd addActor: 'Database'.
    sd addMessage: 'verify ' from: 'Login System' to: 'Database'.
    sd addReturn: 'return something long here' from: 'Database' to: 'Login System'.
    sd build.
]

{ #category : 'examples' }
MicroUMLSequenceDiagram class >> diagram02 [
	"Creates a sequence diagram with three actors and two message exchanges"

	<example>
	| sd |
	sd := self new.
	sd addActor: 'Playground'.
	sd addActor: 'Database'.
	sd addActor: 'Login System'.
	sd addMessage: 'call ' from: 'Playground' to: 'Login System'.
	sd addInternal: 'Kilroy ' for: 'Database'.
	sd addMessage: 'verify ' from: 'Login System' to: 'Database'.
	sd addReturn: '' from: 'Database' to: 'Playground'.
	sd build
]

{ #category : 'instance creation' }
MicroUMLSequenceDiagram class >> from: ast [
	| instanse |
	instanse := self new.
	instanse actors: ast actors .
	instanse messages: ast messages.
	instanse build.
]

{ #category : 'as yet unclassified' }
MicroUMLSequenceDiagram class >> whatIs [
^ '


# `Context` — Class Comment

## Overview

`Context` (historically known as `MethodContext`) represents the runtime state of a method or block activation in the Pharo virtual machine. Every time a message is sent or a block is evaluated, a `Context` is created to hold the execution state: the sender (caller), the receiver, the method being executed, the programme counter (PC), the stack pointer, and any closure (block) information.

Contexts form a linked list via their `sender` field, constituting the **call stack**. This reification of the stack as first-class objects is one of Smalltalk''s most powerful reflective capabilities, enabling the debugger, exception handling, continuations, coroutines, and process scheduling to be implemented entirely in-image.

## Instance Variables

| Variable | Description |
|---|---|
| `sender` | The `Context` that sent the message which created this context (i.e. the caller). "nil" for the bottom of the stack. |
| `pc` | The **programme counter** — an integer index into the method''s bytecodes indicating the next instruction to execute. "nil" when the context is dead (terminated). |
| `stackp` | The **stack pointer** — an integer indicating the current top of the operand stack within this context''s indexed variables. |
| `method` | The `CompiledMethod` or `CompiledBlock` being executed. |
| `closureOrNil` | If this context is executing a block, holds the `BlockClosure`; otherwise "nil". |
| `receiver` | The object that received the message (i.e. `self` within the executing method). |

## Key Responsibilities

- **Stack inspection**: Walking the sender chain to produce stack traces, find handler contexts, or locate specific activations.
- **Bytecode simulation**: Interpreting bytecodes one at a time via `#step`, enabling the debugger to single-step through code entirely in Smalltalk.
- **Exception handling**: Locating `#on:do:` handler contexts and `#ensure:`/`#ifCurtailed:` unwind contexts on the stack.
- **Process control**: Supporting `#jump`, `#resume:`, `#return:`, and `#terminate` for switching and unwinding execution.
- **Temporary variable access**: Reading and writing temporaries by name or index, used extensively by the debugger and inspector.

## Shared Variables

| Variable | Description |
|---|---|
| `PrimitiveFailToken` | A unique sentinel object used during simulation to distinguish primitive failure from a successful result. |

## Design Notes

Contexts have a **variable layout** — their indexed slots hold the operand stack and temporaries. The `#size` and `#basicSize` primitives are overridden to report only the currently accessible portion of the stack (up to `stackp`), not the full allocated frame.

Because contexts are intimately tied to the VM''s execution engine, several methods use special primitives (e.g. 195–199, 210–212) that the VM handles specially for context objects.

## Usage Example

```smalltalk
"Capture the current context and inspect the sender chain"
| ctx senders |
ctx := thisContext.
senders := OrderedCollection new.
ctx withSendersDo: [ :each | senders add: each selector ].
senders
```

```smalltalk
"Simulate a block step-by-step and collect the selectors of each context visited"
| steps |
steps := OrderedCollection new.
thisContext sender
    runSimulated: [ 3 + 4 ]
    contextAtEachStep: [ :each | steps add: each selector ].
steps
```

```smalltalk
"Inspect the structure of a live context"
{ 
    #sender -> thisContext sender.
    #pc -> thisContext pc.
    #receiver -> thisContext receiver.
    #selector -> thisContext selector.
    #compiledCode -> thisContext compiledCode.
    #isBlockContext -> thisContext isBlockContext.
    #isDead -> thisContext isDead
} asDictionary
```
'
]

{ #category : 'as yet unclassified' }
MicroUMLSequenceDiagram class >> whatIsContext [
"Explanation generated by Claude opus 4.6"
^ '


# `Context` — Class Comment

## Overview

`Context` (historically known as `MethodContext`) represents the runtime state of a method or block activation in the Pharo virtual machine. Every time a message is sent or a block is evaluated, a `Context` is created to hold the execution state: the sender (caller), the receiver, the method being executed, the programme counter (PC), the stack pointer, and any closure (block) information.

Contexts form a linked list via their `sender` field, constituting the **call stack**. This reification of the stack as first-class objects is one of Smalltalk''s most powerful reflective capabilities, enabling the debugger, exception handling, continuations, coroutines, and process scheduling to be implemented entirely in-image.

## Instance Variables

| Variable | Description |
|---|---|
| `sender` | The `Context` that sent the message which created this context (i.e. the caller). "nil" for the bottom of the stack. |
| `pc` | The **programme counter** — an integer index into the method''s bytecodes indicating the next instruction to execute. "nil" when the context is dead (terminated). |
| `stackp` | The **stack pointer** — an integer indicating the current top of the operand stack within this context''s indexed variables. |
| `method` | The `CompiledMethod` or `CompiledBlock` being executed. |
| `closureOrNil` | If this context is executing a block, holds the `BlockClosure`; otherwise "nil". |
| `receiver` | The object that received the message (i.e. `self` within the executing method). |

## Key Responsibilities

- **Stack inspection**: Walking the sender chain to produce stack traces, find handler contexts, or locate specific activations.
- **Bytecode simulation**: Interpreting bytecodes one at a time via `#step`, enabling the debugger to single-step through code entirely in Smalltalk.
- **Exception handling**: Locating `#on:do:` handler contexts and `#ensure:`/`#ifCurtailed:` unwind contexts on the stack.
- **Process control**: Supporting `#jump`, `#resume:`, `#return:`, and `#terminate` for switching and unwinding execution.
- **Temporary variable access**: Reading and writing temporaries by name or index, used extensively by the debugger and inspector.

## Shared Variables

| Variable | Description |
|---|---|
| `PrimitiveFailToken` | A unique sentinel object used during simulation to distinguish primitive failure from a successful result. |

## Design Notes

Contexts have a **variable layout** — their indexed slots hold the operand stack and temporaries. The `#size` and `#basicSize` primitives are overridden to report only the currently accessible portion of the stack (up to `stackp`), not the full allocated frame.

Because contexts are intimately tied to the VM''s execution engine, several methods use special primitives (e.g. 195–199, 210–212) that the VM handles specially for context objects.

## Usage Example

```smalltalk
"Capture the current context and inspect the sender chain"
| ctx senders |
ctx := thisContext.
senders := OrderedCollection new.
ctx withSendersDo: [ :each | senders add: each selector ].
senders
```

```smalltalk
"Simulate a block step-by-step and collect the selectors of each context visited"
| steps |
steps := OrderedCollection new.
thisContext sender
    runSimulated: [ 3 + 4 ]
    contextAtEachStep: [ :each | steps add: each selector ].
steps
```

```smalltalk
"Inspect the structure of a live context"
{ 
    #sender -> thisContext sender.
    #pc -> thisContext pc.
    #receiver -> thisContext receiver.
    #selector -> thisContext selector.
    #compiledCode -> thisContext compiledCode.
    #isBlockContext -> thisContext isBlockContext.
    #isDead -> thisContext isDead
} asDictionary
```
'
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> actors [

	^ actors
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> actors: anObject [

	actors := anObject
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> add: type name: aDescription from: fromName to: toName [
	"Adds a message of the specified type with the given description from one actor to another."
    | message |
    message := MicroUMLSDMessages new.
    message
        description: aDescription;
        fromActor: (actors detect: [ :a | a name = fromName ]);
        toActor: (actors detect: [ :a | a name = toName ]);
        messageType: type.
    messages add: message.
    ^ message
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addActor: aString [
	"Adds a new actor to the sequence diagram with the given name"

	| actor |
	actor := MicroUMLSDActor new.
	actor
		name: aString;
		index: actors size + 1.
	actors add: actor.
	^ actor
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addInternal: aDescription for: actorName [
	^ self add: #internal name: aDescription from: actorName to: actorName
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addMessage: aDescription from: fromName to: toName [
	"Adds a message of the specified type with the given description from one actor to another."
	^ self add: #call name: aDescription from: fromName to: toName
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addReturn: aDescription from: fromName to: toName [
	"Adds a return message with the given description from one actor to another"
	^ self add: #return name: aDescription from: fromName to: toName
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> build [
	"Constructs and displays the sequence diagram on a canvas"

	canvas := RSCanvas new.
	self 
		computeActorPositions;
		computeMessagePositions;
		drawActors;
		drawLifelines;
		drawMessages.
	canvas @ RSCanvasController.
	canvas open
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> computeActorPositions [
	"Computes the horizontal positions of actors based on message distances"

	| currentX maxDistance |
	currentX := actorGap.
	actors first x: currentX.
	2 to: actors size do: [ :index |
			| a b messagesBetween |
			a := actors at: index -1.
			b := actors at: index .

			messagesBetween := messages select: [ :msg |
				(msg fromActor = a and: [ msg toActor = b ]) or: [ msg fromActor = b and: [ msg toActor = a ] ] ].
			maxDistance := messagesBetween
				 ifEmpty: [ actorGap ]
				 ifNotEmpty: [ :msgs | 
				 	(msgs collect: [ :msg | (RSLabel new text: msg description) textWidth ]) max + actorGap + 10].
			b x: a x + (maxDistance max: (a width / 2) + (b width / 2) + (2*actorGap) )   ].
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> computeMessagePositions [
	"Computes the vertical positions of messages based on their order and a fixed gap"
    messages doWithIndex: [ :msg :i |
        msg y: MicroUMLSDMessages topMargin + (i * MicroUMLSDMessages messageGap) ]
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> drawActors [
	"Draws all actors on the canvas"
	canvas addAll: (actors collect: [ :actor | actor draw ])
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> drawLifelines [
	"Draws the lifelines for each actor on the canvas"
    canvas addAll: (actors collect: [ :actor |
        RSLine new
            startPoint: actor x @ (MicroUMLSDActor boxHeight / 2);
            endPoint: actor x @ (MicroUMLSDActor boxHeight / 2 + self lifelineHeight);
            dashArray: #(5 5);
            color: Color black;
            yourself ])
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> drawMessages [
	"Draws all messages on the canvas"
    messages do: [ :msg | canvas addAll: msg draw ]
]

{ #category : 'initialization' }
MicroUMLSequenceDiagram >> initialize [
	"Initialises the sequence diagram with empty collections for actors and messages, and sets the default gap between actors"
	actors := OrderedCollection new.
	messages := OrderedCollection new.
	actorGap := MicroUMLSDActor actorGap.
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> lifelineHeight [
	"Returns the total height of the lifeline based on the number of messages and fixed margins"
    ^ MicroUMLSDMessages topMargin 
        + (messages size * MicroUMLSDMessages messageGap) 
        + MicroUMLSDMessages bottomMargin
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> messages [

	^ messages
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> messages: anObject [
	messages := anObject
]
