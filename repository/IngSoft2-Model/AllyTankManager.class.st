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
AllyTankManager class >> manage: arg1 [

	^ self new initializeManage: arg1
]

{ #category : 'set and get' }
AllyTankManager >> ally: arg1 with: arg2 [

	(dictionaryOfAllys includesKey: arg1) ifTrue: [
			Error signal:
				'Spaceship ' , arg1 id asString , ' already has an ally.' ].
	(dictionaryOfAllys includesKey: arg2) ifTrue: [
			Error signal:
				'Spaceship ' , arg2 id asString , ' already has an ally.' ].
	dictionaryOfAllys
		at: arg1 put: arg2;
		at: arg2 put: arg1
]

{ #category : 'initialization' }
AllyTankManager >> initializeManage: aCollectionOfSpaceships [
	dictionaryOfAllys := Dictionary new
]

{ #category : 'action' }
AllyTankManager >> spaceship: aSpaceship wantsToUse: anAmountOfFuel [

    | tankSpaceshipToMove tankAllySpaceship fuelToShare |
    (dictionaryOfAllys includesKey: aSpaceship) ifFalse: [ ^ self ].
    
    "CAMBIO: Le pedimos el tanque directamente al objeto nave"
    tankSpaceshipToMove := aSpaceship objectFuelTank.
    tankAllySpaceship := (dictionaryOfAllys at: aSpaceship) objectFuelTank.

    fuelToShare := (tankSpaceshipToMove loadedWith - anAmountOfFuel) abs.

    tankSpaceshipToMove loadedWith - anAmountOfFuel < 0 ifFalse: [
        ^ self ].
    tankAllySpaceship useFuel: fuelToShare.
    tankSpaceshipToMove loadFuel: fuelToShare

]

{ #category : 'set and get' }
AllyTankManager >> spaceshipsWithEmptyFuelTank: arg1 [

	| tmp1 tmp2 |
	tmp1 := OrderedCollection new.
	(dictionaryOfAllys includesKey: arg1) ifFalse: [
			arg1 objectFuelTank isEmpty ifFalse: [ ^ tmp1 ].
			tmp1 add: arg1.
			^ tmp1 ].
	tmp2 := dictionaryOfAllys at: arg1.
	(arg1 objectFuelTank isEmpty and: tmp2 objectFuelTank isEmpty)
		ifFalse: [ ^ tmp1 ].
	tmp1
		add: arg1;
		add: tmp2.
	^ tmp1
]

{ #category : 'set and get' }
AllyTankManager >> stopAlly: arg1 [

	| tmp1 |
	tmp1 := dictionaryOfAllys at: arg1.
	dictionaryOfAllys
		removeKey: arg1;
		removeKey: tmp1
]
