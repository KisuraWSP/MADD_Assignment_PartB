//
//  ReminderEditorView.swift
//  Prioritv
//
//  Created by Kisura W.S.P on 2025-10-18.
//

import SwiftUI
import CoreData

struct ReminderEditorView: View {
    enum Mode { case create, edit(Reminder) }

    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    // Local draft
    @State private var titleText: String = ""
    @State private var detailsText: String = ""
    @State private var priority: Int = 2
    @State private var remindEnabled: Bool = false
    @State private var remindDate: Date = Date().addingTimeInterval(3600)

    init(mode: Mode = .create) { self.mode = mode }

    var body: some View {
        Form {
            Section("Main") {
                TextField("Title", text: $titleText)
                    .font(.title2)
                    .textInputAutocapitalization(.sentences)
                TextField("Notes (optional)", text: $detailsText, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Priority") {
                HStack(spacing: 28) {
                    ForEach(1...3, id: \.self) { p in
                        Button { priority = p } label: {
                            VStack {
                                PriorityBadge(priority: p).frame(width: 72, height: 72)
                                Text(name(for: p))
                            }
                        }
                        .buttonStyle(.borderless)
                        .focusable(true)
                    }
                }
            }

            Section("Remind Me") {
                Toggle("Set reminder date", isOn: $remindEnabled)
                if remindEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(remindDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.title3.weight(.semibold))

                        HStack(spacing: 16) {
                            nudgeButton("-1h")  { remindDate.addTime(-3600) }
                            nudgeButton("-15m") { remindDate.addTime(-900) }
                            nudgeButton("+15m") { remindDate.addTime( 900) }
                            nudgeButton("+1h")  { remindDate.addTime( 3600) }
                        }

                        HStack(spacing: 16) {
                            presetButton("Now") { remindDate = Date().roundedTo(minutes: 5) }
                            presetButton("Tonight 8pm") { remindDate = Date.tonight(hour: 20, minute: 0) }
                            presetButton("Tomorrow 9am") { remindDate = Date.tomorrow(hour: 9, minute: 0) }
                            Button(role: .destructive) { remindEnabled = false } label: {
                                Label("Clear", systemImage: "xmark.circle")
                            }
                            .buttonStyle(.bordered).focusable(true)
                        }
                    }
                    .padding(.top, 6)
                }
            }

            Section {
                HStack {
                    Button("Save", action: save).buttonStyle(.borderedProminent)
                    Button("Cancel", role: .cancel) { dismiss() }.buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle(modeTitle)
        .onAppear(perform: bootstrap)   // ✅ fixed
    }

    // MARK: helpers
    private var modeTitle: String { mode.isCreate ? "New Reminder" : "Edit Reminder" }

    private func name(for p: Int) -> String {
        switch p { case 3: return "High"; case 2: return "Medium"; default: return "Low" }
    }

    private func bootstrap() {
        if case .edit(let r) = mode {
            titleText = r.title ?? ""
            detailsText = r.details ?? ""
            priority = Int(r.priority)
            if let d = r.remindAt { remindEnabled = true; remindDate = d }
        }
    }

    private func save() {
        let trimmed = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        ctx.performAndWait {
            switch mode {
            case .create:
                let r = Reminder(context: ctx)
                r.title = trimmed
                r.details = detailsText.isEmpty ? nil : detailsText
                r.priority = Int16(priority)
                r.createdAt = Date()
                r.remindAt = remindEnabled ? remindDate : nil

            case .edit(let r):
                r.title = trimmed
                r.details = detailsText.isEmpty ? nil : detailsText
                r.priority = Int16(priority)
                r.remindAt = remindEnabled ? remindDate : nil
                if r.createdAt == nil { r.createdAt = Date() }
            }

            do {
                try ctx.save()
            } catch {
                assertionFailure("Core Data save failed: \(error)")
            }
        }

        dismiss()
    }


    // tvOS-friendly buttons
    @ViewBuilder private func nudgeButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action).buttonStyle(.bordered).focusable(true)
    }
    @ViewBuilder private func presetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button { action() } label: { Label(title, systemImage: "clock") }
            .buttonStyle(.bordered).focusable(true)
    }
}

private extension ReminderEditorView.Mode {
    var isCreate: Bool { if case .create = self { return true } else { return false } }
}

// Date helpers
private extension Date {
    mutating func addTime(_ seconds: TimeInterval) { self = self.addingTimeInterval(seconds).roundedTo(minutes: 5) }
    func roundedTo(minutes: Int) -> Date {
        let sec = Double(minutes * 60)
        let t = timeIntervalSinceReferenceDate
        let rounded = (t / sec).rounded() * sec
        return Date(timeIntervalSinceReferenceDate: rounded)
    }
    static func tonight(hour: Int, minute: Int) -> Date {
        let now = Date()
        var c = Calendar.current.dateComponents([.year, .month, .day], from: now)
        c.hour = hour; c.minute = minute
        var d = Calendar.current.date(from: c) ?? now
        if d < now { d = d.addingTimeInterval(86400) }
        return d
    }
    static func tomorrow(hour: Int, minute: Int) -> Date {
        let now = Date()
        var c = Calendar.current.dateComponents([.year, .month, .day], from: now)
        c.day = (c.day ?? 0) + 1
        c.hour = hour; c.minute = minute
        return Calendar.current.date(from: c) ?? now.addingTimeInterval(86400)
    }
}
