
import UIKit
import AVKit

class PlayTrackViewController: AVPlayerViewController {

    var artworkUrl: String? = nil
    
    @IBOutlet weak var artworkImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let artworkUrl = artworkUrl {
            artworkImage.load(url: artworkUrl)
        }
    }
}
