//
//  RandomUserReviewView.swift
//  AppO11yDemo
//
//  Created by Robert Magnusson on 29.04.24.
//

import SwiftUI

struct RandomUserReviewView: View {
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D")) { phase in
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
            .frame(width: 50, height: 50)
            .clipShape(.circle)
            VStack(alignment: .leading) {
                Text("I like it")
                Text("☕☕☕☕☕")
            }
        }
    }
}

#Preview {
    RandomUserReviewView()
}
