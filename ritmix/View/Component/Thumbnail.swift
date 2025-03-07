//
//  Thumbnail.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct Thumbnail: View {
    var url: String
    var size: Float = 70
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty, .failure:
                Rectangle()
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay{
                        ProgressView()
                            .backgroundStyle(.clear)
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: CGFloat(size), height: CGFloat(size))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: CGFloat(size), height: CGFloat(size))
    }
}
