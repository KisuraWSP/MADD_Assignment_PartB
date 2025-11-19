//
//  Models.swift
//  QuickBurstTV
//
//  Created by Kisura W.S.P on 2025-11-19.
//

import Foundation

// MARK: - Core Models

struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let options: [String]
    let correctIndex: Int
}

struct Player: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var score: Int
}

// High-level phase of the game
enum GamePhase {
    case lobby
    case question
    case scoreboard
}

// Helper: some sample questions for the prototype
extension Question {
    static let sampleQuestions: [Question] = [
        Question(
            id: UUID(),
            text: "Which company created the Swift programming language?",
            options: ["Google", "Microsoft", "Apple", "Meta"],
            correctIndex: 2
        ),
        Question(
            id: UUID(),
            text: "What does UI stand for?",
            options: ["User Interaction", "Universal Input", "User Interface", "Unified Internet"],
            correctIndex: 2
        ),
        Question(
            id: UUID(),
            text: "Which device runs tvOS?",
            options: ["Apple TV", "Apple Watch", "HomePod", "MacBook"],
            correctIndex: 0
        )
    ]
}
