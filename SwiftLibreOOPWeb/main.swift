//
//  main.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 08.04.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//
import Foundation


var accessToken = "foo"


/*
 Please see MoreExamples.swift for a more advanced version of this where you can specify callbacks and tweak parameters
 LibreUtils.GetParsedOOPResult is blocking and is therefore not suited for usage in gui apps (unless you run it in a background thread)
 
 */
LibreUtils.accessToken = accessToken
/*
//patch[4] = UInt8(0x04)
var result  = LibreUtils.GetParsedOOPResult(patch: patch)

print("result? \(result)")*/
/*
var patches = GenerateFakePatches()
let dir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("2018_10_23_Sensor", isDirectory: true)

for reading in patches {
    
    
    let pointer = UnsafeBufferPointer(start:reading.sensordata, count:reading.sensordata.count)
    let data = Data(buffer:pointer)
    let filename = "2018_10_23_Sensor-reading-\(reading.nr)-rawglucose-\(reading.glucose)-rawtemp\(reading.temperature).txt"
    let url = dir.appendingPathComponent(filename, isDirectory: false)
    try! data.write(to:  url)
}
*/
//LibreUtils.accessToken = "abcd"
//extensiveAlgorithmTest()

//var minutes = SensorData(bytes: LibreOOPDefaults.TestPatchAlwaysReturning63)!.minutesSinceStart





var data = SensorData(bytes: LibreOOPDefaults.TestPatchAlwaysReturning63)!
data.minutesSinceStart = 7591
print("modified minutes is: \(data.minutesSinceStart)")

//This semaphore wait is neccessary when running as a mac os cli program. Consider removing this in a GUI app
//it kinda works like python's input() or raw_input() in a cli program, except it doesn't accept input, ofcourse..
let sema = DispatchSemaphore( value: 0 )
 sema.wait()
