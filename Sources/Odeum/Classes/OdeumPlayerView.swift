//
//  OdeumPlayerView.swift
//  Odeum
//
//  Created by Nayanda Haberty on 23/01/21.
//

import Foundation
#if canImport(UIKit)
import UIKit
import AVFoundation
import AVKit

// MARK: OdeumPlayerView

public class OdeumPlayerView: UIView {
    
    // MARK: View
    
    public internal(set) lazy var progressBar: UISlider = {
        let bar = UISlider()
        bar.thumbTintColor = .white
        bar.minimumTrackTintColor = .red
        bar.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.5)
        bar.maximumValue = 1
        bar.minimumValue = 0
        bar.setThumbImage(makeCircle(), for: .normal)
        bar.setThumbImage(makeCircle(withSize: .init(width: 16, height: 16)), for: .highlighted)
        bar.addTarget(self, action: #selector(slided(_:)), for: .valueChanged)
        bar.addTarget(self, action: #selector(didSlide(_:)), for: .touchUpInside)
        bar.addTarget(self, action: #selector(didSlide(_:)), for: .touchUpOutside)
        return bar
    }()
    public internal(set) lazy var placeholderView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    public internal(set) lazy var videoViewHolder: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    public internal(set) lazy var playerControl: PlayControlView = {
        let control = PlayControlView()
        control.delegate = self
        return control
    }()
    public internal(set) lazy var spinner: UIActivityIndicatorView = .init(style: .white)
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    // MARK: State
    public var videoIsFinished: Bool {
        guard let duration = player.currentItem?.duration else { return false }
        return player.currentTime() >= duration
    }
    public var isBuffering: Bool {
        spinner.alpha < 1
    }
    public var audioState: AudioState {
        playerControl.audioState
    }
    public var replayStep: ReplayStep {
        get {
            playerControl.replayStep
        } set {
            playerControl.replayStep = newValue
        }
    }
    public var playState: PlayState {
        playerControl.playState
    }
    public var forwardStep: ForwardStep {
        get {
            playerControl.forwardStep
        } set {
            playerControl.forwardStep = newValue
        }
    }
    public var fullScreenState: FullScreenState {
        playerControl.fullScreenState
    }
    public var videoItem: AVPlayerItem? {
        player.currentItem
    }
    public internal(set) var controlAppearance: ControlAppearanceState = .hidden
    
    // MARK: Delegate
    
    public weak var delegate: OdeumPlayerViewDelegate?
    
    // MARK: Player
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 1000),
            queue: .main) { [weak self] time in
                self?.timeTracked(time)
            }
        player.actionAtItemEnd = .pause
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        return player
    }()
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        return layer
    }()
    
    // MARK: Inspectable Properties
    @IBInspectable
    public var videoControlShownDuration: NSNumber = 3
    
    @IBInspectable
    public var placeholderImage: UIImage? = nil {
        didSet {
            placeholderView.image = placeholderImage
        }
    }
    
    // MARK: Properties
    public internal(set) var url: URL?
    var previousTimeStatus: AVPlayer.TimeControlStatus?
    var hideWorker: DispatchWorkItem?
    weak var fullScreenViewController: UIViewController?
    var manuallySeek: Bool = false
    var videoControlShownTimeInterval: TimeInterval { .init(truncating: videoControlShownDuration) }
    
    // MARK: Initializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        buildView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = videoViewHolder.bounds
        videoViewHolder.layer.addSublayer(playerLayer)
        playerControl.layer.cornerRadius = playerControl.bounds.height / 2
        playerControl.clipsToBounds = true
    }
    
    // MARK: View Arrangement and Animating
    
    func buildView() {
        makeControlTransparent()
        insertSubviewsInPlace()
        activatePlaceholderViewConstraints()
        activateVideoViewHolderConstraints()
        activatePlayerControlConstraints()
        activateProgressBarConstraints()
        activateSpinnerConstraints()
    }
    
    func insertSubviewsInPlace() {
        addSubview(placeholderView)
        addSubview(videoViewHolder)
        addSubview(spinner)
        addSubview(progressBar)
        addSubview(playerControl)
    }
    
    func makeControlTransparent() {
        playerControl.alpha = 0
        progressBar.alpha = 0
        spinner.alpha = 0
    }
    
    func activatePlaceholderViewConstraints() {
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: topAnchor),
            placeholderView.leftAnchor.constraint(equalTo: leftAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            placeholderView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func activateVideoViewHolderConstraints() {
        videoViewHolder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoViewHolder.topAnchor.constraint(equalTo: topAnchor),
            videoViewHolder.leftAnchor.constraint(equalTo: leftAnchor),
            videoViewHolder.bottomAnchor.constraint(equalTo: bottomAnchor),
            videoViewHolder.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func activatePlayerControlConstraints() {
        playerControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            playerControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerControl.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            playerControl.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 16),
            playerControl.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
            playerControl.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -16),
            playerControl.heightAnchor.constraint(lessThanOrEqualToConstant: 48),
            playerControl.widthAnchor.constraint(lessThanOrEqualToConstant: 240),
            playerControl.widthAnchor.constraint(equalTo: playerControl.heightAnchor, multiplier: 5)
        ])
    }
    
    func activateProgressBarConstraints() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            progressBar.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        ])
    }
    
    func activateSpinnerConstraints() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            spinner.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 16),
            spinner.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
            spinner.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -16)
        ])
    }
    
    func showSpinner() {
        self.spinner.startAnimating()
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.spinner.alpha = 1
            },
            completion: nil
        )
    }
    
    func hideSpinner() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.spinner.alpha = 0
                self.placeholderView.alpha = 0
            },
            completion: { _ in
                self.spinner.stopAnimating()
            }
        )
    }
    
    func showControl() {
        controlAppearance = .goingToShow
        UIView.animate(
            withDuration: 0.45,
            delay: .zero,
            options: .curveEaseInOut) { [weak progressBar, weak playerControl] in
                progressBar?.alpha = 1
                playerControl?.alpha = 1
            } completion: { [weak self] complete in
                guard complete else { return }
                self?.controlAppearance = .shown
            }
    }
    
    func hideControl() {
        controlAppearance = .goingToHide
        UIView.animate(
            withDuration: 0.45,
            delay: .zero,
            options: .curveEaseInOut) { [weak progressBar, weak playerControl] in
                progressBar?.alpha = .zero
                playerControl?.alpha = .zero
            } completion: { [weak self] complete in
                guard complete else { return }
                self?.controlAppearance = .hidden
            }
    }
    
}

public extension OdeumPlayerView {
    
    enum ControlAppearanceState: Equatable {
        case shown
        case goingToShow
        case goingToHide
        case hidden
    }
}
#endif
