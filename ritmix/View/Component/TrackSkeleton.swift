//
//  TrackSkeleton.swift
//  ritmix
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct TrackSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .foregroundStyle(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay{
                    ProgressView()
                        .backgroundStyle(.clear)
                }
                .frame(width: 70, height: 70)
            
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 150, height: 15)
                Rectangle()
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 100, height: 15)
                Rectangle()
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 50, height: 15)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    TrackSkeleton()
}
