//
//  GameViewModel.swift
//  QuickBurstTV
//
//  Created by Kisura W.S.P on 2025-11-19.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published State

    @Published var players: [Player] = []
    @Published var phase: GamePhase = .lobby

    @Published var questions: [Question] = Question.sampleQuestions
    @Published var currentQuestionIndex: Int = 0

    // For each question, store each player's chosen answer index
    @Published var currentAnswers: [UUID: Int] = [:]

    // Used to toggle showing the correct answer on screen
    @Published var showCorrectAnswer: Bool = false

    // Which player are we currently collecting an answer from?
    @Published var activePlayerIndex: Int = 0

    // MARK: - Computed

    var currentQuestion: Question? {
        guard currentQuestionIndex >= 0 && currentQuestionIndex < questions.count else {
            return nil
        }
        return questions[currentQuestionIndex]
    }

    var activePlayer: Player? {
        guard !players.isEmpty,
              activePlayerIndex >= 0,
              activePlayerIndex < players.count else { return nil }
        return players[activePlayerIndex]
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }

    // MARK: - Lobby Actions

    func addPlayer(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newPlayer = Player(id: UUID(), name: trimmed, score: 0)
        players.append(newPlayer)
    }

    func removePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    func startGame() {
        guard players.count >= 2 else { return } // at least 2 for "party" feel

        // Reset everything
        questions = Question.sampleQuestions.shuffled()
        currentQuestionIndex = 0
        for index in players.indices {
            players[index].score = 0
        }
        currentAnswers = [:]
        activePlayerIndex = 0
        showCorrectAnswer = false
        phase = .question
    }

    func backToLobby() {
        phase = .lobby
        currentQuestionIndex = 0
        currentAnswers = [:]
        activePlayerIndex = 0
        showCorrectAnswer = false
    }

    // MARK: - Question Flow

    func selectAnswer(optionIndex: Int) {
        guard let activePlayer = activePlayer else { return }

        // Record this player's answer
        currentAnswers[activePlayer.id] = optionIndex

        // Move to next player or reveal results
        if activePlayerIndex < players.count - 1 {
            activePlayerIndex += 1
        } else {
            // All players answered -> score
            scoreCurrentQuestion()
        }
    }

    private func scoreCurrentQuestion() {
        guard let question = currentQuestion else { return }

        // Update scores
        for i in players.indices {
            let playerID = players[i].id
            if let chosenIndex = currentAnswers[playerID],
               chosenIndex == question.correctIndex {
                players[i].score += 1
            }
        }

        // Show correct answer highlight
        showCorrectAnswer = true
    }

    func nextQuestionOrFinish() {
        showCorrectAnswer = false
        currentAnswers = [:]
        activePlayerIndex = 0

        if isLastQuestion {
            phase = .scoreboard
        } else {
            currentQuestionIndex += 1
        }
    }

    // MARK: - Helpers

    func sortedPlayersByScore() -> [Player] {
        players.sorted { $0.score > $1.score }
    }
}
