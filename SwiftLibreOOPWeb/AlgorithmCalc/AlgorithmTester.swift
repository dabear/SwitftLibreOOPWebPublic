//
//  AlgorithmTester.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 18.10.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//

import Foundation

fileprivate func writeGlucoseResult(folder: String, filename:String, result: String){
    let fm = FileManager.default
    let dir: URL
    do{
        dir = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
    }catch{
        print("could not write glucoseresult: dir not created")
        return
    }
    
    var isDir: ObjCBool = true
    let subfolder = dir.appendingPathComponent(folder, isDirectory: true)
    if !fm.fileExists(atPath: subfolder.path, isDirectory: &isDir) {
        do{
            try fm.createDirectory(at: subfolder, withIntermediateDirectories: true, attributes: nil)
        } catch{
            print("subfolder could not be created, aborting writing glucose result")
            return
        }
    }
    
    let fileUrl = subfolder.appendingPathComponent(filename)
    print("Saving glucose result to \(fileUrl.path)")
    let finalResult = "\(result)\n"
    
    do {
        try finalResult.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Could not write result: \(error.localizedDescription)")
    }
}

//
// Secondary entrypoint. Call this function if you have already saved parameters to file and want to test with a few values
//
func TestAlgorithm(){
    
    let runner = DerivedAlgorithmRunner.CreateInstanceFromParamsFile()
    if let runner = runner {
        print("Created runner successfully")
        
        //control
        let res1 = runner.GetGlucoseValue(from_raw_glucose: 1500, raw_temp: 7124) // 146.04347826086956
        print("res1: \(res1)")
        
        
        //uwe:58, me: 57, derivedalgo: 57
        let resb1 = runner.GetGlucoseValue(from_raw_glucose: 700, raw_temp: 7124)
        print("res1b: \(resb1)")
        
        //uwe: 318, me: 313, derivedalgo: 313
        let resb2 = runner.GetGlucoseValue(from_raw_glucose: 3000, raw_temp: 7124)
        print("resb2: \(resb2)")
        
        
    } else {
        print("Could not create runner")
    }
    
}

struct SensorReading{
    public var glucose: Int
    public var temperature: Int
    public var nr: Int //for debugging only
    public var byte2=0
    public var byte3=0
    public var sensordata : [UInt8]
    
}


fileprivate func extensiveAlgorithmTestDelegate( patch: SensorReading ) {
    
    
    print("processing patch \(patch.nr)")
    
    let client = LibreOOPClient(accessToken: LibreUtils.accessToken)
    
    
    
    client.uploadReading(reading: patch.sensordata ) { (response, success, errormessage)  in
        if(!success) {
            NSLog("remote: upload reading failed! \(errormessage)")
            
            return
        }
        
        if let response = response, let uuid = response.result?.uuid {
            print("uuid received: " + uuid)
            client.getStatusIntervalled(uuid: uuid, { (success, errormessage, oopCurrentValue, newState) in
                
                NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(String(describing: oopCurrentValue))), newState: \(newState)")
                //NSLog("GetStatusIntervalled  newState: \(newState)")
                
                /*
                var res1 = "Uknown"
                var diff = "Uknown"
                
                let res2 = runner.GetGlucoseValue(from_raw_glucose: patch.glucose, raw_temp: patch.temperature)
                
                if let bg = oopCurrentValue?.currentBg {
                    res1 = "\(bg)"
                    diff = "\(bg - res2)"
                }*/
                
                let bg = oopCurrentValue?.currentBg ?? -1
                
                let csvline = "\(patch.glucose)|\(patch.temperature)|\(bg)|\(uuid)"
                writeGlucoseResult(folder: "GlucoseComparison", filename: "nr\(patch.nr).txt", result: csvline)
                
                
            })
        } else {
            print("getparsedresult failed")
            
        }
        
        
    }
    
}

