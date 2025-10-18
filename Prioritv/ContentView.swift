//
//  ContentView.swift
//  Prioritv
//
//  Created by Kisura W.S.P on 2025-10-13.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            RemindersHomeView()
                .navigationTitle("Prioritv")
        }
    }
}

struct RemindersHomeView: View {
    @Environment(\.managedObjectContext) private var ctx
    @State private var goAllAfterCreate = false  // jump so you can see the new row

    var body: some View {
        List {
            Section {
                NavigationLink {
                    RemindersListView(filter: .today)
                } label: {
                    Label("Today", systemImage: "sun.max.fill")
                }
                NavigationLink {
                    RemindersListView(filter: .upcoming)
                } label: {
                    Label("Upcoming", systemImage: "calendar.badge.clock")
                }
                NavigationLink {
                    RemindersListView(filter: .all)
                } label: {
                    Label("All Reminders", systemImage: "list.bullet")
                }
            }

            Section("Quick Actions") {
                Button {
                    createEmptyReminder()
                    // Jump to All so the new item is visible immediately
                    withAnimation { goAllAfterCreate = true }
                } label: {
                    Label("New Reminder", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .focusable(true)
            }
        }
        .navigationTitle("Prioritv")
        .navigationDestination(isPresented: $goAllAfterCreate) {
            RemindersListView(filter: .all)
        }
    }

    // Keep this dead simple and loud if it fails.
    private func createEmptyReminder() {
        let r = Reminder(context: ctx)
        r.title = "Untitled"        // change to "" if you prefer empty text
        r.details = nil
        r.priority = 2
        r.createdAt = Date()
        r.remindAt = nil

        do {
            try ctx.save()
            print("✅ Created reminder \(r.objectID)")
        } catch {
            print("❌ Core Data save failed: \(error)")
            assertionFailure("Save failed: \(error)")
        }
    }
}
