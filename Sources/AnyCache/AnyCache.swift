//
//  AnyCache.swift
//
//
//  Created by Eemil Karvonen on 18.3.2023.
//

import Foundation

public protocol AnyCacheInterface {
    associatedtype T: Codable

    /**
     Adds new entry to cache
        - Parameters:
         - value: the cached value
         - key: the key in which the entry will be saved in a cache
     */
    func setEntry(_ value: T, for key: String)

    /**
     Get entry from cache for a key
        - Parameters:
         - key: the key which will be used to search the cache
     */
    func getEntry(for key: String) -> T?

    /// Get all entries from cache
    func getAllEntries() -> [T]?

    /// Remove specific entry from cache for a key
    func removeEntry(for key: String)

    /// Remove all entries from cache
    func removeAllEntries()

    /// Checks if given entry exist in cache
    func entryExists(for key: String) -> Bool
}


/// Generic cache which can be declared with a specificf type to hold cache value of that type.
final class AnyCache<T: Codable>: AnyCacheInterface {

    private let varyingCacheDirectory: URL?
    private let fileManager: FileManager = .default
    /// cacheName is declared on init to differentiate caches from each other which are used with this generic
    let cacheName: String

    init(cacheName: String) {
        self.cacheName = cacheName

        let cacheDirectory: URL? = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let cacheDirectory = cacheDirectory else {
            varyingCacheDirectory = nil
            print("Cache directory is nil")
            return
        }
        varyingCacheDirectory = cacheDirectory.appendingPathComponent(cacheName)
        guard let varyingCacheDirectory = varyingCacheDirectory else {
            print("\(cacheName) cache directory is nil")
            return
        }

        // If cache directory doesnt exist, create one
        if !fileManager.fileExists(atPath: varyingCacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: varyingCacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Cannot create \(cacheName) cache directory: \(error)")
            }
        }

    }

    func setEntry(_ value: T, for key: String) {
        guard let varyingCacheDirectory = varyingCacheDirectory else { return }

        let url = varyingCacheDirectory.appendingPathComponent(key)
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url)
        } catch {
            print("Error caching value: \(error)")
        }
    }

    func getEntry(for key: String) -> T? {
        guard let varyingCacheDirectory = varyingCacheDirectory else { return nil }

        let url = varyingCacheDirectory.appendingPathComponent(key)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error fetching cached value: \(error)")
            return nil
        }
    }

    func getAllEntries() -> [T]? {
        guard let varyingCacheDirectory = varyingCacheDirectory else { return nil }

        do {
            let contents = try fileManager.contentsOfDirectory(at: varyingCacheDirectory, includingPropertiesForKeys: nil)
            var arr: [T] = []
            for url in contents {
                let data = try Data(contentsOf: url)
                let entry = try JSONDecoder().decode(T.self, from : data)
                arr.append(entry)
            }
            return arr
        } catch {
            print("Error fetching all cached values \(error)")
            return nil
        }
    }

    func removeEntry(for key: String) {
        guard let varyingCacheDirectory = varyingCacheDirectory else { return }

        let url = varyingCacheDirectory.appendingPathComponent(key)
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Error removing cached value: \(error)")
        }
    }

    func removeAllEntries() {
        guard let varyingCacheDirectory = varyingCacheDirectory else { return }

        do {
            let contents = try fileManager.contentsOfDirectory(at: varyingCacheDirectory, includingPropertiesForKeys: nil)
            for url in contents {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Error removing all cached values: \(error)")
        }
    }

    func entryExists(for key: String) -> Bool {
        guard let varyingCacheDirectory = varyingCacheDirectory else { return false }

        let url = varyingCacheDirectory.appendingPathComponent(key)
        return fileManager.fileExists(atPath: url.path)
    }
}
