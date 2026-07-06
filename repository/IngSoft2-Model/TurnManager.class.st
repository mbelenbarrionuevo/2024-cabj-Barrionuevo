Class {
	#name : 'TurnManager',
	#superclass : 'Object',
	#instVars : [
		'spaceships',
		'currentSpaceship',
		'turnsToSkip'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
TurnManager class >> manage: collectionOfSpaceships [ 
	^(self new) initializeManage: collectionOfSpaceships .
]

{ #category : 'action' }
TurnManager >> decrementTurnsOfSpaceship [

	turnsToSkip
		at: currentSpaceship
		put: (turnsToSkip at: currentSpaceship) - 1
]

{ #category : 'initialization' }
TurnManager >> initializeManage: collectionOfSpaceships [

	spaceships := collectionOfSpaceships collect: [ :spaceship |
		              spaceship ].

	currentSpaceship := spaceships first.
	turnsToSkip := Dictionary new.
	collectionOfSpaceships each: [ :spaceship |
		turnsToSkip at: spaceship put: 0 ]
]

{ #category : 'action' }
TurnManager >> lostTurns: anAmountOfTurns by: aSpaceship [

	(turnsToSkip at: aSpaceship) = 0 ifTrue: [
		turnsToSkip at: aSpaceship put: anAmountOfTurns ]
]

{ #category : 'auxiliar' }
TurnManager >> nextSpaceship [

	| currentIndex nextIndex |
	currentIndex := spaceships indexOf: currentSpaceship.
	nextIndex := currentIndex + 1.
	nextIndex > spaceships size ifTrue: [ nextIndex := 1 ].
	currentSpaceship := spaceships at: nextIndex
]

{ #category : 'action' }
TurnManager >> nextTurn [

	self nextSpaceship.
	[ (turnsToSkip at: currentSpaceship) > 0 ] whileTrue: [
		self decrementTurnsOfSpaceship.
		self nextSpaceship ]
]

{ #category : 'accessing' }
TurnManager >> spaceshipPlaying [

	^ currentSpaceship
]
