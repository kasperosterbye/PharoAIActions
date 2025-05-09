"
This class implements AI based comment generations for methods. There are several levels.

1) If the method already have a comment (checks if the second line starts with "" ), then that comment is kept.
2) If no comment exist it will look at the senders of this method
* There is no senders. It can be either a method that should be removed, or an important one to be used on the outside. The comment should be added that ask the developer to solve the issue - if it is imporant, add usage to class side or in tests

* More than around 50% of the senders are in the same class. Ignore the other 50% as they are most likely unrelated, but just using the same name. Give the same class methods as input to the understanding of the method

* There number of senders from other classes is high, meaning that the implementation of the method is done in many classes. Assume the name of the class is widely used, and check if the method it self is implemented in all those classes as well.
	If they are, use these other classes as input to the AI comment generator
	If they are not, use the senders as input to the AI comment generator
"
Class {
	#name : 'AI_MethodComment',
	#superclass : 'AI_CommentBuilding',
	#instVars : [
		'compiledMethod',
		'methodSource'
	],
	#category : 'AIActions-Comment builder',
	#package : 'AIActions',
	#tag : 'Comment builder'
}

{ #category : 'accessing - comment' }
AI_MethodComment class >> methodCommentOutline [
	^ 'In Pharo, it is a common practice to include a comment on the second line of a method to describe its purpose or behavior. While there is no strict outline enforced by the system, there are some conventions and best practices that developers follow to ensure that comments are clear and useful. Here are some guidelines for writing method comments in Pharo:

1. **Start with a Verb**: Begin the comment with a verb to describe the action the method performs. For example, "Returns", "Calculates", "Checks", etc.

2. **Be Concise**: Keep the comment brief and to the point. Aim for a single line or a short paragraph.

3. **Use Proper Grammar**: Ensure the comment is grammatically correct and easy to read.

4. **Describe the Method''s Purpose**: Clearly state what the method does. Avoid describing implementation details unless they are crucial for understanding the method''s purpose.

5. **Include Parameters and Return Values**: If the method takes parameters or returns a value, mention them in the comment.

6. **Use Markdown for Formatting**: If you are using a tool that supports Markdown, you can format your comments for better readability.

### Example

Here is an example of a well-commented method in Pharo:

```smalltalk
add: aNumber
	"Adds aNumber to the receiver and returns the result."

	^ self + aNumber
```

In this example:
- The comment starts with a verb ("Adds").
- It is concise and describes the method''s purpose.
- It mentions the parameter (`aNumber`) and the return value (`the result`).

### Another Example

```smalltalk
isEven
	"Returns true if the receiver is an even number, false otherwise."

	^ self \\ 2 = 0
```

In this example:
- The comment starts with a verb ("Returns").
- It clearly states the condition under which the method returns `true` or `false`.
- It is concise and easy to understand.

### Best Practices

- **Consistency**: Follow a consistent style across your codebase.
- **Readability**: Ensure the comment is easy to read and understand.
- **Relevance**: Make sure the comment is relevant to the method''s functionality.

By following these guidelines, you can write clear and useful method comments that enhance the readability and maintainability of your Pharo code.'
]

{ #category : 'accessing - comment' }
AI_MethodComment class >> methodDetailedComment [
	^ 'In Pharo, as in many other programming environments, the quality of a method''s comment can significantly impact its readability and maintainability. The best comments are those that provide clear, concise, and useful information to anyone reading the code. Here are some considerations for writing effective comments for methods:

### Understanding How the Method is Used
- **Contextual Information**: Comments that explain the purpose and context of the method can be very helpful. This includes describing what the method does in the broader context of the application or system.
- **Usage Examples**: Providing examples of how the method is used in other parts of the code can be very beneficial. This can help new developers understand how to integrate the method into their own code.
- **Preconditions and Postconditions**: Describing the expected state before and after the method is called can be crucial for understanding its behavior.

### Understanding How the Method is Implemented
- **Implementation Details**: Comments that explain complex or non-obvious parts of the implementation can be very useful. This includes explaining algorithms, data structures, or any tricky logic.
- **Edge Cases**: Describing how the method handles edge cases or unusual inputs can prevent bugs and make the code more robust.
- **Performance Considerations**: If the method has performance implications, comments can help other developers understand these aspects.

### Tests as Input for Comments
- **Test Cases**: Understanding the tests for a method can provide valuable insights into how the method is expected to behave. Test cases often cover various scenarios, including edge cases, which can be documented in the comments.
- **Test Coverage**: The tests can help ensure that the comments are accurate and comprehensive. If the tests cover a wide range of scenarios, the comments should reflect this.
- **Documenting Assumptions**: Tests often make assumptions about the method''s behavior. Documenting these assumptions in the comments can help prevent misunderstandings.

### Best Practices for Writing Comments
1. **Be Clear and Concise**: Avoid unnecessary details and keep the comments focused on the most important aspects.
2. **Use Active Voice**: Write comments in a way that describes what the method does, rather than what it is.
3. **Keep Comments Updated**: Ensure that the comments are kept in sync with the code. Outdated comments can be misleading.
4. **Avoid Redundancy**: Do not repeat information that is already clear from the method name or the code itself.
5. **Use Examples**: When possible, include examples or snippets of code that illustrate how the method is used.

### Example
Here''s an example of a well-commented method in Pharo:

```smalltalk
"Returns the factorial of a given positive integer.
 If the input is not a positive integer, raises an error.

 Example usage:
   | result |
   result := self factorial: 5.
   Transcript show: result; cr.  "Should print 120"

 Preconditions:
   - The input must be a positive integer.

 Postconditions:
   - The method returns the factorial of the input.

 Edge cases:
   - If the input is 0, the method returns 1.
   - If the input is 1, the method returns 1."

factorial: anInteger
    "Calculates the factorial of anInteger using recursion."
    anInteger < 0 ifTrue: [ self error: ''Input must be a positive integer'' ].
    anInteger = 0 ifTrue: [ ^ 1 ].
    anInteger = 1 ifTrue: [ ^ 1 ].
    ^ anInteger * (self factorial: anInteger - 1)
```

In this example, the comment provides contextual information, usage examples, preconditions, postconditions, and details about edge cases, making it a comprehensive and useful comment.

### Conclusion
The best comments in Pharo (or any other language) are those that provide a balance between explaining the method''s purpose, its usage, and its implementation details. Understanding the tests can be a valuable input to the comments, as they often cover a wide range of scenarios and can help ensure that the comments are accurate and comprehensive.'
]

{ #category : 'accessing' }
AI_MethodComment >> commentSourceFor: aCompiledMethod [
	"The method commentSourceFor takes a compiled method, formats its class name and source code, and returns the formatted string."
	| sourceString |
	sourceString := WriteStream on: ''.
	sourceString << aCompiledMethod methodClass name << ' >> '.
	sourceString << aCompiledMethod sourceCode << String cr << String cr.
	^ sourceString contents
]

{ #category : 'initialization' }
AI_MethodComment >> methodSourceAddComment: comment [
	"Adds a comment to the method source code."
	| sourceLines safeComment |
	safeComment := comment copyWithoutAll: '"'.
	sourceLines := compiledMethod sourceCode lines asOrderedCollection.
	sourceLines add: (String tab, '"' , comment, '"' ) afterIndex: 1.
	^ String cr join: sourceLines 
	
]

{ #category : 'accessing' }
AI_MethodComment >> sendersOf: aCompiledMethod [
	"This method finds senders of a compiled method within the same package prefix, then returns their comments as a string."
	| senders package sendersSource|
	package := aCompiledMethod methodClass package name.
	senders := aCompiledMethod senders select: [ :sender |
		(sender methodClass package name copyUpToSubstring: '-') 
			= (package copyUpToSubstring: '-').].
	sendersSource := WriteStream on: ''.
	senders do: [ :sender | 
		sendersSource << (self commentSourceFor: sender) << String cr. String cr. ].
	^ sendersSource contents 
]

{ #category : 'initialization' }
AI_MethodComment >> setComment: aCompiledMethod [
	"Sets a comment for a compiled method if none exists."
	| mistral |
	compiledMethod := aCompiledMethod.
	compiledMethod comment ifNotNil: [ ^ nil ].
	
	methodSource := self commentSourceFor: compiledMethod .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		(self commentSourceFor: compiledMethod), 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: methodSource.
	response := mistral getResponseForPrompt: prompt.
	compiledMethod methodClass
		compile: (self methodSourceAddComment: response)
		classified: compiledMethod protocol
]
