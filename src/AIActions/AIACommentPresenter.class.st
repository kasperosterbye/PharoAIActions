"
# Class Comment for AIACommentPresenter

`AIACommentPresenter` is a specialized presenter designed to display and manage Markdown-formatted comments within the AIActions framework. It extends `MicrodownPresenter` to provide a user-friendly interface for viewing and editing comments, with support for syntax highlighting and basic text manipulation.

## Key Features

- **Markdown Support**: Renders Markdown text with syntax highlighting using Microdown.
- **Comment Management**: Handles the creation, display, and modification of comments.
- **Window Integration**: Opens comments in a dedicated window with a descriptive title.

## Usage Example

```smalltalk
""AIACommentPresenter example usage in the Playground""

""Create and open a comment presenter with sample Markdown text""
commentText := '## Sample Comment
This is a **Markdown** formatted comment.
- List item 1
- List item 2
```markdown
Code block example:
```smalltalk
1 + 1
```'.

""AIACommentPresenter onText: commentText.
```

This will open a window titled ""Comment for Sample Comment..."" displaying the formatted Markdown content.

## Design Considerations

1. **Inheritance**: Inherits from `MicrodownPresenter` to leverage its rich text display capabilities.
2. **Instance Variables**: Maintains a `commentName` to track the comment's identifier.
3. **Class Methods**: Provides `onText:` class method for easy instantiation.
4. **Window Management**: Automatically generates a descriptive window title based on the comment content.

The presenter is particularly useful in applications requiring comment management with Markdown support, such as code review tools or documentation systems.
"
Class {
	#name : 'AIACommentPresenter',
	#superclass : 'MicrodownPresenter',
	#instVars : [
		'commentName'
	],
	#classInstVars : [
		'commentPresenter'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'instance creation' }
AIACommentPresenter class >> onText: aString [
	commentPresenter ifNotNil: [ commentPresenter delete].
	commentPresenter := self basicNew.
	commentPresenter
		commentName: ((aString lines first takeFirst: 20), '...');
		initialize;
		text: (Microdown asRichText: (aString copyReplaceAll: '```markdown' with: '') );
		"text: aString;"
		open 
]

{ #category : 'accessing' }
AIACommentPresenter >> commentName [

	^ commentName
]

{ #category : 'accessing' }
AIACommentPresenter >> commentName: anObject [

	commentName := anObject
]

{ #category : 'accessing' }
AIACommentPresenter >> windowTitle [

	^ 'Comment for ', self commentName  
]
