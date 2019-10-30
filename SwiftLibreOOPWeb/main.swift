//
//  main.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 08.04.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//
import Foundation

let accessToken = ""
LibreUtils.accessToken = accessToken


var temp = LibreOOPDefaults.TestPatchAlwaysReturning63

var calc = CalculateThresholds(for: temp)!

/*
var result = calc.getAlgorithmThresholds(I_UNDERSTAND_THIS_WILL_TAKE_A_LONG_TIME: true)

print("result for sensor:")

 //var result = AlgorithmThresholds(glucoseLowerThreshold: 500, glucoseUpperThreshold: 5400, temperatureLowerThreshold: 5000, temperatureUpperThreshold: 12400, forSensorIdentifiedBy: 49778)

debugPrint(result)

*/

CalculateDerivedAlgorithm()
extensiveAlgorithmTest()

//This semaphore wait is neccessary when running as a mac os cli program. Consider removing this in a GUI app
//it kinda works like python's input() or raw_input() in a cli program, except it doesn't accept input, ofcourse..
let sema = DispatchSemaphore( value: 0 )
sema.wait()
