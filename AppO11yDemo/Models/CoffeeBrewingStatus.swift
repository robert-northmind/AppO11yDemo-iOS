//
//  CoffeeBrewingStatus.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 30.04.24.
//

import Foundation

protocol CoffeeBrewingStatus {
    var description: String { get }
}

struct WaitingForBaristaBrewingStatus: CoffeeBrewingStatus {
    let description = "Waiting for a barista"
}

struct MakingTheCoffeeBrewingStatus: CoffeeBrewingStatus {
    let description = "Barista is making you coffee"
}

struct CoffeeIsReadyBrewingStatus: CoffeeBrewingStatus {
    let description = "Voila! Coffee is ready!"
}
