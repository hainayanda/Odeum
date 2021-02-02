//
//  OdeumPlayerView+Player.swift
//  Odeum
//
//  Created by Nayanda Haberty on 24/01/21.
//

import Foundation
#if canImport(UIKit)
import AVFoundation
import AVKit

extension OdeumPlayerView {
    
    public func set(url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        self.url = url
    }
    
    public func play() {
        if videoIsFinished {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1000))
        }
        player.play()
    }
    
    public func play(url: URL) {
        set(url: url)
        play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func set(mute: Bool) {
        guard player.isMuted != mute else { return }
        player.isMuted = mute
        if mute {
            playerControl.audioState = .mute
            delegate?.odeumDidMuted(self)
        } else {
            playerControl.audioState = .unmute
            delegate?.odeumDidUnmuted(self)
        }
    }
    
    @discardableResult
    public func forward(by second: TimeInterval) -> Bool {
        guard let duration = player.currentItem?.duration else { return false }
        let forwardedTime = player.currentTime() + CMTime(seconds: second, preferredTimescale: 1000)
        let nextTime = min(duration, forwardedTime)
        player.seek(to: nextTime)
        delegate?.odeum(self, forwardedBy: TimeInterval(nextTime.seconds))
        return true
    }
    
    @discardableResult
    public func replay(by second: TimeInterval) -> Bool {
        guard let _ = player.currentItem else { return false }
        let replayTime = player.currentTime() - CMTime(seconds: second, preferredTimescale: 1000)
        let previousTime: CMTime = max(CMTime(seconds: 0, preferredTimescale: 1000), replayTime)
        player.seek(to: previousTime)
        delegate?.odeum(self, forwardedBy: TimeInterval(previousTime.seconds))
        return true
    }
    
    public func goFullScreen() {
        defer {
            pause()
        }
        let fullScreenController = AVPlayerViewController()
        let item = self.player.currentItem?.copy() as? AVPlayerItem
        let player = AVPlayer(playerItem: item)
        fullScreenController.player = player
        fullScreenController.delegate = self
        guard let viewController = delegate?.odeumViewControllerToPresentFullScreen(self) ?? self.viewController else {
            fatalError()
        }
        fullScreenViewController = fullScreenController
        viewController.present(fullScreenController, animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.odeumDidGoToFullScreen(self)
        }
    }
    
    public func dismissFullScreen() {
        fullScreenViewController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.odeumDidDismissFullScreen(self)
        }
    }
    
    public func removeVideo() {
        pause()
        player.replaceCurrentItem(with: nil)
        self.url = nil
    }
}

extension OdeumPlayerView: AVPlayerViewControllerDelegate {
    public func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let playTime = self.player.currentTime()
        playerViewController.player?.isMuted = audioState == .mute
        playerViewController.player?.seek(to: playTime)
        playerViewController.player?.play()
    }
    
    public func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        defer {
            self.playerControl.fullScreenState = .minimize
            self.delegate?.odeumDidDismissFullScreen(self)
            self.play()
        }
        guard let controllerPlayer = playerViewController.player else {
            return
        }
        playerControl.audioState = controllerPlayer.isMuted ? .mute : .unmute
        player.isMuted = controllerPlayer.isMuted
        player.seek(to: controllerPlayer.currentTime())
    }
}
#endif
