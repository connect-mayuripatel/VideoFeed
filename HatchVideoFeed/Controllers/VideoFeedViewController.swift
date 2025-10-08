//
//  VideoFeedViewController.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-07.
//

import UIKit
import AVFoundation

class VideoFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private var videos: [VideoItem] = []
    private var infiniteVideos: [VideoItem] = []
    private var currentIndex: IndexPath = IndexPath(item: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
        fetchVideos()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = view.bounds.size

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        view.addSubview(collectionView)
    }

    private func fetchVideos() {
        ManifestFetcher.shared.fetchManifest { [weak self] items in
            guard let self = self else { return }
            self.videos = items
            DispatchQueue.main.async {
                self.setupInfiniteVideos()
            }
        }
    }

    // MARK: - Infinite Scroll
    private func setupInfiniteVideos() {
        guard !videos.isEmpty else { return }

        infiniteVideos = []
        infiniteVideos.append(videos.last!)
        infiniteVideos.append(contentsOf: videos)
        infiniteVideos.append(videos.first!)

        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        let firstRealIndex = 1
        collectionView.contentOffset = CGPoint(x: 0, y: collectionView.bounds.height * CGFloat(firstRealIndex))
        currentIndex = IndexPath(item: firstRealIndex, section: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playCurrentVideo()
        }
    }

    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infiniteVideos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        cell.configure(with: infiniteVideos[indexPath.item].url)
        cell.layoutIfNeeded() // Ensures layer ready
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item != currentIndex.item {
            let url = infiniteVideos[indexPath.item].url
            VideoPlayerManager.shared.releasePlayer(for: url)
        }
    }

    // MARK: - Scroll Snapping with Velocity
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageHeight = scrollView.bounds.height
        var currentPage = scrollView.contentOffset.y / pageHeight

        if velocity.y > 0.2 {
            currentPage = ceil(currentPage)
        } else if velocity.y < -0.2 {
            currentPage = floor(currentPage)
        } else {
            currentPage = round(currentPage)
        }

        let newOffset = CGPoint(x: 0, y: currentPage * pageHeight)
        scrollView.setContentOffset(newOffset, animated: true)
        targetContentOffset.pointee.y = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustInfiniteScrollIfNeeded()
        playCurrentVideo()
        prefetchVideos(around: currentIndex.item)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        playCurrentVideo()
    }

    private func updateCurrentIndex() {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            currentIndex = indexPath
        }
    }

    private func adjustInfiniteScrollIfNeeded() {
        guard let visibleIndex = collectionView.indexPathsForVisibleItems.min(by: { $0.item < $1.item }) else { return }
        currentIndex = visibleIndex

        if visibleIndex.item == 0 {
            currentIndex = IndexPath(item: videos.count, section: 0)
            collectionView.contentOffset = CGPoint(x: 0, y: collectionView.bounds.height * CGFloat(videos.count))
        } else if visibleIndex.item == infiniteVideos.count - 1 {
            currentIndex = IndexPath(item: 1, section: 0)
            collectionView.contentOffset = CGPoint(x: 0, y: collectionView.bounds.height)
        }
    }

    // MARK: - Video Playback
    private func playCurrentVideo() {
        updateCurrentIndex()
        
        guard let cell = collectionView.cellForItem(at: currentIndex) as? VideoCell else {
            // Retry if cell is not ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.playCurrentVideo()
            }
            return
        }

        // Pause all other videos
        pauseAllExcept(index: currentIndex)

        // Play current video
        cell.play { }
    }
    
    private func pauseAllExcept(index: IndexPath) {
        for visibleCell in collectionView.visibleCells {
            if let videoCell = visibleCell as? VideoCell,
               collectionView.indexPath(for: videoCell) != index {
                videoCell.pause()
            }
        }
    }

    private func pauseCurrentVideo() {
        guard let cell = collectionView.cellForItem(at: currentIndex) as? VideoCell else { return }
        cell.pause()
    }

    // MARK: - Prefetch
    private func prefetchVideos(around index: Int) {
        let buffer = NetworkMonitor.shared.isFastNetwork ? 5.0 : 2.0
        let indices = [index - 1, index + 1]

        for i in indices {
            guard i >= 0 && i < infiniteVideos.count else { continue }
            let url = infiniteVideos[i].url
            let player = VideoPlayerManager.shared.player(for: url)
            player.currentItem?.preferredForwardBufferDuration = buffer

            if player.timeControlStatus != .playing {
                player.play()
                player.pause()
            }
        }
    }
}
