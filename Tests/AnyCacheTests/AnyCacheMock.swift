//
//  AnyCacheMock.swift
//  
//
//  Created by Eemil Karvonen on 18.3.2023.
//

import Foundation

final class AnyCacheMock<T: Codable>: AnyCacheInterface {
    private var cache = [String: T]()
    var setEntryCallCount = 0
    var getEntryCallCount = 0
    var getAllEntriesCallCount = 0
    var removeEntryCallCount = 0
    var removeAllEntriesCallCount = 0
    var entryExistsCallCount = 0

    func setEntry(_ value: T, for key: String) {
        setEntryCallCount += 1
        cache[key] = value
    }

    func getEntry(for key: String) -> T? {
        getEntryCallCount += 1
        return cache[key]
    }

    func getAllEntries() -> [T]? {
        getAllEntriesCallCount += 1
        return Array(cache.values)
    }

    func removeEntry(for key: String) {
        removeEntryCallCount += 1
        cache[key] = nil
    }

    func removeAllEntries() {
        removeAllEntriesCallCount += 1
        cache.removeAll()
    }

    func entryExists(for key: String) -> Bool {
        entryExistsCallCount += 1
        return cache[key] != nil
    }
}

