//
//  Utils.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation
import SwiftUI

struct TruncatedTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

extension View {
    func truncated() -> some View {
        self.modifier(TruncatedTextModifier())
    }
}
