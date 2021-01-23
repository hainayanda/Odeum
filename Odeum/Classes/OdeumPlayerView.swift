//
//  OdeumPlayerView.swift
//  Odeum
//
//  Created by Nayanda Haberty on 23/01/21.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

// MARK: Delegate

public protocol OdeumPlayerViewDelegate: class {
    func odeumDidPlayVideo(_ player: OdeumPlayerView)
    func odeumDidPauseVideo(_ player: OdeumPlayerView)
    func odeumDidGoToFullScreen(_ player: OdeumPlayerView)
    func odeumDidDismissFullScreen(_ player: OdeumPlayerView)
    func odeumDidMuted(_ player: OdeumPlayerView)
    func odeumDidUnmuted(_ player: OdeumPlayerView)
    func odeum(_ player: OdeumPlayerView, forwardedBy interval: TimeInterval)
    func odeum(_ player: OdeumPlayerView, rewindedBy interval: TimeInterval)
    func odeumDidBuffering(_ player: OdeumPlayerView)
    func odeumDidFinishedBuffering(_ player: OdeumPlayerView)
    func odeum(_ player: OdeumPlayerView, progressingBy percent: Double)
}

public extension OdeumPlayerViewDelegate {
    func odeumDidPlayVideo(_ player: OdeumPlayerView) { }
    func odeumDidPauseVideo(_ player: OdeumPlayerView) { }
    func odeumDidGoToFullScreen(_ player: OdeumPlayerView) { }
    func odeumDidDismissFullScreen(_ player: OdeumPlayerView) { }
    func odeumDidMuted(_ player: OdeumPlayerView) { }
    func odeumDidUnmuted(_ player: OdeumPlayerView) { }
    func odeum(_ player: OdeumPlayerView, forwardedBy interval: TimeInterval) { }
    func odeum(_ player: OdeumPlayerView, rewindedBy interval: TimeInterval) { }
    func odeumDidBuffering(_ player: OdeumPlayerView) { }
    func odeumDidFinishedBuffering(_ player: OdeumPlayerView) { }
    func odeum(_ player: OdeumPlayerView, progressingBy percent: Double) { }
}

// MARK: OdeumPlayerView

public class OdeumPlayerView: UIView {
    // MARK: View
    
    public internal(set) lazy var progressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.progressTintColor = .red
        bar.trackTintColor = UIColor.white.withAlphaComponent(0.5)
        return bar
    }()
    public internal(set) lazy var videoViewHolder: UIView = .init()
    // 256 * 64 or 4 : 1
    public internal(set) lazy var playerControl: PlayControlView = .init()
    public internal(set) lazy var spinner: UIActivityIndicatorView = .init(activityIndicatorStyle: .whiteLarge)
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        gesture.cancelsTouchesInView = false
        videoViewHolder.addGestureRecognizer(gesture)
        return gesture
    }()
    // MARK: State
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
        observationToken = player.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] player, changes in
            guard changes.newValue != changes.oldValue else { return }
            self?.timeControl(changes.newValue, changeFrom: changes.oldValue)
        }
        return player
    }()
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        return layer
    }()
    
    // MARK: Properties
    
    public var videoControlShownDuration: TimeInterval = 3
    
    var observationToken: NSObjectProtocol?
    var hideWorker: DispatchWorkItem?
    
    // MARK: Initializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = videoViewHolder.bounds
        videoViewHolder.layer.addSublayer(playerLayer)
    }
    
    // MARK: View Arrangement and Animating
    
    func setupConstraints() {
        
    }
    
    func showSpinner() {
        
    }
    
    func hideSpinner() {
        
    }
    
    func showControl() {
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.progressBar.alpha = 1
                self.playerControl.alpha = 1
            },
            completion: nil
        )
    }
    
    func hideControl() {
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.progressBar.alpha = 0
                self.playerControl.alpha = 0
            },
            completion: nil
        )
    }
    
    // MARK: Actions
    
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        showControl()
        hideWorker?.cancel()
        let newWorker = DispatchWorkItem { [weak self] in
            self?.hideControl()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + videoControlShownDuration, execute: newWorker)
    }
    
    func timeTracked(_ time: CMTime) {
        guard let duration = player.currentItem?.duration else { return }
        let progress = min(max(time.seconds / duration.seconds, 0), 1)
        progressBar.progress = Float(progress)
        delegate?.odeum(self, progressingBy: progress)
    }
    
    func timeControl(_ status: AVPlayerTimeControlStatus?, changeFrom previousStatus: AVPlayerTimeControlStatus?) {
        if status == .waitingToPlayAtSpecifiedRate {
            showSpinner()
            delegate?.odeumDidBuffering(self)
        } else if status == .playing {
            if previousStatus == .waitingToPlayAtSpecifiedRate {
                hideSpinner()
                delegate?.odeumDidFinishedBuffering(self)
            }
            delegate?.odeumDidPlayVideo(self)
        } else {
            delegate?.odeumDidPauseVideo(self)
        }
    }

}
