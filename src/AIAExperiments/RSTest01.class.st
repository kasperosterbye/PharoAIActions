Class {
	#name : 'RSTest01',
	#superclass : 'Object',
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'adding' }
RSTest01 >> addActor: aString at: xPos [
]

{ #category : 'adding' }
RSTest01 >> addMessage: aString from: actor1 to: actor2 at: yPos [ 
]

{ #category : 'adding' }
RSTest01 >> addReturn: aString from: actor2 to: actor1 at: yPos [
]

{ #category : 'tests' }
RSTest01 >> test02 [
| canvas loginBox dbBox loginLine dbLine msg1 msg1Label msg2 msg2Label |
canvas := RSCanvas new.

"Boksene"
loginBox := RSComposite new shapes: {
    (RSBox new width: 120; height: 40; color: Color white; borderColor: Color black).
    (RSLabel new text: 'Login System') }.
dbBox := RSComposite new shapes: {
    (RSBox new width: 120; height: 40; color: Color white; borderColor: Color black).
    (RSLabel new text: 'Database') }.

loginBox translateTo: 0 @ 0.
dbBox translateTo: 250 @ 0.

"Lifelines"
loginLine := RSLine new
    startPoint: 0 @ 20;
    endPoint: 0 @ 300;
    dashArray: #(5 5);
    color: Color black.
dbLine := RSLine new
    startPoint: 250 @ 20;
    endPoint: 250 @ 300;
    dashArray: #(5 5);
    color: Color black.

"Verify credentials - solid pil"
msg1 := RSPolyline new
    controlPoints: { 0 @ 100. 250 @ 100 };
    color: Color black;
    markerEnd: (RSShapeFactory arrow size: 10) asMarker;
	 yourself .

msg1Label := RSLabel new
    text: 'Verify credentials';
    translateTo: 125 @ 85.

"Return verification result - stiplet pil"
msg2 := RSPolyline new
    controlPoints: { 250 @ 140. 0 @ 140 };
    dashArray: #(5 5);
    color: Color black;
    markerEnd: (RSShapeFactory arrow size: 10) asMarker;
	yourself.

msg2Label := RSLabel new
    text: 'Return verification result';
    translateTo: 125 @ 125.

canvas
    add: loginBox;
    add: dbBox;
    add: loginLine;
    add: dbLine;
    add: msg1;
    add: msg1Label;
    add: msg2;
    add: msg2Label.

canvas @ RSCanvasController.
canvas open
]
