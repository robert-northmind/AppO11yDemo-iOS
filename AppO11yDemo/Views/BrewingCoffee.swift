//
//  BrewingCoffee.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 30.04.24.
//

import SwiftUI

struct BrewingCoffee: View {
    let coffee: Coffee
    
    @StateObject var viewModel = BrewingCoffeeViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                AsyncImage(url: URL(string: "https://coffee.alexflipnote.dev/random")) { phase in
                    switch phase {
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        ProgressView()
                    }
                }
                .frame(height: 200)
                .clipped()
                Spacer()
                Text(viewModel.brewingStatusText).padding()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Brewing a \(coffee.title)")
            .onDisappear {
                viewModel.stopBrewing()
            }
        }
    }
}

#Preview {
    BrewingCoffee(coffee:Coffee(
        title: "Latte",
        description: "A Latte, often simply referred to as a latte, is a coffee classic beloved for its creamy smoothness. This popular beverage combines espresso with steamed milk, topped with a light layer of frothy milk foam. Typically made with a one-to-three ratio of espresso to milk, a latte offers a milder and milkier coffee experience compared to a cappuccino. It's a perfect choice for those who enjoy a rich coffee flavor balanced by the creaminess of milk. Lattes can be enjoyed plain or flavored with syrups such as vanilla, caramel, or hazelnut for an added touch of sweetness.",
        imageUrl: "https://images.unsplash.com/photo-1561882468-9110e03e0f78?auto=format&fit=crop&q=60&w=800&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fGxhdHRlfGVufDB8fDB8fHww",
        ingredients: ["Espresso", "Steamed milk", "Caramel syrup"]
    ))
}
