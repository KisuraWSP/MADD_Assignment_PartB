//
//  ContentView.swift
//  QuickBurstTV
//
//  Created by Kisura W.S.P on 2025-11-19.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var game: GameViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            switch game.phase {
            case .lobby:
                LobbyView()
            case .question:
                QuestionView()
            case .scoreboard:
                ScoreboardView()
            }
        }
    }
}

// MARK: - Lobby Screen

struct LobbyView: View {

    @EnvironmentObject var game: GameViewModel
    @State private var newPlayerName: String = ""

    var body: some View {
        VStack(spacing: 40) {

            Text("QuickBurst TV")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(radius: 8)

            Text("Add players and start the trivia party!")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))

            // TextField + Add Player Button
            HStack(alignment: .center, spacing: 24) {

                // tvOS-friendly TextField
                TextField("Player name", text: $newPlayerName)
                    .padding(14)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .foregroundColor(.white)
                    .frame(width: 400)
                    .submitLabel(.done)
                    .onSubmit {
                        addPlayer()
                    }

                Button("Add Player") {
                    addPlayer()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            // Player List
            if game.players.isEmpty {
                Text("No players yet. Add at least two players to begin.")
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                List {
                    ForEach(game.players) { player in
                        Text(player.name)
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .onDelete(perform: game.removePlayer)
                }
                // tvOS DOES NOT support .scrollContentBackground()
                .frame(width: 600, height: 260)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.25))
                )
            }

            // Start Button
            Button {
                game.startGame()
            } label: {
                Text("Start Game")
                    .font(.title)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(game.players.count < 2)
            .opacity(game.players.count < 2 ? 0.5 : 1.0)

            Spacer()
        }
        .padding(.top, 80)
        .padding(.horizontal, 80)
    }

    private func addPlayer() {
        game.addPlayer(named: newPlayerName)
        newPlayerName = ""
    }
}

// MARK: - Question Screen

struct QuestionView: View {

    @EnvironmentObject var game: GameViewModel

    var body: some View {
        guard let question = game.currentQuestion,
              let activePlayer = game.activePlayer else {
            return AnyView(Text("Loading question...").foregroundStyle(.white))
        }

        return AnyView(
            VStack(spacing: 40) {

                // Top info bar
                HStack {
                    Text("Question \(game.currentQuestionIndex + 1) / \(game.questions.count)")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer()

                    Text("Now answering: \(activePlayer.name)")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.yellow)
                }

                // Question text
                Text(question.text)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 1000, alignment: .leading)

                // Options
                VStack(spacing: 24) {
                    ForEach(question.options.indices, id: \.self) { index in
                        AnswerButton(
                            text: question.options[index],
                            isCorrect: index == question.correctIndex,
                            shouldHighlight: game.showCorrectAnswer
                        ) {
                            if !game.showCorrectAnswer {
                                game.selectAnswer(optionIndex: index)
                            }
                        }
                    }
                }
                .frame(maxWidth: 900)

                // Bottom controls
                HStack {
                    Button("Back to Lobby") {
                        game.backToLobby()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)

                    Spacer()

                    if game.showCorrectAnswer {
                        Button(game.isLastQuestion ? "View Final Scores" : "Next Question") {
                            game.nextQuestionOrFinish()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        Text("Use the remote to pick an answer for each player.")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                Spacer()
            }
            .padding(60)
        )
    }
}

struct AnswerButton: View {
    let text: String
    let isCorrect: Bool
    let shouldHighlight: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 12)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .buttonStyle(.borderedProminent)
        .tint(buttonTintColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 4)
    }

    private var buttonTintColor: Color {
        if shouldHighlight {
            return isCorrect ? .green : .red
        } else {
            return .blue
        }
    }
}

// MARK: - Scoreboard Screen

struct ScoreboardView: View {

    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let sortedPlayers = game.sortedPlayersByScore()

        return VStack(spacing: 40) {

            Text("Final Scores")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(.white)

            // Winner message
            if let topScore = sortedPlayers.first?.score {
                let winners = sortedPlayers.filter { $0.score == topScore }

                if winners.count == 1 {
                    Text("🏆 Winner: \(winners[0].name) with \(topScore) points!")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                } else {
                    Text("🏆 Winners: \(winners.map { $0.name }.joined(separator: ", ")) with \(topScore) points!")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                }
            }

            // Scores list
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    HStack {
                        Text("\(index + 1). \(player.name)")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Spacer()

                        Text("\(player.score) pts")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                    )
                }
            }
            .frame(maxWidth: 800)

            HStack(spacing: 40) {
                Button("Play Again") {
                    game.startGame()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Back to Lobby") {
                    game.backToLobby()
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }

            Spacer()
        }
        .padding(60)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
