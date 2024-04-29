//
//  Coffee.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import Foundation

struct Coffee: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: String
    let ingredients: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case imageUrl = "image"
        case ingredients = "ingredients"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? values.decode(Int.self, forKey: .id)) ?? Int.random(in: 1000..<Int.max)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        imageUrl = try values.decode(String.self, forKey: .imageUrl)
        ingredients = try values.decode([String].self, forKey: .ingredients)
    }
    
    init(id: Int, title: String, description: String, imageUrl: String, ingredients: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.ingredients = ingredients
    }
}
