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

testMinuteCounterAffectingResult()

/*
let b64 = "Os8QFgMAAAAAAAAAAAAAAAAAAAAAAAAApdIIEK0CyNRbAKoCyLQbgKkCyJxbAKkCyIwbgLACyDBcgLACiOacgLgCyDydgLgCyGCdgKECyNyegKsCyBSegKkCyMCdgKsCyHidgKoCyECdgKgCyAidgKgCyCxcgK0CyPhbACkGyPSbgMkFyIzegMMFyCiegCwGyNCegHsGiKaegPkFyLCegJkFyPCegC4FyACfgIEEyEiggF0EyDidgBIEyBCegM8DyEyegG8DyLiegBkDyECfgMUCyPSegKoCyPhbAKIEyDiaANEEyCibgOQEyOAagI8EyCCbgCIGyFBbgLwGyFScgH8FyCRcgMkFyDhcgDgFyPQagDcHyIRbgPsIyEycgPsJyHybgHcKyORagN8JyIifgG0IyCyfgMMGyLCdgOUWAABywgAIggUJURQHloBaAO2mDm4ayATdWG0="
//let arr = LibreOOPDefaults.TestPatchAlwaysReturning63
let arr : [UInt8] =  b64.base64Decoded()!
*/



//This semaphore wait is neccessary when running as a mac os cli program. Consider removing this in a GUI app
//it kinda works like python's input() or raw_input() in a cli program, except it doesn't accept input, ofcourse..
let sema = DispatchSemaphore( value: 0 )
 sema.wait()
