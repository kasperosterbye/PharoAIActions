# AIActions – Examples

This file contains example usages of the AIActions package and sample AI-generated responses.


## Method and Class Comments

```smalltalk
(EpLog >> #priorEntriesFrom:upTo:) aiaComment.
"→ 'Returns value at key if present, otherwise puts and returns new value.'"

(EpLog >> #priorEntriesFrom:upTo:) aiaWhiteComment.
"→ 'Answer the element at index, or if absent, put the result of evaluating the block and answer that.'"

EpLog aiaComment.
"→ AI-generated class comment for EpLog."

'Epicea' aiaComment.
"→ AI-generated comment for the package named 'Epicea'."
```


## Setting Comments
```smalltalk
(EpLog >> #priorEntriesFrom:upTo:) setWhiteComment.
'Epicea' setAIAComment.
```

## Language Variants
It is possible to change the language used in construction of comments

```smalltalk
AIACommentBuilding language: 'French'.
AIACommentBuilding language: 'Polish'.
AIACommentBuilding language: 'Japanese'.
AIACommentBuilding language: 'British'.
```

## Question the AI
It is possible to treat a string as a prompt by the **q** method

```smalltalk
'Is blue more clear than yellow' q.
"→ 'It depends on context. Clarity isn't a strict property of color.'"

'I am Kasper Østerbye. What is my first name' q.
"→ 'Your first name is Kasper.'"

'What is my first name' q.
"→ 'What is my first name'  (stateless model; context lost)"
```


## Source-Based Prompts
It is possible to set the special system background to be used in the questions using **q:**

```smalltalk
'In Pharo, what is the instance variables of class EpLog. Just the result, no comments' q.
"→ #(#name #level #message #timeStamp)"


'In Pharo, what is the instance variables of class EpLog. Just the result, no comments' q: [
   AIASourceCodeBuilder new forClass: EpLog.
].

'What is this code about, and who wrote this code' q: [
   ZnClient new
      url: 'https://raw.githubusercontent.com/pharo-project/pharo/refs/heads/Pharo14/doc/Regex/7-History.md';
      get.
].
```







