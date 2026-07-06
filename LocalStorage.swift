import Foundation

/// Handles reading/writing submitted items to local device storage.
/// Uses UserDefaults (iOS's standard local key-value storage), storing
/// items as a simple array of strings under one key.
final class LocalStorage {

    static let shared = LocalStorage()

    private let defaults = UserDefaults.standard
    private let itemsKey = "saved_items"

    private init() {}

    /// Appends one new item to local storage. Newest item first.
    func saveItem(_ text: String) {
        var items = loadItems()
        items.insert(text, at: 0)
        defaults.set(items, forKey: itemsKey)
    }

    /// Reads all saved items from local storage.
    func loadItems() -> [String] {
        return defaults.stringArray(forKey: itemsKey) ?? []
    }

    /// Optional helper if you ever want a "Clear All" button.
    func clearAll() {
        defaults.removeObject(forKey: itemsKey)
    }
}
