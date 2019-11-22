
import UIKit

protocol TrackCellDelegate: NSObjectProtocol {
    func dowloadButtonClicked(cellPosition: Int)
}

class TrackCell: UITableViewCell {

    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!

    weak var delegate: TrackCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artwork.image = nil
        artistLabel.text = ""
        songTitleLabel.text = ""
        downloadProgress.isHidden = true
        delegate = nil
    }
      
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(for track: Track, position: Int, isDownloaded: Bool, delegate: TrackCellDelegate? = nil) {
        tag = position
        self.delegate = delegate
        artwork.load(url: track.artworkUrl)
        artistLabel.text = track.artistName
        songTitleLabel.text = track.trackName
        downloadButton.isHidden = isDownloaded
    }

    @objc func handleTap(_ sender: Any) {
        delegate?.dowloadButtonClicked(cellPosition: tag)
    }
}
