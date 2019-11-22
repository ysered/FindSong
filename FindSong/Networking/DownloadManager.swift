
import Foundation


struct Download {
    var url: URL
    var task: URLSessionDownloadTask? = nil
    var isDownloading = false
}

protocol DownloadManagerDelegate: NSObjectProtocol {
    
    func trackDidDownload(source url: URL, localPath path: URL)
    
    func downloadingProgress(for url: URL, progress: Float)
}

class DownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    static var shared = DownloadManager()
    
    private var urlSession: URLSession {
        let session = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        return URLSession(configuration: session, delegate: self, delegateQueue: OperationQueue())
    }
    private var activeDownloads: [URL: Download] = [:]
    
    var delegate: DownloadManagerDelegate? = nil

    override private init() {
        super.init()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            return
        }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        debugPrint("Progress \(downloadTask.originalRequest?.url?.lastPathComponent ?? "") \(progress)")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Track downloaded: \(location.path)")
        if let originalUrl = downloadTask.originalRequest?.url,
            let destination = FileManager.copyFileIntoDocumentDirectory(location: location, withName: originalUrl.lastPathComponent) {
            DispatchQueue.main.async {
                self.delegate?.trackDidDownload(source: originalUrl, localPath: destination)
            }
            debugPrint("Track copied into: \(destination.path)")
        }
        
    }
    
    func download(track: Track) {
        guard !isAlreadyDownloading(track: track) else {
            return
        }
        var download = Download(url: track.url)
        download.task = urlSession.downloadTask(with: track.url)
        download.isDownloading = true
        download.task!.resume()
    }
    
    private func isAlreadyDownloading(track: Track) -> Bool {
        if let download = activeDownloads[track.url] {
            return download.isDownloading
        }
        return false
    }
}
