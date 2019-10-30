//
//  CalculateBounds.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 27/10/2019.
//  Copyright © 2019 Bjørn Inge Berg. All rights reserved.
//

import Foundation


enum direction{
    case positive
    case negative
}




struct AlgorithmThresholds {
    var glucoseLowerThreshold: UInt16
    var glucoseUpperThreshold: UInt16
    var temperatureLowerThreshold: UInt16
    var temperatureUpperThreshold: UInt16

    var forSensorIdentifiedBy: UInt16
}

class CalculateThresholds{
    //these are safe starting points
    // all values are in mg/dl
    public static let GLUCOSE_DEFAULT_LOWER_BOUND: UInt16 = 1000;
    public static let GLUCOSE_DEFAULT_UPPER_BOUND: UInt16 = 3000;
    //public static let GLUCOSE_DEFAULT_UPPER_BOUND: UInt16 = 5000;
    public static let RAWTEMP_DEFAULT_LOWER_BOUND: UInt16 = 6000;
    public static let RAWTEMP_DEFAULT_UPPER_BOUND: UInt16 = 9000;

    public static let MAX_CALCULATED_GLUCOSE: Double = 501
    public static let MIN_CALCULATED_GLUCOSE: Double = 39

    public static var glucose_center : UInt16{
        return (GLUCOSE_DEFAULT_LOWER_BOUND + GLUCOSE_DEFAULT_UPPER_BOUND) / 2
    }

    public static var temp_center : UInt16{
        return (RAWTEMP_DEFAULT_LOWER_BOUND + RAWTEMP_DEFAULT_UPPER_BOUND) / 2
    }

    let sensorData: SensorData
    init(for sensor:SensorData) {
        self.sensorData = sensor
    }

    convenience init?(for sensor: [UInt8]) {
        let data = SensorData(bytes: sensor)
        if let data = data {
            self.init(for: data)

        } else {
            return nil
        }

    }

    func calculatedGlucoseIsValid(currentBg: Double?) -> Bool {
        guard let currentBg = currentBg else {
            return false
        }
        //ugly hack
        // but should make for more sane (but not optimal) defaults
        return currentBg > (CalculateThresholds.MIN_CALCULATED_GLUCOSE + CalculateThresholds.MIN_CALCULATED_GLUCOSE)  && currentBg < (CalculateThresholds.MAX_CALCULATED_GLUCOSE)
    }

    func getAlgorithmThresholds(I_UNDERSTAND_THIS_WILL_TAKE_A_LONG_TIME:Bool=false) -> AlgorithmThresholds{
        if !I_UNDERSTAND_THIS_WILL_TAKE_A_LONG_TIME {
            fatalError("You should ack that you understand the risk of running this function")
        }

        return AlgorithmThresholds(
            glucoseLowerThreshold: self.getGlucoseLowerBound(),
            glucoseUpperThreshold: self.getGlucoseUpperBound(),
            temperatureLowerThreshold: self.getTemperatureLowerBound(),
            temperatureUpperThreshold: self.getTemperatureUpperBound(),
            forSensorIdentifiedBy: self.sensorData.reverseFooterCRC!
        )

    }


    private func getTemperatureBound(sign: @escaping (UInt16,UInt16)->UInt16, temperatureToTest: UInt16) -> UInt16 {


        guard temperatureToTest >= 101 else {
            return temperatureToTest
        }

        var test = temperatureToTest

        let modifiedPatch = LibreUtils.CreateFakePatch(fromPatch: self.sensorData.bytes, raw_glucose: CalculateThresholds.glucose_center, raw_temp: test)



        var lastSuccessfulThreshold = test


        // we assume the initial provided value is always correct (even if it isn't)
        // but we don't continue if it isn't
        guard let response=LibreUtils.GetParsedOOPResult( patch: modifiedPatch), calculatedGlucoseIsValid(currentBg: response.currentBg) else {
            return lastSuccessfulThreshold
        }



        print("rawtemperature of \(test) was successfully tested, continuing")

        //calculate glucose to nearest 1000
        var tries = 0
        while true {
            tries += 1
            if tries > 10 {
                print("tried more than 10 times, returning")
                break
            }
            test = sign(test,1000)

            if test <= 101 {
                print("test value was less than 100, returning")
                break
            }

            let modifiedPatch2 = LibreUtils.CreateFakePatch(fromPatch: self.sensorData.bytes, raw_glucose: CalculateThresholds.GLUCOSE_DEFAULT_LOWER_BOUND , raw_temp: test)
            let response2 = LibreUtils.GetParsedOOPResult( patch: modifiedPatch2)
            if calculatedGlucoseIsValid(currentBg: response2?.currentBg) {
                lastSuccessfulThreshold = test
                print("test value of \(test) provided a currentbg of  \(response2?.currentBg), continuing")
            } else {
                print("response2 is: \(response2)")
                print("test value of \(test) could not provide valid result, so stopping loop")
                break
            }
        }

        test = lastSuccessfulThreshold

        //calculate glucose to nearest 100
        tries = 0
        while true {
            tries += 1
            if tries > 10 {
                print("tried more than 10 times, returning")
                break
            }
            test = sign(test,100)

            if test <= 101 {
                print("test value was less than 100, returning")
                break
            }

            let modifiedPatch2 = LibreUtils.CreateFakePatch(fromPatch: self.sensorData.bytes, raw_glucose: CalculateThresholds.glucose_center, raw_temp: test)
            let response2 = LibreUtils.GetParsedOOPResult( patch: modifiedPatch2)
            if calculatedGlucoseIsValid(currentBg: response2?.currentBg) {
                lastSuccessfulThreshold = test
                print("test value of \(test) provided a currentbg of  \(response2?.currentBg), continuing")
            } else {
                print("test value of \(test) could not provide valid result, so stopping loop")
                break
            }
        }

        print("testvalue of \(lastSuccessfulThreshold) found")
        return lastSuccessfulThreshold

    }

