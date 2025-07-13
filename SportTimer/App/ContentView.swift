//
//  ContentView.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        TabView {
            homeTab
                .tabItem {
                    Image(systemName: "house")
                    Text(NSLocalizedString("HomeTab", comment: ""))
                }
            
            timerTab
                .tabItem {
                    Image(systemName: "timer")
                    Text(NSLocalizedString("TimerTab", comment: ""))
                }
            
            historyTab
                .tabItem {
                    Image(systemName: "book")
                    Text(NSLocalizedString("HistoryTab", comment: ""))
                }
            
            profileTab
                .tabItem {
                    Image(systemName: "person")
                    Text(NSLocalizedString("ProfileTab", comment: ""))
                }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var homeTab: some View {
        NavigationView {
            HomeScreen()
                .navigationTitle(NSLocalizedString("HomeTitle", comment: ""))
        }
    }
    
    @ViewBuilder
    var timerTab: some View {
        NavigationView {
            TimerScreen()
                .navigationTitle(NSLocalizedString("TimerTitle", comment: ""))
        }
    }
    
    @ViewBuilder
    var historyTab: some View {
        NavigationView {
            HistoryScreen()
                .navigationTitle(NSLocalizedString("HistoryTitle", comment: ""))
        }
    }
    
    @ViewBuilder
    var profileTab: some View {
        NavigationView {
            ProfileScreen()
                .navigationTitle(NSLocalizedString("ProfileTitle", comment: ""))
        }
    }
    
    /*var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }*/

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

func showConfirmationDialog(confirmationHandler: @escaping () -> Void) {
    let alert = UIAlertController(title: "Confirm this action", message: "Are you sure you want to finish this training?", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in
        alert.dismiss(animated: true)
    })
    
    alert.addAction(UIAlertAction(title: "Finish", style: .default) {_ in
        alert.dismiss(animated: true)
        
        confirmationHandler()
    })
    
    alert.presentAlert()
}

func showItemDeletionDialog(confirmationHandler: @escaping () -> Void) {
    let alert = UIAlertController(title: "Confirm this action", message: "Are you sure you want to delete this item? This cannot be undone", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in
        alert.dismiss(animated: true)
    })
    
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) {_ in
        alert.dismiss(animated: true)
        
        confirmationHandler()
    })
    
    alert.presentAlert()
}
