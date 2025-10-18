//
//  PriorityBadge.swift
//  Prioritv
//
//  Created by Kisura W.S.P on 2025-10-18.
//

import SwiftUI

struct PriorityBadge: View {
    let priority: Int // 1,2,3

    var body: some View {
        ZStack {
            Circle().fill(bg)
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title2)
                .foregroundStyle(fg)
                .opacity(priority == 3 ? 1 : 0.85)
        }
        .overlay(
            Text(short)
                .font(.headline)
                .foregroundStyle(fg)
        )
    }

    private var fg: Color {
        switch priority { case 3,2: return .white; default: return .black }
    }
    private var bg: Color {
        switch priority { case 3: return .red; case 2: return .orange; default: return .yellow }
    }
    private var short: String {
        switch priority { case 3: return "H"; case 2: return "M"; default: return "L" }
    }
}
