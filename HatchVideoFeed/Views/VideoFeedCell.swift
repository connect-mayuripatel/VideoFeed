//
//  VideoCollectionViewCell.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-08.
//
import UIKit
import AVFoundation

class VideoCell: UICollectionViewCell {

    static let identifier = "VideoCell"

    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var spinner: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    private var retryButton: UIButton!
    private var retryCount = 0
    private let maxRetries = 3
    private var observedItem: AVPlayerItem?
    private var completion: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupSpinner()
        setupErrorLabel()
        setupRetryButton()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with url: URL) {
        retryCount = 0
        spinner.startAnimating()
        errorLabel.isHidden = true
        retryButton.isHidden = true

        player = VideoPlayerManager.shared.player(for: url)

        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            contentView.layer.insertSublayer(playerLayer!, at: 0)
        }
        playerLayer?.player = player
        playerLayer?.frame = contentView.bounds

        // Remove old observer
        if let oldItem = observedItem {
            oldItem.removeObserver(self, forKeyPath: "status")
            observedItem = nil
        }

        if let currentItem = player?.currentItem {
            currentItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
            observedItem = currentItem
        }
    }

    func play(completion: @escaping () -> Void) {
        self.completion = completion
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    @objc private func retryTapped() {
        guard let url = player?.currentItem?.asset as? AVURLAsset else { return }
        configure(with: url.url)
        play(completion: completion ?? {})
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "status", let item = object as? AVPlayerItem else { return }

        switch item.status {
        case .readyToPlay:
            DispatchQueue.main.async { [weak self] in
                self?.spinner.stopAnimating()
                self?.completion?()
            }
        case .failed:
            handleFailure()
        default: break
        }
    }

    private func handleFailure() {
        retryCount += 1
        if retryCount <= maxRetries {
            player?.seek(to: .zero)
            player?.play()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.spinner.stopAnimating()
                self?.errorLabel.isHidden = false
                self?.retryButton.isHidden = false
            }
        }
    }

    // MARK: - UI
    private func setupSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func setupErrorLabel() {
        errorLabel = UILabel()
        errorLabel.text = "Failed to load video"
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func setupRetryButton() {
        retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.tintColor = .white
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(retryButton)
        NSLayoutConstraint.activate([
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8),
            retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.player = nil
        spinner.stopAnimating()
        errorLabel.isHidden = true
        retryButton.isHidden = true
        retryCount = 0

        if let item = observedItem {
            item.removeObserver(self, forKeyPath: "status")
            observedItem = nil
        }
        completion = nil
    }

    deinit {
        if let item = observedItem {
            item.removeObserver(self, forKeyPath: "status")
        }
    }
}
