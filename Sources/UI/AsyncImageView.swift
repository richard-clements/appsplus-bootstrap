#if canImport(UIKit) && canImport(Combine)

import UIKit
import Combine

@available(iOS 13.0, tvOS 13.0, *)
public struct AsyncImage: Equatable {
    public let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

@available(iOS 13.0, tvOS 13.0, *)
public class AsyncImageView: UIView {
    
    private struct AssetImage {
        let image: UIImage
        let isCached: Bool
    }
    
    public enum CornerRadius {
        case value(CGFloat)
        case percentage(CGFloat)
    }
    
    public enum State {
        case idle
        case loading
        case success
        case failed
    }
    
    /**
     Setting this to true will show the loading animation
     when an image is being fetched to display.
     Defaults to `false`
     */
    public var shouldShowLoadingAnimation = false
    public var image: AsyncImage? {
        didSet {
            if oldValue != image {
                fetchImage()
            }
        }
    }
    public var cornerRadius: CornerRadius = .value(0)
    
    @Published public private(set) var state = State.idle
    
    private var cancellables = Set<AnyCancellable>()
    private var imageCancellable: AnyCancellable?
    private let imageView = UIImageView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let resizeQueue = DispatchQueue(label: Bundle.main.bundleIdentifier ?? "" + ".graphics.resize")
    public var shouldAutoResize = true
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentMode = .scaleAspectFill
        setUp(imageView: imageView)
        setUp(activityIndicatorView: activityIndicatorView)
        addSubview(imageView)
        addSubview(activityIndicatorView)
        setUpConstraints()
        bindState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindState() {
        $state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch $0 {
                case .loading:
                    showLoadingAnimation()
                default:
                    hideLoadingAnimation()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUp(imageView: UIImageView) {
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = contentMode
    }
    
    private func setUp(activityIndicatorView: UIActivityIndicatorView) {
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpConstraints() {
        imageView.pinConstraints(to: self)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    /**
     Should only be called by the instance itself and never by another object. Setting a new url will call this function indirectly.
     */
    func fetchImage() {
        cancel()
        guard let image = image else {
            return
        }
        state = .loading
        imageCancellable = imagePublisher(for: image.url)
            .flatMap { [unowned self] in
                self.resizeImage($0)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    state = .success
                case .failure:
                    state = .failed
                }
            }, receiveValue: { [unowned self] result in
                imageView.image = result.image
                if result.isCached {
                    imageView.alpha = 1
                } else {
                    UIView.animate(withDuration: 0.3) {
                        imageView.alpha = 1
                    }
                }
            })
    }
    
    public func retry() {
        fetchImage()
    }
    
    private func imagePublisher(for url: URL) -> AnyPublisher<AssetImage, URLError> {
        if let cachedResult = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResult.data) {
            return Just(AssetImage(image: image, isCached: true))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, _ in
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeRawData)
                }
                return AssetImage(image: image, isCached: false)
            }
            .mapError { $0 as? URLError ?? URLError(.badServerResponse) }
            .eraseToAnyPublisher()
    }
    
    private func cancel() {
        imageCancellable = nil
        imageView.image = nil
        imageView.alpha = 0
        state = .idle
    }
    
    private func showLoadingAnimation() {
        guard shouldShowLoadingAnimation, !activityIndicatorView.isAnimating else { return }
        activityIndicatorView.startAnimating()
    }
    
    private func hideLoadingAnimation() {
        activityIndicatorView.stopAnimating()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        switch cornerRadius {
        case .value(let value):
            layer.cornerRadius = value
        case .percentage(let percentage):
            layer.cornerRadius = (bounds.height / 2) * percentage
        }
    }
    
    private func resizeImage<ImageError: Error>(_ asset: AssetImage) -> AnyPublisher<AssetImage, ImageError> {
        guard shouldAutoResize else {
            return Just(asset).setFailureType(to: ImageError.self).eraseToAnyPublisher()
        }
        return Future { [weak self] completion in
            DispatchQueue.main.async {
                guard let self = self else {
                    completion(.success(asset))
                    return
                }
                let size = self.bounds.size
                let image = asset.image
                if image.size.width <= size.width && image.size.height <= size.height {
                    completion(.success(asset))
                } else {
                    self.resizeQueue.async {
                        let resizedImage = self.redrawImage(image, toFit: size)
                        completion(.success(AssetImage(image: resizedImage, isCached: asset.isCached)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func redrawImage(_ image: UIImage, toFit size: CGSize) -> UIImage {
        guard size.width > 0 && size.height > 0 else {
            return image
        }
        var newSize = image.size
        if newSize.width > size.width {
            let scaleFactor = size.width/newSize.width
            newSize.width = size.width
            newSize.height *= scaleFactor
        }
        if newSize.height > size.height {
            let scaleFactor = size.height/newSize.height
            newSize.height = size.height
            newSize.width *= scaleFactor
        }
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        }
    }
}

#endif
