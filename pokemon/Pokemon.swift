//
//  Pokemon.swift
//  pokemon
//
//  Created by Anika Morris on 6/26/20.
//  Copyright © 2020 Anika Morris. All rights reserved.
//


import Foundation

struct Pokemon: Codable {
    let name: String
    let url: URL
}

struct PokemonList: Codable {
    let list: [Pokemon]
}

