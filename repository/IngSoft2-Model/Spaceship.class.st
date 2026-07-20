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
Spaceship class >> launchWithFuel: arg1 [

	counterId := counterId + 1.
	^ self new initializeLaunch: counterId withFuel: arg1
]

{ #category : 'comparing' }
Spaceship >> > arg1 [

	| tmp1 tmp2 tmp3 tmp4 |
	tmp1 := objectPosition lap - 1.
	tmp2 := arg1 position lap - 1.
	tmp3 := objectPosition cell.
	tmp4 := arg1 position cell.
	^ tmp1 > tmp2 or: [ tmp1 = tmp2 and: [ tmp3 > tmp4 ] ]
]

{ #category : 'set and get' }
Spaceship >> amountOfFuel [

	^ aFuelTank loadedWith
]

{ #category : 'action' }
Spaceship >> changeCapacity: arg1 [

	aFuelTank changeCapacity: arg1
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
Spaceship >> initializeLaunch: arg1 withFuel: arg2 [

	objectPosition := Position startGame.
	aFuelTank := FuelTank fullWith: arg2.
	id := arg1.
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
Spaceship >> move: arg1 [

	| tmp1 |
	tmp1 := arg1.
	arg1 > aFuelTank loadedWith ifTrue: [ tmp1 := aFuelTank loadedWith ].
	objectPosition updateCell: tmp1.
	aFuelTank useFuel: tmp1 abs
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
