
import Foundation

typealias QueryResult = ([Track]?, String) -> ()

class QueryService {

    private let baseUrlComponents = URLComponents(string: "https://itunes.apple.com/search")
    private let query = "media=music&entity=song&term="
   
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        return URLSession(configuration: config)
    }()
    private var dataTask: URLSessionDataTask? = nil
    private let decoder = JSONDecoder()
    
    func searchForSong(by name: String, completion: @escaping QueryResult) {
        discardPreviousQuery()
        guard let url = getUrlByTerm(term: name) else {
            print("Couln't build URL for term: \(name)")
            return
        }
        dataTask = urlSession.dataTask(with: url) { data, response, error in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data else {
                return
            }
            DispatchQueue.main.async {
                completion(self.decodeTracks(from: data), "")
            }
        }
        dataTask?.resume()
    }
    
    func discardPreviousQuery() {
        dataTask?.cancel()
    }
    
    private func getUrlByTerm(term: String) -> URL? {
        var urlComponents = baseUrlComponents
        urlComponents?.query = query + term
        return urlComponents?.url
    }
    
    private func decodeTracks(from data: Data) -> [Track] {
        var tracks = [Track]()
        do {
            let trackList = try decoder.decode(TrackList.self, from: data)
            tracks = trackList.results
        } catch let decodeError as NSError {
            print("Could not decode track list data: \(decodeError.localizedDescription)")
        }
        return tracks
    }
}
