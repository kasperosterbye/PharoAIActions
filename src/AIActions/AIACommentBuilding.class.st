"
# Notes for building this

- Method comments in black (default) and white (aiaWhiteComment og setWhiteComment)
- The class side need to be cleaned, and tested
- The human language need to be tested
- There need to be a list of examples - it seems like simply starting the method name with example on the class side does the trick.
- There is a trick error for method comments

1. √ There are comments for Package, Class and Method. And no others!
2. √ 'PackageName' aiaComment, ClassName aiaComment, (ClassName >> #method) aiaComment.
3. √ Same as above, but setAIAComment for all three.
4. – AIACommentBuilder aiaComment: 'PackageName' , ClassName , (ClassName >> #method) selects based on the type of the argument - clumsey idea. #2 was better...
5. √ Unify the tree getComment methods - it seems like they do nearly the same. Split it into system and prompt setter, and the call to AIApi looks very similar too.
6. √ Set the system such that AIACommentBuilder is the only class to be used. Well, it is not necessary now.

"
Class {
	#name : 'AIACommentBuilding',
	#superclass : 'AIABuilder',
	#instVars : [
		'aiaApi'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIClassComment [
	self aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIMethodComment [
	(EpLog >> #priorEntriesFrom:do:) aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIPackageComment [
	'Epicea' aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleSetAIMethodComment [
	| method |
	method := EpLog >> #priorEntriesFrom:do:.
	method aiaComment inspect.
]

{ #category : 'model system' }
AIACommentBuilding class >> mistralComment01 [
	"Fist example of the result from AI_PackageComment comment: 'AI-OllamaKasper'"
	^ 'The `AI-OllamaKasper` package is designed to integrate AI capabilities into the Pharo programming environment, specifically focusing on generating and managing comments for classes and methods. This package leverages advanced AI models to provide intelligent suggestions and documentation, enhancing the development experience by automating the creation of comments and ensuring that code is well-documented.

### Key Features

1. **AI-Generated Comments**:
   - The package includes classes and methods that utilize AI models to generate comments for instance variables and methods. This helps in maintaining a well-documented codebase, which is crucial for understanding and maintaining the code.

2. **Integration with AI Models**:
   - The package is built to work with various AI models, such as Ollama and Mistral, which are used to generate responses based on the provided prompts. This integration allows for dynamic and context-aware comment generation.

3. **Testing and Validation**:
   - Comprehensive test classes are provided to ensure the reliability and accuracy of the AI-generated comments. These tests validate the functionality of the comment generation process and ensure that the comments are meaningful and relevant.

4. **User Interface**:
   - The package includes a user interface for interacting with the AI models and viewing the generated comments. This interface is built using Spec2, a framework for building user interfaces in Pharo.

5. **Extensibility**:
   - The package is designed to be extensible, allowing developers to add new AI models and customize the comment generation process to suit their specific needs.

### Classes and Their Responsibilities

1. **AI_PackageComment**:
   - This class is responsible for generating package comments using AI models. It takes a package name as input and generates a comment that describes the package''s purpose and functionality.

2. **AI_CommentBuilding**:
   - This class handles the generation of comments for classes and methods. It uses AI models to generate comments for instance variables and methods, ensuring that the code is well-documented.

3. **AI_CommentBuildingTest**:
   - This class contains tests for the `AI_CommentBuilding` class. It validates the functionality of the comment generation process and ensures that the comments are meaningful and relevant.

4. **AI_PackagesAsOllamaSystem**:
   - This class is responsible for converting package information into a format that can be used by AI models. It generates a system input that includes class definitions, instance variables, and method definitions.

5. **AI_PackagesAsOllamaSystemTest**:
   - This class contains tests for the `AI_PackagesAsOllamaSystem` class. It validates the functionality of the package conversion process and ensures that the generated system input is accurate and complete.

6. **OllamaApiExperiments**:
   - This class is responsible for running experiments with the Ollama API. It sends prompts to the API and collects the responses, allowing developers to test and validate the AI models.

7. **OllamaApiExperimentsPresenter**:
   - This class provides a user interface for interacting with the Ollama API experiments. It displays the results of the experiments and allows developers to view the generated comments and responses.

8. **MistralApiExperiments**:
   - This class is responsible for running experiments with the Mistral API. It sends prompts to the API and collects the responses, allowing developers to test and validate the AI models.

9. **MistralApiExperimentsPresenter**:
   - This class provides a user interface for interacting with the Mistral API experiments. It displays the results of the experiments and allows developers to view the generated comments and responses.

### Usage

To use the `AI-OllamaKasper` package, developers can leverage the provided classes and methods to generate comments for their classes and methods. The package can be integrated into the development workflow to ensure that the codebase remains well-documented and maintainable.

### Conclusion

The `AI-OllamaKasper` package is a powerful tool for enhancing the documentation of Pharo codebases. By leveraging AI models to generate comments, developers can save time and effort while ensuring that their code is well-documented and easy to understand. The package''s extensibility and comprehensive testing make it a valuable addition to any Pharo development environment.'
]

{ #category : 'model system' }
AIACommentBuilding class >> numberExample [
	"Just an experiment on 2+3*4, which in Pharo is 20"
	| a b c op1 op2 operators res prefix|
	operators := { #+. #-. #*. #/}.
	res := WriteStream on: ''.
		prefix := '
				1.	Build a symbol list with clear left-to-right examples:
				•	In Pharo, a + b * c → (a + b) * c
				•	In Pharo, a / b * c → (a / b) * c
				2.	Feed it to the system prompt as training:
				•	“In Pharo, arithmetic follows left-to-right message order. Do not follow standard precedence. Here are examples…”
				3.	Then, the model will:
				•	Answer correctly for Pharo-style expressions
				•	Maybe even reformat expressions to match Pharo rules
				•	Distinguish between normal math and Pharo evaluation when asked
			'.
	res << '' << String cr.
	1 to: 10 do:[ :dummy | | e1 e2 e3|
		a := (Random new nextIntegerBetween: 1 and: 100).
		b := (Random new nextIntegerBetween: 1 and: 100).
		c := (Random new nextIntegerBetween: 1 and: 100).	
		op1 := operators at: (Random new nextIntegerBetween: 1 and: operators size).
		op2 := operators at: (Random new nextIntegerBetween: 1 and: operators size).
		e1 := a asString, op1, b asString, op2, c asString.
		e2 := '(', a asString, op1, b asString, ')', op2, c asString.
		e3 := (a perform: op1 with: b) perform: op2 with: c.
		res << (prefix, ' Example: ', e1, ' is interpreted as ', e2, ' giving ', e3 asString, String cr)
	].
	res << String cr.
	^ res contents.
]

{ #category : 'accessing' }
AIACommentBuilding >> getResponse [
	"Method initiates AI process to retrieve response displaying progress and handling interruptions. Uses system progress morph to show progress and allows interruption. Returns response from AI API."
	
	aiaApi getResponse
]

{ #category : 'accessing' }
AIACommentBuilding >> getResponse_old [
	"This method initiates an AI process to retrieve a response, displaying progress and handling interruptions."
	| aiProcess |
	aiProcess := [ aiaApi getResponse ] newProcess.
	aiProcess resume.
	[ :job |
		SystemProgressMorph uniqueInstance position: 10@20.
		job title: 'Waiting for AI response...'.
		job interruptBlock: [ 
			aiProcess terminate.
			aiaApi response: 'AI based response Terminated'.
			^ self
		].
		1 to: 300 do: [:each |
			job
				progress: ((1/300) * each) ;
				title: 'AI working ', (each/10) asFloat printString, ' of 30'.
				aiaApi response ifEmpty: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'initialization' }
AIACommentBuilding >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	aiaApi := self class ailienApi new.
]

{ #category : 'accessing' }
AIACommentBuilding >> prompt [

	^ aiaApi prompt
]

{ #category : 'accessing' }
AIACommentBuilding >> prompt: anObject [

	aiaApi prompt: anObject
]

{ #category : 'accessing' }
AIACommentBuilding >> response [

	^ aiaApi response
]

{ #category : 'accessing' }
AIACommentBuilding >> system [

	^ aiaApi system
]

{ #category : 'accessing' }
AIACommentBuilding >> system: anObject [

	aiaApi system: anObject
]
