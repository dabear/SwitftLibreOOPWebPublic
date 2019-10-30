//
//  ResponseTests.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 19/10/2019.
//  Copyright © 2019 Bjørn Inge Berg. All rights reserved.
//

import Foundation


private func getSuccessFulGetStatusResponse() -> String {
   return "some POST value from android: currentBg: 63 FullAlgoResults: {\"currenTrend\":10,\"currentBg\":63.0,\"currentTime\":4568,\"historicBg\":[{\"bg\":111.0,\"quality\":0,\"time\":4095},{\"bg\":115.0,\"quality\":0,\"time\":4110},{\"bg\":113.0,\"quality\":0,\"time\":4125},{\"bg\":129.0,\"quality\":0,\"time\":4140},{\"bg\":172.0,\"quality\":0,\"time\":4155},{\"bg\":169.0,\"quality\":0,\"time\":4170},{\"bg\":137.0,\"quality\":0,\"time\":4185},{\"bg\":132.0,\"quality\":0,\"time\":4200},{\"bg\":153.0,\"quality\":0,\"time\":4215},{\"bg\":212.0,\"quality\":0,\"time\":4230},{\"bg\":260.0,\"quality\":0,\"time\":4245},{\"bg\":286.0,\"quality\":0,\"time\":4260},{\"bg\":295.0,\"quality\":0,\"time\":4275},{\"bg\":276.0,\"quality\":0,\"time\":4290},{\"bg\":232.0,\"quality\":0,\"time\":4305},{\"bg\":179.0,\"quality\":0,\"time\":4320},{\"bg\":153.0,\"quality\":0,\"time\":4335},{\"bg\":156.0,\"quality\":0,\"time\":4350},{\"bg\":167.0,\"quality\":0,\"time\":4365},{\"bg\":181.0,\"quality\":0,\"time\":4380},{\"bg\":179.0,\"quality\":0,\"time\":4395},{\"bg\":162.0,\"quality\":0,\"time\":4410},{\"bg\":150.0,\"quality\":0,\"time\":4425},{\"bg\":133.0,\"quality\":0,\"time\":4440},{\"bg\":115.0,\"quality\":0,\"time\":4455},{\"bg\":107.0,\"quality\":0,\"time\":4470},{\"bg\":100.0,\"quality\":0,\"time\":4485},{\"bg\":91.0,\"quality\":0,\"time\":4500},{\"bg\":81.0,\"quality\":0,\"time\":4515},{\"bg\":69.0,\"quality\":0,\"time\":4530},{\"bg\":62.0,\"quality\":0,\"time\":4545},{\"bg\":0.0,\"quality\":1,\"time\":4560}],\"newState\":[-40,17,0,0,0,0,0,0,-101,58,101,67,101,-107,79,64,-40,17,0,0,0,0,0,0,60,100,6,25,101,-82,-39,63],\"serialNumber\":\"\",\"timestamp\":0}"
}

func TestGetStatusResponse(){
    let response = LibreOOPClient.getOOPCurrentValue(from: getSuccessFulGetStatusResponse())!

    print("got response: \(response)")
    print("got currenttrend: \(response.currentTrend)")

    
}
