
import UIKit

class SearchViewController: UIViewController {

    private lazy var queryService = { QueryService() }()
    
    private var tracks = [Track]()
    
    @IBOutlet weak var searchSongBar: UISearchBar!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSongBar.delegate = self
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
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
        cell.configure(for: track, position: indexPath.row, delegate: self)
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension SearchViewController: TrackCellDelegate {
    
    func dowloadButtonClicked(cellPosition: Int) {
        guard tracks.indices.contains(cellPosition) else {
            return
        }
        let track = tracks[cellPosition]
        print("Downloading track by URL: \(track.previewUrl)")
    }
}
