
import Foundation

class Downloader {
    
    private let downloadSession = URLSession(configuration: .default)
    private var activeDownloads: [URL: Download] = [:]
    
    func download(track: Track) {
        guard !isAlreadyDownloading(track: track) else {
            return
        }
        var download = Download(url: track.url)
        download.task = downloadSession.downloadTask(with: track.url)
        download.isDownloading = true
        download.task!.resume()
    }
    
    func isAlreadyDownloading(track: Track) -> Bool {
        if let download = activeDownloads[track.url] {
            return download.isDownloading
        }
        return false
    }
}

struct Download {
    var url: URL
    var task: URLSessionDownloadTask? = nil
    var isDownloading = false
}
