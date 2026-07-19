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
		'anAllyTankManager',
		'rewardManager'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
Game class >> numberOfSpaceships: arg1 with: arg2 playWith: arg3 andGameDeck: arg4 [

	^ self new
		  initializeNumberOfSpaceships: arg1
		  with: arg2
		  playWith: arg3
		  andGameDeck: arg4
]

{ #category : 'activation' }
Game >> activateCard: arg1 [

	aActiveDeck activate: arg1
]

{ #category : 'accessing' }
Game >> ally: arg1 with: arg2 [

	| tmp1 tmp2 |
	tmp1 := spaceships detectSpaceshipWithId: arg1.
	tmp2 := spaceships detectSpaceshipWithId: arg2.
	anAllyTankManager ally: tmp1 with: tmp2
]

{ #category : 'action' }
Game >> applyHyperGravityOn: arg1 withValue: arg2 [

	spaceshipsWithHyperGravity at: arg1 put: arg2
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
Game >> checkMoveIsPossible: arg1 for: arg2 [

	| tmp1 tmp2 |
	tmp2 := arg1.
	tmp1 := arg2 position.
	(spaceshipsWithHyperGravity includesKey: arg2) ifTrue: [
			arg1 < (spaceshipsWithHyperGravity at: arg2) ifTrue: [
					tmp2 := 0.
					^ tmp2 ].
			spaceshipsWithHyperGravity removeKey: arg2 ].
	tmp2 := tmp1 adjustMovementFor: tmp2 withLimits: finishLine.
	^ tmp2
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
Game >> moveAllTheSpaceshipsExcept: arg1 withValueToMove: arg2 [

	spaceships each: [ :arg3 | self move: arg3 a: arg2 ] but: arg1
]

{ #category : 'action' }
Game >> moveSpaceship [

	| tmp1 tmp2 tmp3 |
	tmp2 := self throwDiceAndCheckEffects.
	tmp3 := turnManager spaceshipPlaying.
	tmp1 := tmp3 position.
	self move: tmp3 a: tmp2.
	cellToEnter := board at: tmp1 cell.
	cellToEnter applyEffectTo: tmp3 on: self.
	tmp1 = finishLine ifTrue: [
			dice := GameOver new.
			^ self spaceships positionsOfSpaceships ].
	nil.
	turnManager nextTurn
]

{ #category : 'action' }
Game >> reloadSpaceship [

	| tmp1 |
	tmp1 := turnManager spaceshipPlaying.
	tmp1 loadFuel.
	tmp1 := turnManager nextTurn
]

{ #category : 'removing' }
Game >> removeTheCard: arg1 andSaveTheLastInstantCardPlayed: arg2 [

	aActiveDeck
		activate: arg2;
		removeACard: arg1
]

{ #category : 'initialization' }
Game >> resetSpaceshipsToCellOne [

	spaceships each: [ :arg1 | arg1 resetToOne ]
]

{ #category : 'results' }
Game >> rewardManager [
    ^ rewardManager ifNil: [ rewardManager := RewardManager withRandomProvider: Random new ]

]

{ #category : 'accessing' }
Game >> rewardManager: aRewardManager [
    rewardManager := aRewardManager
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
Game >> stopAlly: arg1 [

	| tmp1 |
	tmp1 := spaceships detectSpaceshipWithId: arg1.
	anAllyTankManager stopAlly: tmp1
]

{ #category : 'action' }
Game >> throwDiceAndCheckEffects [
	| tmp1 tmp2 tmp4 |
	tmp1 := dice throw.
	tmp4 := turnManager spaceshipPlaying.
	tmp1 := aActiveDeck applyEffectOn: tmp1 withCurrentSpaceship: tmp4 id.
	tmp2 := dice amountOfFaces.
	tmp1 = tmp2 ifTrue: [
		self rewardManager applyRewardOn: tmp4 ]. "<- Cambiado aquí"
	^ tmp1

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
