import Foundation
import ImageIO
import UIKit

private func downsampleImage(data: Data, maxPixelSize: CGFloat) -> UIImage? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
        return nil
    }

    let thumbnailOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
    ] as CFDictionary

    guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
        return nil
    }
    return UIImage(cgImage: image)
}

@MainActor
private final class ThumbnailCache {
    static let shared = ThumbnailCache()

    private let storage = NSCache<NSString, UIImage>()

    private init() {
        storage.totalCostLimit = 64 * 1_024 * 1_024
    }

    func key(for url: URL, maxPixelSize: CGFloat) -> NSString {
        "\(url.absoluteString)#\(Int(maxPixelSize.rounded(.up)))" as NSString
    }

    func image(for key: NSString) -> UIImage? {
        storage.object(forKey: key)
    }

    func insert(_ image: UIImage, for key: NSString) {
        let decodedCost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        storage.setObject(image, forKey: key, cost: decodedCost)
    }
}

@MainActor
final class ThumbnailCell: UICollectionViewCell {
    static let reuseIdentifier = "ThumbnailCell"

    private let thumbnailView = UIImageView()
    private var representedURL: URL?
    private var loadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        contentView.addSubview(thumbnailView)
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(url: URL, targetSize: CGSize, scale: CGFloat) {
        loadTask?.cancel()
        representedURL = url
        thumbnailView.image = nil

        let maxPixelSize = max(targetSize.width, targetSize.height) * scale
        let cacheKey = ThumbnailCache.shared.key(for: url, maxPixelSize: maxPixelSize)
        if let cachedImage = ThumbnailCache.shared.image(for: cacheKey) {
            thumbnailView.image = cachedImage
            loadTask = nil
            return
        }

        loadTask = Task { [weak self] in
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode),
                      !Task.isCancelled else { return }

                let image = await Task.detached(priority: .utility) {
                    downsampleImage(data: data, maxPixelSize: maxPixelSize)
                }.value

                guard let image,
                      !Task.isCancelled,
                      self?.representedURL == url else { return }
                ThumbnailCache.shared.insert(image, for: cacheKey)
                self?.thumbnailView.image = image
            } catch is CancellationError {
                return
            } catch {
                guard self?.representedURL == url else { return }
                self?.thumbnailView.image = nil
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        representedURL = nil
        thumbnailView.image = nil
    }
}

@MainActor
final class GalleryViewController: UIViewController, UICollectionViewDataSource {
    private let imageURLs: [URL]
    private let collectionView: UICollectionView

    init(imageURLs: [URL]) {
        self.imageURLs = imageURLs
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.reuseIdentifier)
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ThumbnailCell.reuseIdentifier,
            for: indexPath
        ) as? ThumbnailCell else {
            return UICollectionViewCell()
        }

        cell.configure(
            url: imageURLs[indexPath.item],
            targetSize: CGSize(width: 120, height: 120),
            scale: view.window?.screen.scale ?? UIScreen.main.scale
        )
        return cell
    }
}
