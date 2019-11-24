
import UIKit
import AVKit

class SearchViewController: UIViewController {

    private let queryService = QueryService()
    private let downloadManager = DownloadManager.shared
    
    private var tracks = [Track]()
    private var activeDownloads = [URL:Float]()
    
    @IBOutlet weak var searchSongBar: UISearchBar!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSongBar.delegate = self
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        downloadManager.delegate = self
        activityIndicator.hidesWhenStopped = true
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        activityIndicator.startAnimating()
        queryService.searchForSong(by: searchText, completion: { tracks, error in
            self.activityIndicator.stopAnimating()
            if let tracks = tracks {
                self.tracks = tracks
                self.tracksTableView.reloadData()
                self.searchSongBar.searchTextField.resignFirstResponder()
            } else {
                print("Error occured: \(error)")
            }
        })
    }
       
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        queryService.discardPreviousQuery()
        tracks = []
        activeDownloads = [:]
        tracksTableView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("Bookmark button clicked!")
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        guard tracks.indices.contains(indexPath.row) else {
            return cell
        }
        let track = tracks[indexPath.row]
        let isDownloaded = FileManager.localFileExists(with: track.url.lastPathComponent)
        cell.configure(for: track, position: indexPath.row, isDownloaded: isDownloaded, delegate: self)
        if let progress = activeDownloads[track.url] {
            cell.updateDownloadingProgress(progress: progress)
        } else {
            cell.downloadProgress.isHidden = true
        }
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let track = tracks[indexPath.row]
        let fileName = track.url.lastPathComponent
        let isDownloaded = FileManager.localFileExists(with: fileName)
        if isDownloaded {
            let localTrack = FileManager.localFilePath(for: track.url)
            debugPrint("Play downloaded track at: \(localTrack)")
            playTrack(track)
        }
    }
    
    private func playTrack(_ track: Track) {
        let localTrackUrl = FileManager.localFilePath(for: track.url)
        let controller = PlayTrackViewController()
        present(controller, animated: true, completion: nil)
        let player = AVPlayer(url: localTrackUrl)
        controller.player = player
        controller.artworkUrl = track.artworkUrl
        player.play()
    }
}

extension SearchViewController: TrackCellDelegate {
    
    func dowloadButtonClicked(cellPosition: Int) {
        guard tracks.indices.contains(cellPosition) else {
            return
        }
        let indexPath = IndexPath(row: cellPosition, section: 0)
        let track = tracks[cellPosition]
        debugPrint("Downloading track by URL: \(track.previewUrl)")
        activeDownloads[track.url] = 0.0
        tracksTableView.reloadRows(at: [indexPath], with: .none)
        downloadManager.download(track: track)
    }
}

extension SearchViewController: DownloadManagerDelegate {
    
    func trackDidDownload(source: URL, localPath: URL) {
        if let index = getTrackIndex(with: source) {
            let pathToUpdate = IndexPath(row: index, section: 0)
            activeDownloads.removeValue(forKey: source)
            tracksTableView.reloadRows(at: [pathToUpdate], with: .none)
        }
    }
    
    func downloadingProgress(for url: URL, progress: Float) {
        if let index = getTrackIndex(with: url) {
            let pathToUpdate = IndexPath(row: index, section: 0)
            tracksTableView.reloadRows(at: [pathToUpdate], with: .none)
            activeDownloads[url] = progress
        }
    }
    
    private func getTrackIndex(with url: URL) -> Int? {
        let element = tracks.enumerated().first { $0.element.url == url }
        return element?.offset
    }
}