    func getTemperatureLowerBound(temperatureToTest: UInt16 = RAWTEMP_DEFAULT_LOWER_BOUND) -> UInt16 {
        return getTemperatureBound(sign: -, temperatureToTest: temperatureToTest)
    }
    func getTemperatureUpperBound(temperatureToTest: UInt16 = RAWTEMP_DEFAULT_UPPER_BOUND) -> UInt16 {
        return getTemperatureBound(sign: +, temperatureToTest: temperatureToTest)
    }

    func getGlucoseUpperBound(glucoseToTest: UInt16 = GLUCOSE_DEFAULT_UPPER_BOUND) -> UInt16 {
        return getGlucoseBound(sign: +, glucoseToTest: glucoseToTest)
    }

    func getGlucoseLowerBound(glucoseToTest: UInt16 = GLUCOSE_DEFAULT_LOWER_BOUND) -> UInt16 {
        return getGlucoseBound(sign: -, glucoseToTest: glucoseToTest)
    }

    private func getGlucoseBound(sign: (UInt16,UInt16)->UInt16, glucoseToTest: UInt16) -> UInt16 {

        guard glucoseToTest >= 101 else {
            return glucoseToTest
        }

        var test = glucoseToTest

        let modifiedPatch = LibreUtils.CreateFakePatch(fromPatch: self.sensorData.bytes, raw_glucose: test, raw_temp: CalculateThresholds.temp_center)

        var lastSuccessfulThreshold = test


        // we assume the initial provided value is always correct (even if it isn't)
        // but we don't continue if it isn't
        guard let response=LibreUtils.GetParsedOOPResult( patch: modifiedPatch), calculatedGlucoseIsValid(currentBg: response.currentBg) else {
            return lastSuccessfulThreshold
        }


        print("rawglucose of \(glucoseToTest) was successfully tested, trying higher amount")

        //calculate glucose to nearest 1000
        var tries = 0
        while true {
            tries += 1
            if tries > 10 {
                print("tried more than 10 times, returning")
                break
            }
            test = sign(test,1000)

            if test <= 101 {
                print("test value was less than 100, returning")
                break
            }

            let modifiedPatch2 = LibreUtils.CreateFakePatch(fromPatch: self.sensorData.bytes, raw_glucose: test, raw_temp: CalculateThresholds.temp_center)
            let response2 = LibreUtils.GetParsedOOPResult( patch: modifiedPatch2)
            if calculatedGlucoseIsValid(currentBg: response2?.currentBg) {
                lastSuccessfulThreshold = test
                print("test value of \(test) provided a currentbg of  \(response2?.currentBg), continuing")
            } else {
                print("test value of \(test) could not provide valid result, so stopping loop")
                break
            }
        }

        test = lastSuccessfulThreshold

        //calculate glucose to nearest 100
        tries = 0
        while true {
            tries += 1
            if tries > 10 {
                print("tried more than 10 times, returning")
                break
            }
            test = sign(test,100)

            if test <= 101 {
                print("test value was less than 100, returning")
                break
            }

            let modifiedPatch2 = LibreUtils.CreateFakePatch(fromPatch: self.sensorData.bytes, raw_glucose: test, raw_temp: CalculateThresholds.temp_center)
            let response2 = LibreUtils.GetParsedOOPResult( patch: modifiedPatch2)
            if calculatedGlucoseIsValid(currentBg: response2?.currentBg) {
                lastSuccessfulThreshold = test
                print("test value of \(test) provided a currentbg of  \(response2?.currentBg), continuing")
            } else {
                print("test value of \(test) could not provide valid result, so stopping loop")
                break
            }
        }

        print("testvalue of \(lastSuccessfulThreshold) found")

        return lastSuccessfulThreshold

    }




}


