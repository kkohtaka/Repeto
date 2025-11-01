//
//  ContentView.swift
//  Repeto
//
//  Created by Kazumasa Kohtaka on 2025/11/01.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Repeto")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("繰り返しタスクのリマインダー")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !tasks.isEmpty {
                    Text("\(tasks.count) タスク")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
            }
            .padding()
            .navigationTitle("Repeto")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
