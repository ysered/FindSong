
import Foundation

struct Track: Codable {
    var trackName: String
    var artistName: String
    var artworkUrl: String
    var previewUrl: String
    var trackPrice: Double

    enum CodingKeys: String, CodingKey {
        case trackName
        case artistName
        case artworkUrl = "artworkUrl100"
        case previewUrl
        case trackPrice
    }
}

extension Track {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        trackName = try values.decode(String.self, forKey: .trackName)
        artistName = try values.decode(String.self, forKey: .artistName)
        artworkUrl = try values.decode(String.self, forKey: .artworkUrl)
        previewUrl = try values.decode(String.self, forKey: .previewUrl)
        trackPrice = try values.decode(Double.self, forKey: .trackPrice)
    }
}
