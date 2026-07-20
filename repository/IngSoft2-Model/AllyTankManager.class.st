Class {
	#name : 'AllyTankManager',
	#superclass : 'Object',
	#instVars : [
		'dictionaryOfAllys'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
AllyTankManager class >> manage: aCollectionOfSpaceships [

	^ self new  initializeManage: aCollectionOfSpaceships
]

{ #category : 'set and get' }
AllyTankManager >> ally: aFirstSpaceship with: aSecondSpaceship [

	(dictionaryOfAllys includesKey: aFirstSpaceship) ifTrue: [
			Error signal:
				'Spaceship ' , aFirstSpaceship id asString , ' already has an ally.' ].
	(dictionaryOfAllys includesKey: aSecondSpaceship) ifTrue: [
			Error signal:
				'Spaceship ' , aSecondSpaceship id asString , ' already has an ally.' ].
	dictionaryOfAllys
		at: aFirstSpaceship put: aSecondSpaceship;
		at: aSecondSpaceship put: aFirstSpaceship
]

{ #category : 'initialization' }
AllyTankManager >> initializeManage: aCollectionOfSpaceships [
	dictionaryOfAllys := Dictionary new
]

{ #category : 'action' }
AllyTankManager >> spaceship: aSpaceship wantsToUse: anAmountOfFuel [

    | tankSpaceshipToMove tankAllySpaceship fuelToShare fuelNeeded |
    (dictionaryOfAllys includesKey: aSpaceship) ifFalse: [ ^ self ].
    
    tankSpaceshipToMove := aSpaceship fuelTank.
    tankAllySpaceship := (dictionaryOfAllys at: aSpaceship) fuelTank.

	fuelNeeded := anAmountOfFuel abs.

    fuelToShare := (tankSpaceshipToMove loadedWith - fuelNeeded) abs.

    tankSpaceshipToMove loadedWith - fuelNeeded < 0 ifFalse: [
        ^ self ].
    tankAllySpaceship useFuel: fuelToShare.
    tankSpaceshipToMove loadFuel: fuelToShare

]

{ #category : 'set and get' }
AllyTankManager >> spaceshipsWithEmptyFuelTank: aSpaceship [

	| emptySpaceships allySpaceship |
	emptySpaceships := OrderedCollection new.
	(dictionaryOfAllys includesKey: aSpaceship) ifFalse: [
			aSpaceship fuelTank isEmpty ifFalse: [ ^ emptySpaceships ].
			emptySpaceships add: aSpaceship.
			^ emptySpaceships ].
	allySpaceship := dictionaryOfAllys at: aSpaceship.
	(aSpaceship fuelTank isEmpty and: allySpaceship fuelTank isEmpty)
		ifFalse: [ ^ emptySpaceships ].
	emptySpaceships
		add: aSpaceship;
		add: allySpaceship.
	^ emptySpaceships
]

{ #category : 'set and get' }
AllyTankManager >> stopAlly: aSpaceship [

	| allySpaceship |
	allySpaceship := dictionaryOfAllys at: aSpaceship.
	dictionaryOfAllys
		removeKey: aSpaceship;
		removeKey: allySpaceship
]
