Class {
	#name : 'TurnManagerTest',
	#superclass : 'TestCase',
	#category : 'IngSoft2-Tests',
	#package : 'IngSoft2-Tests'
}

{ #category : 'tests' }
TurnManagerTest >> test01OneSpaceshipsThenTurnOneReturnsSpaceshipOne [

	| aTurnManager collectionOfSpaceships currentSpaceshipId |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 1
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 1
]

{ #category : 'tests' }
TurnManagerTest >> test02TwoSpaceshipsThenTurnTwoReturnsSpaceshipTwo [

	| aTurnManager collectionOfSpaceships currentSpaceshipId |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 2
]

{ #category : 'tests' }
TurnManagerTest >> test03WhenRoundIsOverNextTurnIsTheFirstSpaceship [

	| aTurnManager collectionOfSpaceships currentSpaceshipId |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.

	self assert: currentSpaceshipId equals: 1
]

{ #category : 'tests' }
TurnManagerTest >> test04WhenSpaceshipOneLosesTurnsTheNextTurnIsSpaceshipTwo [

	| aTurnManager collectionOfSpaceships currentSpaceshipId spaceshipOne |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	aTurnManager lostTurns: 2 by: spaceshipOne.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 2
]

{ #category : 'tests' }
TurnManagerTest >> test05WhenSpaceshipOneLosesTwoTurnsThenSpaceshipTwoPlaysThem [

	| aTurnManager collectionOfSpaceships currentSpaceshipId spaceshipOne|
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	aTurnManager lostTurns: 2 by: spaceshipOne.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 1
]

{ #category : 'tests' }
TurnManagerTest >> test06WhenEverySpaceshipsLosesTheirTurnThenReturnAnAllShipsDisabledHandler [

	| aTurnManager collectionOfSpaceships currentSpaceshipId spaceshipOne|
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 1
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	aTurnManager lostTurns: 2 by: spaceshipOne.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 1
]

{ #category : 'tests' }
TurnManagerTest >> test07WhenSpaceshipLostTwoTurnsIsCalledTwiceAndTwoTurnsPassThenSpaceshipRecoversTurn [

	| aTurnManager collectionOfSpaceships currentSpaceshipId spaceshipOne |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 1
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	aTurnManager lostTurns: 2 by: spaceshipOne.
	aTurnManager lostTurns: 2 by: spaceshipOne.
	aTurnManager lostTurns: 2 by: spaceshipOne.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 1
]

{ #category : 'tests' }
TurnManagerTest >> test08OneSpaceshipLostOneTurnAndThenRecoversIt [

	| aTurnManager collectionOfSpaceships currentSpaceshipId spaceshipOne|
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	aTurnManager := TurnManager manage: collectionOfSpaceships.
	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	aTurnManager lostTurns: 1 by: spaceshipOne.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	aTurnManager nextTurn.
	currentSpaceshipId := aTurnManager spaceshipPlaying id.

	Spaceship initialize.
	self assert: currentSpaceshipId equals: 1
]

{ #category : 'tests' }
TurnManagerTest >> test09NextTurnSkipsSpaceshipWithoutTurbines [

	| aTurnManager collectionOfSpaceships  spaceshipOne spaceshipTwo |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	spaceshipTwo := collectionOfSpaceships detectSpaceshipWithId: 2.
	aTurnManager := TurnManager manage: collectionOfSpaceships.
	
	3 timesRepeat: [ spaceshipTwo loseTurbine ].
	
	aTurnManager nextTurn.
	Spaceship initialize.
	self assert: aTurnManager spaceshipPlaying equals: spaceshipOne.
]

{ #category : 'tests' }
TurnManagerTest >> test10NextTurnSignalsErrorWhenAllSpaceshipsHaveZeroTurbines [

	| aTurnManager collectionOfSpaceships  spaceshipOne spaceshipTwo |
	collectionOfSpaceships := CollectionOfSpaceships
		                          numberOfSpaceships: 2
		                          withAmountOfFuel: 5.

	spaceshipOne := collectionOfSpaceships detectSpaceshipWithId: 1.
	spaceshipTwo := collectionOfSpaceships detectSpaceshipWithId: 2.
	aTurnManager := TurnManager manage: collectionOfSpaceships.
	
	3 timesRepeat: [ spaceshipOne loseTurbine. spaceshipTwo loseTurbine ].
	

	self
		should: [ aTurnManager nextTurn ]
		raise: Error.
	
]