fileprivate func testMinuteCounterAffectingResultDelegate(sensorData: SensorData) {
    let client = LibreOOPClient(accessToken: LibreUtils.accessToken)
    
    print("processing patch with minutedata: \(sensorData.minutesSinceStart)")
    client.uploadReading(reading: sensorData.bytes ) { (response, success, errormessage)  in
        guard success else {
            NSLog("remote: upload reading failed! \(errormessage)")
            return
        }
        
        if let response = response, let uuid = response.result?.uuid {
            print("uuid received: " + uuid)
            client.getStatusIntervalled(uuid: uuid, { (success, errormessage, oopCurrentValue, newState) in
                
                NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(String(describing: oopCurrentValue))), newState: \(newState)")

                let currentbg = oopCurrentValue?.currentBg ?? -1
                
                guard let currentValue = oopCurrentValue else {
                    writeGlucoseResult(folder: "GlucoseComparison", filename: "minute-\(sensorData.minutesSinceStart).txt", result: "\(sensorData.minutesSinceStart)|\(uuid)|error!")
                    return
                }
                
                var historicBgs = currentValue.historyValues.map({"\($0.bg)"}).joined(separator: "|")
                
                
                //writeGlucoseResult(folder: "GlucoseComparison", filename: "000_headers.txt", result: "currentTime|oopwebuid|currentBg|historicbg")
                
                
                let csvline = "\(sensorData.minutesSinceStart)|\(uuid)|\(currentValue.currentBg)|\(historicBgs)"
                writeGlucoseResult(folder: "GlucoseComparison", filename: "minute-\(sensorData.minutesSinceStart).txt", result: csvline)
                
                
            })
        } else {
            print("getparsedresult failed")
            
        }
    }
        
}


func testMinuteCounterAffectingResult() {
    var patches : [SensorData] = Array(GenerateMinutePatches().prefix(10))
    
    
    
    for patch in patches {
        print("patch minutes: \(patch.minutesSinceStart), crcs: \(patch.hasValidCRCs)")
    }
    print("number of sensors to test: \(patches.count)")
    
    let step = 15
    let start = 0
    
    let delay = 40 //seconds
    var groupdelay = 0
    
    //headers
    writeGlucoseResult(folder: "GlucoseComparison", filename: "000_headers.txt", result: "currentTime|oopwebuid|currentBg|historicbg")
    
    for patchrangestart in stride(from: start, to:patches.count, by: step){
        let patchrangeend = min(patchrangestart+step,  patches.count)
  
        let relevantPatches = patches[patchrangestart..<patchrangeend]
        
       
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(groupdelay)) { [relevantPatches] in
            for  patch in relevantPatches{
                testMinuteCounterAffectingResultDelegate(sensorData: patch)
                
            }
            
        }
        
        groupdelay += delay
        
    }
    let now = Date()
    let expectedRuntime = (groupdelay+delay)
    let expectedEndDate = now + TimeInterval(exactly: expectedRuntime)!
    print("time is now \(now), script execution will take about \(expectedRuntime) seconds and be complete about \(expectedEndDate )")
    
}

func extensiveAlgorithmTest(){
    //let runner = DerivedAlgorithmRunner.CreateInstanceFromParamsFile()
    //if let runner = runner {
        print("Created runner successfully")
        
        var patches = GenerateFakePatches()
        
        //we don't want to send more than 15 calls to the algorithm per 30 seconds
        //so group them by 15 and delay them
        
        let step = 15
        let start = 0
        
        let delay = 40 //seconds
        var groupdelay = 0
        
        //headers
        writeGlucoseResult(folder: "GlucoseComparison", filename: "000_headers.txt", result: "rawglucose|rawtemperature|oopalgoresult-pre2019|oopwebuid")
        
        for patchrangestart in stride(from: start, to:patches.count, by: step){
            let patchrangeend = min(patchrangestart+step,  patches.count)
            //print("start: \(patchrangestart)")
            let relevantPatches = patches[patchrangestart..<patchrangeend]
            //print("relevant patches: \(relevantPatches)\n")
            
            //print("will send patches \(relevantPatches.first!.nr)-\(relevantPatches.last!.nr) with delay of \(groupdelay) seconds")
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(groupdelay)) { [relevantPatches] in
                
                //print("async: will send patches \(relevantPatches.first!.nr)-\(relevantPatches.last!.nr) with delay of \(groupdelay) seconds")
                
                for  patch in relevantPatches{
                    extensiveAlgorithmTestDelegate(patch: patch)
                    
                }
                
                
                
            }
            
            groupdelay += delay
            
        }
        let now = Date()
        let expectedRuntime = (groupdelay+delay)
        let expectedEndDate = now + TimeInterval(exactly: expectedRuntime)!
        print("time is now \(now), script execution will take about \(expectedRuntime) seconds and be complete about \(expectedEndDate )")
        
   /* } else {
        print("Could not create runner")
    }*/
    
}

