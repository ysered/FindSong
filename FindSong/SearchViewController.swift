
import UIKit

class SearchViewController: UIViewController {

    private let queryService = QueryService()
    private let downloadManager = DownloadManager.shared
    
    private var tracks = [Track]()
    
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
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let track = tracks[indexPath.row]
        let fileName = track.url.lastPathComponent
        let isDownloaded = FileManager.localFileExists(with: fileName)
        if isDownloaded {
            debugPrint("Play downloaded track at: \(FileManager.localFilePath(for: track.url))")
        }
    }
}

extension SearchViewController: TrackCellDelegate {
    
    func dowloadButtonClicked(cellPosition: Int) {
        guard tracks.indices.contains(cellPosition) else {
            return
        }
        let track = tracks[cellPosition]
        debugPrint("Downloading track by URL: \(track.previewUrl)")
        downloadManager.download(track: track)
    }
}

extension SearchViewController: DownloadManagerDelegate {
    
    func trackDidDownload(source: URL, localPath: URL) {
        if let index = getTrackIndex(with: source) {
            let pathToUpdate = IndexPath(row: index, section: 0)
            tracksTableView.reloadRows(at: [pathToUpdate], with: .none)
        }
    }
    
    func getTrackIndex(with url: URL) -> Int? {
        let element = tracks.enumerated().first { $0.element.url == url }
        return element?.offset
    }
}
