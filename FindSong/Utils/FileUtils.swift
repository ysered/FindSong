
import Foundation

extension FileManager {
    
    static let documentPath: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }()
    
    static func fileExists(url: URL, isDirectory: Bool = false) -> Bool {
        var isDir = ObjCBool(isDirectory)
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
    }
    
    static func localFilePath(for url: URL) -> URL {
        return FileManager.localFilePath(for: url.lastPathComponent)
    }
    
    static func localFilePath(for name: String) -> URL {
        return FileManager.documentPath.appendingPathComponent(name)
    }
    
    static func localFileExists(at url: URL) -> Bool {
        let localFile = FileManager.localFilePath(for: url)
        return FileManager.fileExists(url: localFile)
    }
    
    static func localFileExists(with name: String) -> Bool {
        let localFile = localFilePath(for: name)
        return FileManager.fileExists(url: localFile)
    }
    
    static func copyFileIntoDocumentDirectory(location: URL, withName: String? = nil) -> URL? {
        let fileName = withName ?? location.lastPathComponent
        if localFileExists(with: fileName) {
            return nil
        }
        
        let destination = FileManager.localFilePath(for: fileName)
        
        do {
            try FileManager.default.copyItem(at: location, to: destination)
        } catch {
            debugPrint("Could not copy file from: \(location.path) to \(destination.path)")
            return nil
        }

        return destination
    }
}