func extensiveCalibrationTestDelegate(patch: SensorReading ) -> Bool{
    
    
    print("processing patch \(patch.nr)")
    
    let client = LibreOOPClient(accessToken: LibreUtils.accessToken)
    
    print("patch for calibration: \(patch.sensordata)")
    
    
    client.uploadCalibration(reading: patch.sensordata) { (response, success, errormessage) in
        
    
        if(!success) {
            NSLog("remote uploadCalibration: upload reading failed! \(errormessage)")
            
            return
        }
        
        if let response = response{
            let uuid = response.uuid
            
            print("calibration uuid received: " + uuid)
            
            client.getCalibrationStatusIntervalled(uuid: uuid,  { (success, errormessage, calibrationparams) in
                NSLog("getCalibrationStatusIntervalled returned with success?: \(success), error: \(errormessage)")
                var csvline = ""
                
                if success, let params = calibrationparams {
                    csvline = "\(uuid)|\(patch.byte2)|\(patch.byte3)|\(params.offset_offset)|\(params.offset_slope)|\(params.slope_slope)|\(params.slope_offset)"
                    
                } else {
                    csvline = "\(uuid)|\(patch.byte2)|\(patch.byte3)|NA|NA|NA|NA"
                }
                
                writeGlucoseResult(folder: "GlucoseComparison", filename: "nr\(patch.nr).txt", result: csvline)
                
                
            })
            
            
            
        } else {
            print("get reponse failed")
            
        }
        
        
    }
    return true
}


func extensiveCalibrationTest(){
    
    
    var patches = CreateDabearPatceshModifiedHeader()
    
    
    print("patches count: \(patches.count)")
   
    
    
    //headers
    writeGlucoseResult(folder: "GlucoseComparison", filename: "000_headers.txt", result: "uuid|byte2|byte3|offset_offset|offset_slope|slope_slope|slope_offset")
    
    
    //we don't want to send more than about 7 calls to the algorithm per 30 seconds
    //so group them by 15 and delay them
    
    let step = 7
    let start = 0
    
    let delay = 35 //seconds
    var groupdelay = 0
    
    /*//headers
    print("test patches:")
    print("\(SensorData(bytes: patches[10].sensordata)?.oopWebInterfaceInput())")
    print("\(SensorData(bytes: patches[15].sensordata)?.oopWebInterfaceInput())")
    
    let temp = [
        patches[10],
        patches[15]
                
    ]
    patches = temp*/
    
    for patchrangestart in stride(from: start, to:patches.count, by: step){
        let patchrangeend = min(patchrangestart+step,  patches.count)
        //print("start: \(patchrangestart)")
        let relevantPatches = patches[patchrangestart..<patchrangeend]
        //print("relevant patches: \(relevantPatches)\n")
        
        print("will send patches \(relevantPatches.first!.nr)-\(relevantPatches.last!.nr) with delay of \(groupdelay) seconds")
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(groupdelay)) { [relevantPatches] in
            
            //print("async: will send patches \(relevantPatches.first!.nr)-\(relevantPatches.last!.nr) with delay of \(groupdelay) seconds")
            
            for patch in relevantPatches{
                _ = extensiveCalibrationTestDelegate(patch: patch)
                
            }
            
            
            
        }
        
        groupdelay += delay
        
    }
    let now = Date()
    let expectedRuntime = (groupdelay+delay)
    let expectedEndDate = now + TimeInterval(exactly: expectedRuntime)!
    print("time is now \(now), script execution will take about \(expectedRuntime) seconds and be complete about \(expectedEndDate )")
    
    
    
    
}
