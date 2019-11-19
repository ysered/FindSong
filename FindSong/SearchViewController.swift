
import UIKit

class SearchViewController: UIViewController {

    private lazy var queryService = { QueryService() }()
    
    @IBOutlet weak var searchSongBar: UISearchBar!
    @IBOutlet weak var songsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSongBar.delegate = self
        songsTableView.delegate = self
        activityIndicator.hidesWhenStopped = true
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        print("Searching for text: \(searchText)")
        activityIndicator.startAnimating()
        queryService.searchForSong(by: searchText, completion: { tracks, error in
            self.activityIndicator.stopAnimating()
            if let tracks = tracks {
                let songNames = tracks.map { $0.trackName }
                print("Found songs: \(songNames)")
            } else {
                print("Error occured: \(error)")
            }
        })
    }
       
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        queryService.discardPreviousQuery()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("Bookmark button clicked!")
    }
}

extension SearchViewController: UITableViewDelegate {
    
}
