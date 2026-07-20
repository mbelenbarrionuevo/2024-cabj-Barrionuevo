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
Game >> ally: aSpaceshipOrIdOne with: aSpaceshipOrIdTwo [

    | firstSpaceship secondSpaceship |

	firstSpaceship := spaceships resolve: aSpaceshipOrIdOne.
    secondSpaceship := spaceships resolve: aSpaceshipOrIdTwo.
    anAllyTankManager ally: firstSpaceship with: secondSpaceship
]

{ #category : 'accessing' }
Game >> applyEffectOf: aCell to: aSpaceship [
    | targets |
	targets := self resolveTargetsFor: aCell landingSpaceship: aSpaceship.
	targets do: [ :target | aCell applyBaseEffectTo: target on: self ]
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
        aSpaceship loseTurbine.
        turnManager lostTurns: 2 by: aSpaceship.
        aSpaceship resetToCell: 1 andLap: aStartingLap.
        aSpaceship loadFuel.
    ].
    
    alliesWithoutFuel := spaceshipsWithoutFuel copyWithout: aSpaceship.
    alliesWithoutFuel do: [ :ally |
        ally loseTurbine.
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
                    arg2 loseTurbine.
                    tmp2 := 0.
                    ^ tmp2 ].
            spaceshipsWithHyperGravity removeKey: arg2 ].
    tmp2 := tmp1 adjustMovementFor: tmp2 withLimits: finishLine.
    ^ tmp2
]

{ #category : 'action' }
Game >> effectiveTargetTypeFor: normalTargetType isReversed: isReversed [
	isReversed ifFalse: [ ^ normalTargetType ].
	normalTargetType = #single ifTrue: [ ^ #allExceptSingle ].
	normalTargetType = #allExceptSingle ifTrue: [ ^ #single ].
	normalTargetType = #all ifTrue: [ ^ #none ].
	^ normalTargetType
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

{ #category : 'action' }
Game >> resolveTargetsFor: aCell landingSpaceship: aSpaceship [
     | cellIndex activeCards isReversed effectiveTargetType allSpaceships |
	cellIndex := board indexOf: aCell.
	activeCards := aActiveDeck activeReversePolarityCardsFor: cellIndex.
	isReversed := activeCards size odd.
	
	effectiveTargetType := self effectiveTargetTypeFor: aCell targetType isReversed: isReversed.
	allSpaceships := spaceships collect: [ :s | s ].
	effectiveTargetType = #single ifTrue: [ ^ OrderedCollection with: aSpaceship ].
	effectiveTargetType = #allExceptSingle ifTrue: [ ^ allSpaceships copyWithout: aSpaceship ].
	effectiveTargetType = #all ifTrue: [ ^ allSpaceships ].
	^ OrderedCollection new
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

	 | spaceshipCardHand cardInitialized spaceship target |
    spaceship := spaceships resolve: anId. 
    target := spaceships resolve: anObject. 
                      
    cardInitialized := aCard toDoEffectFor: target.
    spaceshipCardHand := spaceshipsCardHands at: spaceship.
    (spaceshipCardHand use: aCard) ifTrue: [
        cardInitialized activateEffectOn: self forSpaceship: spaceship ]
]

{ #category : 'accessing' }
Game >> spaceships [

	^ spaceships
]

{ #category : 'accessing' }
Game >> stopAlly: aSpaceshipOrId [

	| spaceshipToStop |
    spaceshipToStop := spaceships resolve: aSpaceshipOrId.
    anAllyTankManager stopAlly: spaceshipToStop
]

{ #category : 'action' }
Game >> throwDiceAndCheckEffects [
	| throwResult maxThrow currentSpaceship |
	throwResult := dice throw.
	currentSpaceship := turnManager spaceshipPlaying.
	throwResult := aActiveDeck applyEffectOn: throwResult withCurrentSpaceship: currentSpaceship.
	maxThrow := dice amountOfFaces.
	throwResult = maxThrow ifTrue: [
		self rewardManager applyRewardOn: currentSpaceship ].
	^ throwResult

]

{ #category : 'activation' }
Game >> usePermanentCard: aCard toDoEffectFor: anId [

	| currentSpaceshipCardHand cardInitialized currentSpaceship targetSpaceship |
    currentSpaceship := turnManager spaceshipPlaying.
    targetSpaceship := spaceships resolve: anId. 
                               
    cardInitialized := aCard toDoEffectFor: targetSpaceship.
    currentSpaceshipCardHand := spaceshipsCardHands at: currentSpaceship.
    (currentSpaceshipCardHand use: aCard) ifFalse: [ ^ self ].
    cardInitialized
        activateEffectOn: self
        forSpaceship: currentSpaceship
]

{ #category : 'results' }
Game >> winner [

	^ (spaceships ranking at: 1) id
]
