
import UIKit

// MARK: - UIImageView Extensions

extension UIImageView {
    func load(url: String) {
        let imageUrl = URL(string: url)!
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: imageUrl), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
