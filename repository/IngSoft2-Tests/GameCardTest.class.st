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
	aGame := Game
		         numberOfSpaceships: 1
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

	aGame usePermanentCard: AccelerationCard toDoEffectFor: nil.

	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 8.


	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'overload' }
GameCardTest >> test05SpaceshipOnePlaysOverloadToSpaceshipTwoThenTwoMovesLessTwo [

	| result aGame |
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 3
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 3
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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
	aGame := Game
		         numberOfSpaceships: 4
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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
	aGame := Game
		         numberOfSpaceships: 3
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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
			aGame := Game
				         numberOfSpaceships: 4
				         with: aBoardCreator
				         playWith: aLoadedDie
				         andGameDeck: gameDeck.

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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

	aGame usePermanentCard: AllyCard toDoEffectFor: 2.
	aGame moveSpaceship. "1 -> 7"
	aGame moveSpaceship. "2 -> 8"
	aGame moveSpaceship. "1 -> 13"
	aGame reloadSpaceship.
	aGame moveSpaceship. "1 -> 27"
	aGame moveSpaceship. "2 -> 10"

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
	aGame := Game
		         numberOfSpaceships: 1
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.
	
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

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.

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
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: gameDeck.
	
	spaceshipOne := aGame spaceships ranking detect: [ :s | s id = 1 ].
	spaceshipTwo := aGame spaceships ranking detect: [ :s | s id = 2 ].
	
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
   | aGame result customGameDeck |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). 
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.
	
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	"Creamos un mazo cargado únicamente con cartas ReversePolarityCard"
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck. "<- Usamos el mazo personalizado"
	"Jugamos la carta ReversePolarityCard sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	"Turno 1: Nave 1 saca 3 -> va al casillero 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 saca 9 -> va al casillero 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 saca 2 -> cae en el casillero 6 (BlackHoleCell)"
	aGame moveSpaceship.
	result := Dictionary new.
	"Nave 1 cae en el BlackHoleCell pero con la polaridad invertida -> se queda en el 6"
	result at: 1 put: 6.
	"Nave 2 es la afectada por el BlackHoleCell -> retrocede 4 casilleros desde el 10 -> celda 6"
	result at: 2 put: 6.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test38SpaceshipPlaysReversePolarityOnMoonWalkThenOnlyLandingSpaceshipMoves [
	| aGame result customGameDeck |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). "Secuencia para mover ambas naves"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	"Ponemos un MoonWalkCell de valor 2 en el casillero 6"
	collectionOfCells at: 6 put: (MoonWalkCell withValueToMove: 2).

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.

	"Jugamos la carta ReversePolarityCard sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	"Turno 1: Nave 1 saca 3 -> va al casillero 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 saca 9 -> va al casillero 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 saca 2 -> cae en el casillero 6 (MoonWalkCell)"
	aGame moveSpaceship.

	result := Dictionary new.
	"Como la polaridad está invertida, la Nave 1 es la única que retrocede (el efecto de MoonWalk)"
	"Estaba en la celda 6, retrocede 2 casilleros -> termina en la celda 4"
	result at: 1 put: 4.
	"La Nave 2 no es afectada, se queda en la celda 10"
	result at: 2 put: 10.

	self assert: aGame spaceships cellsOfSpaceships equals: result

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test39SpaceshipPlaysReversePolarityOnAtomicBombThenNoSpaceshipIsAffected [
	| aGame result customGameDeck |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). "Nave 1 va al 4, Nave 2 va al 10, Nave 1 va al 6"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	"Ponemos un AtomicBombCell en el casillero 6"
	collectionOfCells at: 6 put: AtomicBombCell new.
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.
	"Jugamos la carta ReversePolarityCard sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	"Turno 1: Nave 1 va al 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 va al 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 cae en el casillero 6 (AtomicBombCell)"
	aGame moveSpaceship.
	result := Dictionary new.
	"Como la polaridad está invertida, la bomba atómica no afecta a NINGUNA nave"
	"Ambas se quedan exactamente donde estaban (Nave 1 en 6, Nave 2 en 10)"
	result at: 1 put: 6.
	result at: 2 put: 10.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test40SpaceshipPlaysTwoReversePolarityCardsOnBlackHoleThenNormalEffectApplies [
	| aGame result customGameDeck |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). "Nave 1 va al 4, Nave 2 va al 10, Nave 1 va al 6"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	"Necesitamos al menos 3 cartas para que la Nave 1 pueda jugar dos de ellas"
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.

	"Jugamos DOS cartas ReversePolarityCard sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	"Turno 1: Nave 1 saca 3 -> va al casillero 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 saca 9 -> va al casillero 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 saca 2 -> cae en el casillero 6 (BlackHoleCell)"
	aGame moveSpaceship.

	result := Dictionary new.
	"Como hay 2 cartas (par), la polaridad se anula -> actúa el efecto normal"
	"Nave 1 es la afectada por el BlackHoleCell -> retrocede 4 casilleros desde el 6 -> celda 2"
	result at: 1 put: 2.
	"Nave 2 no es afectada -> se queda en la celda 10"
	result at: 2 put: 10.

	self assert: aGame spaceships cellsOfSpaceships equals: result

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test41SpaceshipPlaysReversePolarityThenCancelsItThenNormalEffectApplies [
	| aGame result customGameDeck activeDeck cards reversePolarityCardInstance |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). "Nave 1 va al 4, Nave 2 va al 10, Nave 1 va al 6"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	collectionOfCells at: 6 put: BlackHoleCell new.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.

	"Cargamos la mano de Nave 1 con ReversePolarityCard y CancellationCard"
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: CancellationCard
		                  with: ReversePolarityCard).

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.

	"Jugamos la carta de polaridad sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	"Buscamos la instancia que se activó en el ActiveDeck para poder cancelarla"
	activeDeck := aGame instVarNamed: #aActiveDeck.
	cards := activeDeck instVarNamed: #cards.
	reversePolarityCardInstance := cards detect: [ :card | card isReversePolarity ].

	"Nave 1 juega CancellationCard sobre la carta activa de polaridad"
	aGame spaceshipId: 1 useInstantCard: CancellationCard toDoEffectFor: reversePolarityCardInstance.

	"Turno 1: Nave 1 saca 3 -> va al casillero 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 saca 9 -> va al casillero 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 saca 2 -> cae en el casillero 6 (BlackHoleCell)"
	aGame moveSpaceship.

	result := Dictionary new.
	"Como la carta fue cancelada -> actúa el efecto normal del BlackHoleCell"
	"Nave 1 retrocede 4 casilleros -> termina en la celda 2"
	result at: 1 put: 2.
	"Nave 2 no es afectada -> se queda en la celda 10"
	result at: 2 put: 10.

	self assert: aGame spaceships cellsOfSpaceships equals: result


]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test42SpaceshipPlaysReversePolarityOnWormholeThenAllOtherSpaceshipsAreMovedToExit [
	| aGame result customGameDeck aCustomWormholeCreator |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). "Nave 1 va al 4, Nave 2 va al 10, Nave 1 va al 6"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	"Creamos un Wormhole con entrada en 6 y salida en 12"
	aCustomWormholeCreator := WormholeCreator withBeginning: 6 andEnd: 12.

	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aCustomWormholeCreator.

	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).

	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.

	"Jugamos la carta ReversePolarityCard sobre el casillero 6 (la entrada del Wormhole)"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.

	"Turno 1: Nave 1 va al 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 va al 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 cae en el casillero 6 (Wormhole)"
	aGame moveSpaceship.

	result := Dictionary new.
	"Como la polaridad está invertida, la Nave 1 que cayó en el Wormhole NO se mueve (se queda en 6)"
	result at: 1 put: 6.
	"La Nave 2 (que estaba en 10) es teletransportada al casillero de salida del Wormhole (casillero 12)"
	result at: 2 put: 12.

	self assert: aGame spaceships cellsOfSpaceships equals: result

]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test43SpaceshipPlaysReversePolarityOnCardDispenserThenAllOtherSpaceshipsGainCard [
	| aGame result customGameDeck |
	aLoadedDie := LoadedDie of: #( 3 9 2 2 ). "Turno 1: N1->4, Turno 2: N2->10, Turno 3: N1->6, Turno 4: N2->12"
	
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
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.
	"Nave 1 juega polaridad en cell 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	"Turno 1: Nave 1 va al 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 va al 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 va al 6 (CardDispenser). Al estar invertido, Nave 2 gana una ReversePolarityCard."
	aGame moveSpaceship.
	"Ahora es el turno de la Nave 2. Como ganó la carta, tiene 2 ReversePolarityCard en su mano."
	"Juega la primera en cell 8 y la segunda en cell 12."
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 8.
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 12.
	"Turno 4: Nave 2 saca 2 -> cae en cell 12 (BlackHoleCell)"
	aGame moveSpaceship.
	result := Dictionary new.
	"Si la celda 12 está invertida (porque Nave 2 jugó la carta que ganó):"
	"Nave 2 se queda en 12. Nave 1 (que estaba en 6) retrocede 4 -> celda 2."
	result at: 1 put: 2.
	result at: 2 put: 12.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test44SpaceshipPlaysReversePolarityOnHyperGravityThenAllOtherSpaceshipsGetHyperGravity [
	| aGame result customGameDeck |
	aLoadedDie := LoadedDie of: #( 3 9 2 2 ). "Turno 1: N1->4, Turno 2: N2->10, Turno 3: N1->6, Turno 4: N2->12"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	"Ponemos un HyperGravityCell con gravedad de valor 4 en el casillero 6"
	collectionOfCells at: 6 put: (HyperGravityCell withValueToMove: 4).
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.
	"Jugamos la carta de polaridad sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	"Turno 1: Nave 1 va al 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 va al 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 cae en el casillero 6. Al estar invertido, Nave 2 recibe la gravedad de 4."
	aGame moveSpaceship.
	"Turno 4: Nave 2 saca 2 -> como tiene gravedad de 4, y 2 < 4, no puede moverse. Se queda en 10."
	aGame moveSpaceship.
	result := Dictionary new.
	result at: 1 put: 6.
	result at: 2 put: 10.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]

{ #category : 'spaceshipCardHand' }
GameCardTest >> test45SpaceshipPlaysReversePolarityOnHyperJumpThenAllOtherSpaceshipsJump [
	| aGame result customGameDeck aConversor |
	aLoadedDie := LoadedDie of: #( 3 9 2 ). "Nave 1 va al 4, Nave 2 va al 10, Nave 1 va al 6"
	
	collectionOfCells := OrderedCollection new.
	30 timesRepeat: [ collectionOfCells add: Cell new ].
	
	"Creamos un conversor con ratio 1 y salto de 5 casilleros"
	aConversor := Conversor totalCells: 30 convertionValue: 30.
	collectionOfCells at: 6 put: (HyperJumpCell withConversor: aConversor andValues: (OrderedCollection with: (Parsecs ofValue: 5))).
	aBoardCreator := BoardCreator
		                 with: collectionOfCells
		                 ofLaps: 1
		                 withWormholeCreator: aWormholeCreator.
	customGameDeck := LoadedEffectManager manage: (OrderedCollection
		                  with: ReversePolarityCard
		                  with: ReversePolarityCard).
	aGame := Game
		         numberOfSpaceships: 2
		         with: aBoardCreator
		         playWith: aLoadedDie
		         andGameDeck: customGameDeck.
	"Jugamos la carta de polaridad sobre el casillero 6"
	aGame usePermanentCard: ReversePolarityCard toDoEffectFor: 6.
	"Turno 1: Nave 1 va al 4"
	aGame moveSpaceship.
	"Turno 2: Nave 2 va al 10"
	aGame moveSpaceship.
	"Turno 3: Nave 1 cae en el casillero 6 (HyperJumpCell)"
	aGame moveSpaceship.
	result := Dictionary new.
	"Como la polaridad está invertida, la Nave 1 no salta (se queda en 6)"
	result at: 1 put: 6.
	"La Nave 2 salta 5 casilleros -> de 10 pasa a 15"
	result at: 2 put: 15.
	self assert: aGame spaceships cellsOfSpaceships equals: result
]
