
import Foundation

class TrackLocalStorage {
    
    func localFilePath(for url: URL) -> URL {
        return FileManager.documentPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func localFileExists(for url: URL) -> Bool {
        let localFile = localFilePath(for: url)
        return FileManager.fileExists(url: localFile)
    }
}

extension FileManager {
    
    static let documentPath: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }()
    
    static func fileExists(url: URL, isDirectory: Bool = false) -> Bool {
        var isDir = ObjCBool(isDirectory)
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
    }
}
