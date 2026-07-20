Class {
	#name : 'Spaceship',
	#superclass : 'Object',
	#instVars : [
		'id',
		'aFuelTank',
		'objectPosition',
		'turbines'
	],
	#classInstVars : [
		'counterId'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'class initialization' }
Spaceship class >> initialize [

	counterId := 0
]

{ #category : 'instance creation' }
Spaceship class >> launchWithFuel: anAmountOfFuel [

	counterId := counterId + 1.
	^ self new initializeLaunch: counterId withFuel: anAmountOfFuel
]

{ #category : 'comparing' }
Spaceship >> > aSpaceship [

	| currentLap targetLap currentCell targetCell |
	currentLap := objectPosition lap - 1.
	targetLap := aSpaceship position lap - 1.
	currentCell := objectPosition cell.
	targetCell := aSpaceship position cell.
	^ currentLap > targetLap or: [ currentLap = targetLap and: [ currentCell > targetCell ] ]
]

{ #category : 'set and get' }
Spaceship >> amountOfFuel [

	^ aFuelTank loadedWith
]

{ #category : 'action' }
Spaceship >> changeCapacity: anAmount [

	aFuelTank changeCapacity: anAmount 
]

{ #category : 'set and get' }
Spaceship >> fuelTank [

	^ aFuelTank
]

{ #category : 'action' }
Spaceship >> hasTurbines [
    ^ turbines > 0

]

{ #category : 'accessing' }
Spaceship >> id [

	^ id
]

{ #category : 'initialization' }
Spaceship >> initializeLaunch: aSpaceshipId withFuel: anAmountOfFuel [

	objectPosition := Position startGame.
	aFuelTank := FuelTank fullWith: anAmountOfFuel.
	id := aSpaceshipId.
	turbines := 3.
]

{ #category : 'setter' }
Spaceship >> loadFuel [

	aFuelTank reloadToCapacity
]

{ #category : 'action' }
Spaceship >> loseTurbine [
    turbines := turbines - 1



]

{ #category : 'action' }
Spaceship >> move: aDistance [

	| distanceToMove |
	distanceToMove := aDistance.
	aDistance > aFuelTank loadedWith ifTrue: [ distanceToMove := aFuelTank loadedWith ].
	objectPosition updateCell: distanceToMove.
	aFuelTank useFuel: distanceToMove abs
]

{ #category : 'set and get' }
Spaceship >> position [

	^ objectPosition
]

{ #category : 'action' }
Spaceship >> resetToCell: aCellNumber andLap: aLapNumber [ 
    | currentCell currentLap |
    
    currentCell := objectPosition cell.
    currentLap := objectPosition lap.
    objectPosition updateCell: aCellNumber - currentCell.
    objectPosition updateLap: aLapNumber - currentLap.


]

{ #category : 'initialization' }
Spaceship >> resetToOne [

	self resetToCell: 1 andLap: objectPosition lap.
]

{ #category : 'accessing' }
Spaceship >> turbines [
    ^ turbines

]
