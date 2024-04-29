//
//  CoffeeListView.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import SwiftUI

struct CoffeeListView: View {
    @StateObject var viewModel = CoffeeListViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                VStack {
                    Text("Loading")
                    ProgressView()
                }
            } else if let error = viewModel.error {
                Text(viewModel.getErrorText(error))
            } else {
                List {
                    ForEach(viewModel.coffees) { coffee in
                        NavigationLink(value: coffee) {
                            HStack{
                                AsyncImage(url: URL(string: coffee.imageUrl)) { phase in
                                    switch phase {
                                    case .failure:
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                    case .success(let image):
                                        image
                                            .resizable()
                                    default:
                                        ProgressView()
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(.circle)
                                Text("\(coffee.title)")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Coffees")
                .navigationDestination(for: Coffee.self) { coffee in
                    CoffeeDetailView(coffee: coffee)
                }
            }
        }
        .task {
            await viewModel.getCoffees()
        }
    }
}

#Preview {
    CoffeeListView()
}
