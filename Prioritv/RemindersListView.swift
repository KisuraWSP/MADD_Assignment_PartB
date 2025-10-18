//
//  RemindersListView.swift
//  Prioritv
//
//  Created by Kisura W.S.P on 2025-10-18.
//

import SwiftUI
import CoreData

enum ReminderFilter { case today, upcoming, all }

struct RemindersListView: View {
    @Environment(\.managedObjectContext) private var ctx
    let filter: ReminderFilter

    @FetchRequest private var reminders: FetchedResults<Reminder>

    init(filter: ReminderFilter) {
        self.filter = filter
        let req: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let now = Date()

        switch filter {
        case .today:
            let start = Calendar.current.startOfDay(for: now)
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            req.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "remindAt >= %@ AND remindAt < %@", start as NSDate, end as NSDate),
                NSPredicate(format: "remindAt == nil AND createdAt >= %@ AND createdAt < %@", start as NSDate, end as NSDate)
            ])
        case .upcoming:
            req.predicate = NSPredicate(format: "remindAt > %@", now as NSDate)
        case .all:
            req.predicate = nil
        }

        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Reminder.priority, ascending: false),
            NSSortDescriptor(keyPath: \Reminder.remindAt, ascending: true),
            NSSortDescriptor(keyPath: \Reminder.createdAt, ascending: false)
        ]
        _reminders = FetchRequest(fetchRequest: req, animation: .default)
    }

    var body: some View {
        List {
            if case .all = filter {
                // Extra creation point in the All list
                Button {
                    let r = Reminder(context: ctx)
                    r.title = "Untitled"
                    r.priority = 2
                    r.createdAt = Date()
                    do { try ctx.save(); print("✅ Quick add \(r.objectID)") }
                    catch { print("❌ Save failed: \(error)"); assertionFailure("Save failed: \(error)") }
                } label: {
                    Label("Add Quick Reminder", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
                .focusable(true)
            }

            ForEach(reminders) { r in
                HStack(spacing: 16) {
                    NavigationLink {
                        ReminderEditorView(mode: .edit(r))
                    } label: {
                        ReminderRow(reminder: r)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 20)

                    Button(role: .destructive) {
                        delete(reminder: r)
                    } label: {
                        Image(systemName: "trash").font(.title2)
                    }
                    .buttonStyle(.bordered)
                    .focusable(true)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle(title)
    }


    private var title: String {
        switch filter {
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .all: return "All Reminders"
        }
    }

    private func delete(reminder: Reminder) {
        ctx.delete(reminder)
        try? ctx.save()
    }
}

struct ReminderRow: View {
    @ObservedObject var reminder: Reminder

    var body: some View {
        HStack(spacing: 16) {
            PriorityBadge(priority: Int(reminder.priority))
                .frame(width: 60, height: 60)
                .focusable(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title ?? "")
                    .font(.title3.weight(.semibold))
                    .lineLimit(2)
                if let d = reminder.remindAt {
                    Text(d.formatted(date: .abbreviated, time: .shortened))
                        .font(.callout).foregroundStyle(.secondary)
                } else {
                    Text("No reminder date")
                        .font(.callout).foregroundStyle(.secondary)
                }
            }
        }
    }
}
