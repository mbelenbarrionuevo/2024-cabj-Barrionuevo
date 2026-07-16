Class {
	#name : 'Game',
	#superclass : 'Object',
	#instVars : [
		'turnManager',
		'finishLine',
		'board',
		'spaceshipsCardHands',
		'aActiveDeck',
		'dice',
		'spaceships',
		'cellToEnter',
		'spaceshipsWithHyperGravity',
		'anAllyTankManager'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
Game class >> numberOfSpaceships: anAmount with: aBoardCreator playWith: aCollectionOfDice andGameDeck: anEffectManager [

	^ self new
		  initializeNumberOfSpaceships: anAmount
		  with: aBoardCreator
		  playWith: aCollectionOfDice
		  andGameDeck: anEffectManager
]

{ #category : 'activation' }
Game >> activateCard: aCard [

	aActiveDeck activate: aCard
]

{ #category : 'accessing' }
Game >> ally: spaceshipIdOne with: spaceshipIdTwo [
	
	| spaceshipOne spaceshipTwo |
	
	spaceshipOne := spaceships detectSpaceshipWithId: spaceshipIdOne.
	spaceshipTwo := spaceships detectSpaceshipWithId: spaceshipIdTwo.
	anAllyTankManager ally: spaceshipOne with: spaceshipTwo
]

{ #category : 'action' }
Game >> applyHyperGravityOn: aSpaceship withValue: value [
	
	spaceshipsWithHyperGravity at: aSpaceship put: value

	
	
]

{ #category : 'action' }
Game >> checkAndHandleFuelDepletion: aSpaceship startingLap: aStartingLap [

	| spaceshipsWithoutFuel alliesWithoutFuel |
    spaceshipsWithoutFuel := anAllyTankManager spaceshipsWithEmptyFuelTank: aSpaceship.
    spaceshipsWithoutFuel isEmpty ifTrue: [ ^ self ].
    
    (spaceshipsWithoutFuel includes: aSpaceship) ifTrue: [
        turnManager lostTurns: 2 by: aSpaceship.
        aSpaceship resetToCell: 1 andLap: aStartingLap.
        aSpaceship loadFuel.
    ].
    
    alliesWithoutFuel := spaceshipsWithoutFuel copyWithout: aSpaceship.
    alliesWithoutFuel do: [ :ally |
        turnManager lostTurns: 2 by: ally.
        ally resetToOne.
        ally loadFuel.
    ]
]

{ #category : 'checking' }
Game >> checkMoveIsPossible: throwResult for: aSpaceship [

	| positionOfSpaceship aNumberOfMovements |
	aNumberOfMovements := throwResult.
	positionOfSpaceship := aSpaceship position.

	(spaceshipsWithHyperGravity includesKey: aSpaceship) ifTrue: [
		throwResult < (spaceshipsWithHyperGravity at: aSpaceship)
			ifTrue: [
				aNumberOfMovements := 0.
				^ aNumberOfMovements ]
			ifFalse: [ spaceshipsWithHyperGravity removeKey: aSpaceship ] ].

	aNumberOfMovements := positionOfSpaceship
		                      adjustMovementFor: aNumberOfMovements
		                      withLimits: finishLine.

	^ aNumberOfMovements
]

{ #category : 'action' }
Game >> giveOneCardTo: aSpaceship [

	(spaceshipsCardHands at: aSpaceship) gainACard
]

{ #category : 'initialization' }
Game >> initializeNumberOfSpaceships: anAmount with: aBoardCreator playWith: aCollectionOfDice andGameDeck: anEffectManager [

	aActiveDeck := ActiveDeck startGame.

	finishLine := Position
		              startGameWithCell: aBoardCreator cells
		              andLap: aBoardCreator laps.

	dice := aCollectionOfDice.

	spaceships := CollectionOfSpaceships
		              numberOfSpaceships: anAmount
		              withAmountOfFuel: dice amountOfFaces * 2.

	anAllyTankManager := AllyTankManager manage: spaceships.

	spaceshipsCardHands := Dictionary new.
	spaceships each: [ :spaceship |
    	spaceshipsCardHands at: spaceship put: (SpaceshipCardHand startGameWith: anEffectManager)].

	turnManager := TurnManager manage: spaceships.

	spaceshipsWithHyperGravity := Dictionary new.

	board := aBoardCreator createBoard
]

{ #category : 'accessing' }
Game >> lastCardPlayed [

	^ aActiveDeck lastCardPlayed
]

{ #category : 'accessing' }
Game >> lastCellEffect [

	^ cellToEnter
]

{ #category : 'action' }
Game >> move: spaceship a: numberOfMovements [

	| positionOfSpaceship aNumberOfMovements startingLap |
	aNumberOfMovements := self
		                      checkMoveIsPossible: numberOfMovements
		                      for: spaceship.

	positionOfSpaceship := spaceship position.
	
	startingLap := positionOfSpaceship lap.

	anAllyTankManager
		spaceship: spaceship
		wantsToUse: aNumberOfMovements.

	spaceship move: aNumberOfMovements.

	positionOfSpaceship adjustPositionWith: finishLine.

	self checkAndHandleFuelDepletion: spaceship startingLap: startingLap.
]

{ #category : 'action' }
Game >> moveAllTheSpaceshipsExcept: aSpaceship withValueToMove: aNumberOfMovements [

	spaceships
		each: [ :spaceship | self move: spaceship a: aNumberOfMovements ]
		but: aSpaceship
]

{ #category : 'action' }
Game >> moveSpaceship [

	| positionOfSpaceship throwResult currentSpaceship |
	throwResult := self throwDiceAndCheckEffects.
	currentSpaceship := turnManager spaceshipPlaying.
	positionOfSpaceship := currentSpaceship position.

	self move: currentSpaceship a: throwResult.

	cellToEnter := board at: positionOfSpaceship cell.
	cellToEnter applyEffectTo: currentSpaceship on: self.

	positionOfSpaceship = finishLine ifTrue: [
		dice := GameOver new.
		^ self spaceships positionsOfSpaceships ].

	turnManager nextTurn
]

{ #category : 'action' }
Game >> reloadSpaceship [

	| currentSpaceship |
	currentSpaceship := turnManager spaceshipPlaying.
	currentSpaceship loadFuel.
	currentSpaceship := turnManager nextTurn
]

{ #category : 'removing' }
Game >> removeTheCard: aCardToCancel andSaveTheLastInstantCardPlayed: aCancellationCard [

	aActiveDeck activate: aCancellationCard .
	aActiveDeck removeACard: aCardToCancel
]

{ #category : 'initialization' }
Game >> resetSpaceshipsToCellOne [

	spaceships each: [ :spaceship | spaceship resetToOne ]
]

{ #category : 'activation' }
Game >> spaceshipId: anId useInstantCard: aCard toDoEffectFor: anObject [

	| spaceshipCardHand cardInitialized spaceship |
	cardInitialized := aCard toDoEffectFor: anObject.
	spaceship := spaceships detectSpaceshipWithId: anId.
	spaceshipCardHand := spaceshipsCardHands at: spaceship.
	(spaceshipCardHand use: aCard) ifTrue: [
		cardInitialized activateEffectOn: self forSpaceship: anId ]
]

{ #category : 'accessing' }
Game >> spaceships [

	^ spaceships 
]

{ #category : 'accessing' }
Game >> stopAlly: aSpaceshipId [

	| spaceshipOne |
	spaceshipOne := spaceships detectSpaceshipWithId: aSpaceshipId.
	anAllyTankManager stopAlly: spaceshipOne
]

{ #category : 'action' }
Game >> throwDiceAndCheckEffects [

	| throwResult maxThrow randomValue currentSpaceship |
	randomValue := Random new next.
	throwResult := dice throw.
	currentSpaceship := turnManager spaceshipPlaying.

	throwResult := aActiveDeck
		               applyEffectOn: throwResult
		               withCurrentSpaceship: currentSpaceship id.

	maxThrow := dice amountOfFaces.
	throwResult = maxThrow ifTrue: [
		randomValue < 0.8
			ifTrue: [ currentSpaceship changeCapacity: 1 ]
			ifFalse: [ currentSpaceship objectFuelTank useFuel: 1 ] ].
	^ throwResult
]

{ #category : 'activation' }
Game >> usePermanentCard: aCard toDoEffectFor: anId [

	| currentSpaceshipCardHand cardInitialized currentSpaceship |
	currentSpaceship := turnManager spaceshipPlaying.
	cardInitialized := aCard toDoEffectFor: anId.
	currentSpaceshipCardHand := spaceshipsCardHands at: currentSpaceship.
	(currentSpaceshipCardHand use: aCard) ifFalse: [ ^ self ].
	cardInitialized
		activateEffectOn: self
		forSpaceship: currentSpaceship id
]

{ #category : 'results' }
Game >> winner [

	^ (spaceships ranking at: 1) id
]
