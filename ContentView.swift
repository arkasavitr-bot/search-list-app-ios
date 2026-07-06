import SwiftUI

struct ContentView: View {

    // MARK: - State

    // Text currently typed in the "Add Item" textbox
    @State private var inputText: String = ""

    // Text currently typed in the search box.
    // This is @State (in-memory only), so it always starts empty
    // when the app is launched - it is never restored from storage.
    @State private var searchText: String = ""

    // Results currently shown in the list box. Populated only when
    // searchText is non-empty, by reading fresh from local storage.
    @State private var searchResults: [String] = []

    // Simple toast-style confirmation after Submit
    @State private var showSavedAlert: Bool = false

    private let storage = LocalStorage.shared

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Section 1 - Add Item (store only, no display)
                Text("Add Item")
                    .font(.headline)

                HStack {
                    TextField("Type something...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Submit") {
                        submitText()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Divider()

                // MARK: Section 2 - Search (live/instant, reset on relaunch)
                Text("Search")
                    .font(.headline)

                TextField("Search items...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText) { newValue in
                        performLiveSearch(query: newValue)
                    }

                // MARK: Section 3 - Result list box
                List(searchResults, id: \.self) { item in
                    Text(item)
                }
                .listStyle(PlainListStyle())

            }
            .padding()
            .navigationTitle("Search List App")
            .alert("Saved to device", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: - Actions

    /// Saves the submitted text directly to local device storage.
    /// Nothing is displayed on screen as a result - storage only.
    private func submitText() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        storage.saveItem(trimmed)
        inputText = ""
        showSavedAlert = true
        // Note: we deliberately do NOT touch searchResults here,
        // since submit is storage-only, not display.
    }

    /// Live/instant search: reads all saved items fresh from local storage
    /// every time the query changes, and filters them.
    private func performLiveSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            return
        }
        let allItems = storage.loadItems()
        searchResults = allItems.filter {
            $0.range(of: trimmedQuery, options: .caseInsensitive) != nil
        }
    }
}

#Preview {
    ContentView()
}
