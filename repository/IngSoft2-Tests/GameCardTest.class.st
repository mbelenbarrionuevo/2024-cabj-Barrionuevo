Class {
	#name : 'GameCardTest',
	#superclass : 'TestCase',
	#instVars : [
		'aLoadedDie',
		'aWormholeCreator',
		'aBoardCreator',
		'collectionOfCells',
		'gameDeck'
	],
	#category : 'IngSoft2-Tests',
	#package : 'IngSoft2-Tests'
}

{ #category : 'running' }
GameCardTest >> createGameFor: anAmountOfSpaceships withDice: aDie deck: aDeck [
	| aGame aRewardManager |
	aGame := Game
		         numberOfSpaceships: anAmountOfSpaceships
		         with: aBoardCreator
		         playWith: aDie
		         andGameDeck: aDeck.
	aRewardManager := RewardManager withRandomProvider: (LoadedRandomProvider with: #( 0.5 )).
	aGame rewardManager: aRewardManager.
	^ aGame
]

{ #category : 'running' }
GameCardTest >> setUp [

	super setUp.
	aLoadedDie := LoadedDie of: #( 6 ).

	aWormholeCreator := WormholeCreator withBeginning: 2 andEnd: 3.
	collectionOfCells := OrderedCollection new.

	30 timesRepeat: [ collectionOfCells add: Cell new ].

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	gameDeck := LoadedEffectManager manage: (OrderedCollection
			             with: AccelerationCard
			             with: AllyCard
			             with: OverloadCard
			             with: RedoCard
			             with: RepeatCard
			             with: CancellationCard)
]

{ #category : 'running' }
GameCardTest >> should: anErrorBlock raise: anErrorClass withMessage: anErrorMessage [

	self
		should: anErrorBlock
		raise: anErrorClass
		withExceptionDo: [ :error |
		self assert: error messageText equals: anErrorMessage ]
]

{ #category : 'acceleration' }
GameCardTest >> test03WhenOneAccelerationCardIsActiveThenSpaceshipMovesOneMoreThanThrowResult [

	| result aGame |
	aGame := self createGameFor: 1 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.

	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 8.


	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'overload' }
GameCardTest >> test05SpaceshipOnePlaysOverloadToSpaceshipTwoThenTwoMovesLessTwo [

	| result aGame |
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: OverloadCard toDoEffectFor: 2.
	aGame moveSpaceship.

	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 7.
	result at: 2 put: 5.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'ally' }
GameCardTest >> test06GameActivatesAllyCardThenSpaceshipOneCanUseFuelFromSpaceshipTwo [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 1 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.


	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 22.
	result at: 2 put: 4.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'ally' }
GameCardTest >> test07BothAllysRunOutOfFuelThenBothLooseTwoTurns [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 ).

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 1.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'cancellation' }
GameCardTest >> test10SpaceshipThreeRemovesOverloadCardThenItMovesWithoutEffect [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 7 ).

	aGame := self createGameFor: 3 withDice: aLoadedDie deck: gameDeck.


	aGame usePermanentCard: OverloadCard toDoEffectFor: 2.
	aGame moveSpaceship.
	aGame usePermanentCard: OverloadCard toDoEffectFor: 3.
	aGame moveSpaceship.

	aGame
		spaceshipId: 2
		useInstantCard:
		CancellationCard
		toDoEffectFor: (OverloadCard toDoEffectFor: 3).
	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 6.
	result at: 3 put: 8.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'cancellation' }
GameCardTest >> test11CancelAllyCardThenBothSpaceshipsUseOnlyTheirFuelTank [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 1 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame moveSpaceship.
	aGame
		spaceshipId: 2
		useInstantCard: CancellationCard
		toDoEffectFor: (AllyCard toDoEffectFor: 2).
	aGame moveSpaceship.
	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 1.
	result at: 2 put: 3.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'instant card' }
GameCardTest >> test12InstancCardPlayedOnAnoterSpaceshipsTurnThenInstantCardCanDoTheEffect [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: OverloadCard toDoEffectFor: 2.
	aGame
		spaceshipId: 2
		useInstantCard: CancellationCard
		toDoEffectFor: (OverloadCard toDoEffectFor: 2).
	aGame moveSpaceship.
	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 8.


	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'cancellation' }
GameCardTest >> test13AccelerationCardPlayedAndCancelledThenSpaceshipMovesWithoutEffect [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame
		spaceshipId: 2
		useInstantCard:
		CancellationCard
		toDoEffectFor: AccelerationCard new.
	aGame moveSpaceship.
	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 8.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'redo ' }
GameCardTest >> test14TwoRedoCardsPlayedAfterAccelerationThenSpaceshipMovesThreeCellsMore [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame spaceshipId: 2 useInstantCard: RedoCard toDoEffectFor: nil.
	aGame spaceshipId: 1 useInstantCard: RedoCard toDoEffectFor: 2.

	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 11.
	result at: 2 put: 1.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'redo ' }
GameCardTest >> test15RedoCardPlayedAfterOverloadThenSpaceshipsAffectedHaveLessMovement [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 7 ).

	aGame := self createGameFor: 3 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: OverloadCard toDoEffectFor: 2.
	aGame spaceshipId: 1 useInstantCard: RedoCard toDoEffectFor: 3.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 6.
	result at: 3 put: 6.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'redo ' }
GameCardTest >> test16RedoCardPlayedAfterAllyThenSpaceshipsThreeAndFourShareFuelBeacuseOfIt [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 7 7 7 1 ).
	
	aGame := self createGameFor: 4 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame spaceshipId: 3 useInstantCard: RedoCard toDoEffectFor: 4.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 1.
	result at: 2 put: 1.
	result at: 3 put: 15.
	result at: 4 put: 4.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'redo ' }
GameCardTest >> test17TwoAccelerationCardsPlayThenACancellationAndARedoSoNoAccelerationEffectOccurs [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 7 7 7 1 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame spaceshipId: 2 useInstantCard: RedoCard toDoEffectFor: nil.
	aGame
		spaceshipId: 2
		useInstantCard: CancellationCard
		toDoEffectFor: AccelerationCard new.
	aGame
		spaceshipId: 1
		useInstantCard: RedoCard
		toDoEffectFor: AccelerationCard new.

	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test18SpaceshipOneEntersBlackHoleAndSpaceshipTwoRepeatsEffectThenSpaceshipOneIsInPositionOne [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 5 ).
	aWormholeCreator := WormholeCreator withBeginning: 2 andEnd: 3.
	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 1.

	result := Dictionary new.
	result at: 1 put: 1.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test19ReapeatCardRepeatsACellThenNothingChanges [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 9 ).

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 1.

	result := Dictionary new.
	result at: 1 put: 10.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test20RepeatCardRepeatsMoonWalkThenSpaceshipOneMovesBackwards [

	| aGame result |
	aWormholeCreator := WormholeCreator withBeginning: 2 andEnd: 3.
	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells at: 7 put: (MoonWalkCell withValueToMove: 4).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 2.

	result := Dictionary new.
	result at: 1 put: 3.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test21RepeatCardRepeatsAtomicBombThenEverySpaceshipIsOnCellOne [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 4 ).
	aWormholeCreator := WormholeCreator withBeginning: 2 andEnd: 3.
	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells at: 5 put: AtomicBombCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 1.

	result := Dictionary new.
	result at: 1 put: 1.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test22RepeatCardRepeatsHyperJumpThenBothSpaceshipsMoveSameParsecs [

	| aGame result aConversor values |
	aConversor := Conversor totalCells: 4 convertionValue: 8.
	values := OrderedCollection
		          with: (Parsecs ofValue: 10)
		          with: (LightYear ofValue: 24)
		          with: (Parsecs ofValue: 6)
		          with: (Parsecs ofValue: 4).

	aLoadedDie := LoadedDie of: #( 8 ).

	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells
		at: 9
		put: (HyperJumpCell withConversor: aConversor andValues: values).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 2
		                 withWormholeCreator: aWormholeCreator.

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 1 useInstantCard: RepeatCard toDoEffectFor: 2.

	result := Dictionary new.
	result at: 1 put: 4.
	result at: 2 put: 5.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test23RepeatCardRepeatsCardDispenserThenSpaceshipTwoCanPlayTwoAccelerationCards [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 3 3 3 3 80 ).

	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 4 put: CardDispenserCell new.

	gameDeck := LoadedEffectManager manage:
		            (OrderedCollection
			             with: AccelerationCard
			             with: RepeatCard).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 2
		                 withWormholeCreator: aWormholeCreator.

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 2.
	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 10.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test24RepeatCardRepeatsWormholeThenSpaceshipOneGoesToWormhole [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 9 1 ).

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 1.

	result := Dictionary new.
	result at: 1 put: 3.
	result at: 2 put: 3.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'redo ' }
GameCardTest >> test25RedoCardPlayedAfterRepeatCardThenCellEffectRepeatsTwice [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 9 5 10).

	aWormholeCreator := WormholeCreator withBeginning: 2 andEnd: 3.
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame spaceshipId: 2 useInstantCard: RepeatCard toDoEffectFor: 1.
	aGame spaceshipId: 2 useInstantCard: RedoCard toDoEffectFor: 1.

	result := Dictionary new.
	result at: 1 put: 2.
	result at: 2 put: 2.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test26RepeatCardRepeatsHyperGravityThenSpaceshipMovesWithoutImpediment [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 7 1 1 ).
	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 1 useInstantCard: RepeatCard toDoEffectFor: 2.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 3.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test27WhenACardThatIsNotInHandTriesToActivateThenDoesNotDoTheEffectOfIt [

	| result aGame |
	aLoadedDie := LoadedDie of: #( 14 12 12 1 ).
	
	aGame := self createGameFor: 3 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame
		spaceshipId: 1
		useInstantCard: CancellationCard
		toDoEffectFor: AccelerationCard new.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 16.
	result at: 2 put: 13.
	result at: 3 put: 13.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'cancellation' }
GameCardTest >> test28CancellationCardCancelsOnlyTheCardThatIsExactlyTheSameAsTheOneItWantsToCancel [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 7 7 7 7 7 7 7 7 7 7 20 ).

	aGame := Game
		         numberOfSpaceships: 3
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.
	aGame := self createGameFor: 3 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: OverloadCard toDoEffectFor: 2.
	aGame moveSpaceship.
	aGame usePermanentCard: OverloadCard toDoEffectFor: 3.
	aGame moveSpaceship.
	aGame moveSpaceship.

	aGame moveSpaceship.
	aGame
		spaceshipId: 2
		useInstantCard: CancellationCard
		toDoEffectFor: (OverloadCard toDoEffectFor: 2).
	aGame moveSpaceship.
	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 15.
	result at: 2 put: 13.
	result at: 3 put: 11.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test29RepeatHyperGravityForSpaceshipTwoThenItCannotMoveBeacuseOfIt [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 7 2 ).

	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells
		at: 8
		put:
		(HyperGravityCell withValueToMove: aLoadedDie amountOfFaces // 2).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 2
		                 withWormholeCreator: aWormholeCreator.

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 1 useInstantCard: RepeatCard toDoEffectFor: 2.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 1.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'repeat' }
GameCardTest >> test30RepeatHyperGravityForSpaceshipTwoThenItCanMoveBeacuseOfThrowGreaterThenValue [

	| aGame result |
	aLoadedDie := LoadedDie of: #( 7 6 ).

	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].

	collectionOfCells
		at: 8
		put:
		(HyperGravityCell withValueToMove: aLoadedDie amountOfFaces // 2).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 2
		                 withWormholeCreator: aWormholeCreator.


	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship.
	aGame spaceshipId: 1 useInstantCard: RepeatCard toDoEffectFor: 2.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 8.
	result at: 2 put: 7.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'ally' }
GameCardTest >> test31SpaceshipThreeTriesToAllyWithTwoThenItThrowAnErrorBecauseTwoAlreadyHasAlly [

	self
		should: [
			| aGame |
			aLoadedDie := LoadedDie of: #( 1 1 7 1 ).
			
			aGame := self createGameFor: 4 withDice: aLoadedDie deck: gameDeck.

			aGame usePermanentCard: AllyCard toDoEffectFor: 2.
			aGame moveSpaceship.
			aGame moveSpaceship.
			aGame usePermanentCard: AllyCard toDoEffectFor: 2 ]
		raise: Error
		withMessage: 'Spaceship 2 already has an ally.'
]

{ #category : 'ally' }
GameCardTest >> test32SpaceshipsTwoChangesCapacityAndOneAnTwoAreAllysThenAmountOfTotalFuelChanges [

	| resultOne aGame resultTwo |
	aLoadedDie := LoadedDie of: #( 6 7 6 14 2 ).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame reloadSpaceship.
	aGame moveSpaceship. 
	aGame moveSpaceship. 

	resultOne := Dictionary new.
	resultOne at: 1 put: 1.
	resultOne at: 2 put: 1.

	resultTwo := Dictionary new.
	resultTwo at: 1 put: 27.
	resultTwo at: 2 put: 10.

	self assert: (aGame spaceships cellsOfSpaceships = resultOne or:
			 aGame spaceships cellsOfSpaceships = resultTwo)
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test33GamePlaysWithDeckWithProbabilisticDistributionThenSpaceshipCardHandAlwaysInitializedWithTwoCards [

	| result aGame |
	gameDeck := EffectManager
		            manage: (OrderedCollection with: AccelerationCard)
		            withProbabilitiesDistribution: #( 100 ).
	aLoadedDie := LoadedDie of: #( 4 ).
	
	aGame := self createGameFor: 1 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 7.

	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test34AllysInDifferentLapsRunOutOfFuelThenEachReturnsToTheirOwnLapStart [
	| aGame resultCells resultLaps |
	aWormholeCreator := WormholeCreator withBeginning: 8 andEnd: 9.
	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 3
		                 withWormholeCreator: aWormholeCreator.
	gameDeck := LoadedEffectManager manage: (OrderedCollection
			             with: AccelerationCard
			             with: AllyCard
			             with: OverloadCard
			             with: RedoCard
			             with: RepeatCard
			             with: CancellationCard).

	aLoadedDie := LoadedDie of: #( 6 3 6 3 6 3 6 7 ).
	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame moveSpaceship. 
	aGame moveSpaceship. 
	
	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	 
	resultCells := Dictionary new.
	resultCells at: 1 put: 1.
	resultCells at: 2 put: 1.
	resultLaps := Dictionary new.
	resultLaps at: 1 put: 2. 
	resultLaps at: 2 put: 1. 
	self assert: aGame spaceships cellsOfSpaceships equals: resultCells.
	self assert: aGame spaceships lapsOfSpaceships equals: resultLaps.
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test35SpaceshipFallsOnBlackHoleWithInsufficientFuelUsesAllyFuel [

	| aGame |
	aWormholeCreator := WormholeCreator withBeginning: 8 andEnd: 9.
	collectionOfCells := OrderedCollection new.
	10 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 2
		                 withWormholeCreator: aWormholeCreator.

	gameDeck := LoadedEffectManager manage: (OrderedCollection with: AllyCard).
	aLoadedDie := LoadedDie of: #( 5 6).

	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	aGame usePermanentCard: AllyCard toDoEffectFor: 2.

	(aGame spaceships detectSpaceshipWithId: 1) fuelTank useFuel: 8.
	
	aGame moveSpaceship.

	self assert: (aGame spaceships detectSpaceshipWithId: 1) fuelTank loadedWith equals: 0.
	self assert: (aGame spaceships detectSpaceshipWithId: 2) fuelTank loadedWith equals: 7.
	self assert: ((aGame spaceships detectSpaceshipWithId: 1) position cell) equals: 2.

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test36SpaceshipCancelsAllyCardThenAllianceStops [
   | aGame spaceshipOne spaceshipTwo |
	aLoadedDie := LoadedDie of: #( 9 1 9 1 9 ).
	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: gameDeck.

	spaceshipOne := aGame spaceships resolve: 1.
	spaceshipTwo := aGame spaceships resolve: 2.
	
	aGame usePermanentCard: AllyCard toDoEffectFor: spaceshipTwo.
	
	aGame spaceshipId: spaceshipOne useInstantCard: CancellationCard toDoEffectFor: (AllyCard toDoEffectFor: spaceshipTwo).
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	
	self assert: spaceshipTwo amountOfFuel equals: 6
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test37SpaceshipPlaysReversePolarityOnBlackHoleThenAllOtherSpaceshipsRetrogress [
   | aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.
	
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .

	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	
	result := Dictionary new.
	result at: 1 put: 6.
	result at: 2 put: 6.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test38SpaceshipPlaysReversePolarityOnMoonWalkThenOnlyLandingSpaceshipMoves [
	| aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	collectionOfCells at: 6 put: (MoonWalkCell withValueToMove: 2).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 4.
	result at: 2 put: 10.

	self assert: aGame spaceships cellsOfSpaceships equals: result

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test39SpaceshipPlaysReversePolarityOnAtomicBombThenNoSpaceshipIsAffected [
	| aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	collectionOfCells at: 6 put: AtomicBombCell new.
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	
	result := Dictionary new.
	result at: 1 put: 6.
	result at: 2 put: 10.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test40SpaceshipPlaysTwoReversePolarityCardsOnBlackHoleThenNormalEffectApplies [
	| aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 2.
	result at: 2 put: 10.

	self assert: aGame spaceships cellsOfSpaceships equals: result

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test41SpaceshipPlaysReversePolarityThenCancelsItThenNormalEffectApplies [
	| aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: CancellationCard
		                  with: ReversePolarityCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	
	aGame
		spaceshipId: 1
		useInstantCard: CancellationCard
		toDoEffectFor: (ReversePolarityCard toDoEffectFor: 6).
	
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	
	result := Dictionary new.
	result at: 1 put: 2.
	result at: 2 put: 10.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test42SpaceshipPlaysReversePolarityOnWormholeThenAllOtherSpaceshipsAreMovedToExit [
	| aGame result customGameDeck aCustomWormholeCreator aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	aCustomWormholeCreator := WormholeCreator withBeginning: 6 andEnd: 12.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aCustomWormholeCreator.

	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).

	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.

	result := Dictionary new.
	result at: 1 put: 6.
	result at: 2 put: 12.

	self assert: aGame spaceships cellsOfSpaceships equals: result

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test43SpaceshipPlaysReversePolarityOnCardDispenserThenAllOtherSpaceshipsGainCard [
	| aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: CardDispenserCell new.
	collectionOfCells at: 8 put: BlackHoleCell new.
	collectionOfCells at: 12 put: BlackHoleCell new.
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: AccelerationCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 8.
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 12.
	
	aGame moveSpaceship.
	result := Dictionary new.
	
	result at: 1 put: 2.
	result at: 2 put: 12.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test44SpaceshipPlaysReversePolarityOnHyperGravityThenAllOtherSpaceshipsGetHyperGravity [
	| aGame result customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 2 ). 
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	collectionOfCells at: 6 put: (HyperGravityCell withValueToMove: 4).
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	
	result := Dictionary new.
	result at: 1 put: 6.
	result at: 2 put: 10.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test45SpaceshipPlaysReversePolarityOnHyperJumpThenAllOtherSpaceshipsJump [
	| aGame result customGameDeck aConversor aRewardManager |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	aConversor := Conversor totalCells: 30 convertionValue: 30.
	collectionOfCells at: 6 put: (HyperJumpCell withConversor: aConversor andValues: (OrderedCollection with: (Parsecs ofValue: 5))).
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	aGame moveSpaceship.
	aGame moveSpaceship.
	aGame moveSpaceship.
	result := Dictionary new.
	
	result at: 1 put: 6.
	result at: 2 put: 15.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test46SpaceshipLaunchesWithThreeTurbines [
	| spaceship |
	spaceship := Spaceship launchWithFuel: 10.
	self assert: spaceship turbines equals: 3.
	self assert: spaceship hasTurbines
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test47SpaceshipEntersBlackHoleLosesOneTurbine [
	| aGame customGameDeck  |
	aLoadedDie := LoadedDie of: #( 5 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: AccelerationCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	
	aGame moveSpaceship. 
	self assert: (aGame spaceships resolve: 1) turbines equals: 2
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test48SpaceshipFailsToExitHyperGravityLosesOneTurbine [
	| aGame customGameDeck aRewardManager |
	aLoadedDie := LoadedDie of: #( 5 9 2 ). "Turno 1: N1 va al 6 (HyperGravity 4), Turno 2: N2 va al 10, Turno 3: N1 saca 2 (<4)"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: (HyperGravityCell withValueToMove: 4).
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: AccelerationCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship.
	
	self assert: (aGame spaceships resolve: 1) turbines equals: 2
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test49SpaceshipRunsOutOfFuelLosesOneTurbine [
	| aGame customGameDeck  spaceshipOne aRewardManager |
	aLoadedDie := LoadedDie of: #( 9 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: AccelerationCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	spaceshipOne := aGame spaceships resolve: 1.
	spaceshipOne fuelTank useFuel: (spaceshipOne amountOfFuel - 2).
	aRewardManager := RewardManager withRandomProvider: (LoadedRandomProvider with: #( 0.5 )).
	aGame rewardManager: aRewardManager.
	aGame moveSpaceship. 
	
	self assert: spaceshipOne turbines equals: 2
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test50SpaceshipLosesAllTurbinesIsEliminatedAndSkipped [
	| aGame customGameDeck spaceshipOne spaceshipTwo |
	aLoadedDie := LoadedDie of: #( 5 9 4 9 4 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: AccelerationCard).
	aGame := self createGameFor: 2 withDice: aLoadedDie deck: customGameDeck .
	spaceshipOne := aGame spaceships resolve: 1.
	spaceshipTwo := aGame spaceships resolve: 2.

	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 
	aGame moveSpaceship. 

	self assert: spaceshipOne turbines equals: 0.
	self deny: spaceshipOne hasTurbines.

	
	aGame moveSpaceship.
	self assert: (aGame spaceships resolve: 2) equals: spaceshipTwo

]
