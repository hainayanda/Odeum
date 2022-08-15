//
//  OdeumPlayerView+Actions.swift
//  Odeum
//
//  Created by Nayanda Haberty on 25/01/21.
//

import Foundation
#if canImport(UIKit)
import UIKit
import AVFoundation
import AVKit

extension OdeumPlayerView {
    
    @objc func slided(_ sender: Any?) {
        hideWorker?.cancel()
        player.pause()
        seek(to: progressBar.value)
    }
    
    @objc func didSlide(_ sender: Any?) {
        seek(to: progressBar.value)
        player.play()
        didTap(sender)
    }
    
    @objc func didTap(_ sender: Any?) {
        guard !isTappingControl(for: sender), !(sender is UISlider) else {
            animateShowControlIfNeeded()
            delayAutoHide()
            return
        }
        guard let delegate = self.delegate else {
            defaultTapAction()
            return
        }
        if delegate.odeum(self, shouldShowOnTapWhen: controlAppearance) {
            animateShowControlIfNeeded()
            delayAutoHide()
        } else if delegate.odeum(self, shouLdHideOnTapWhen: controlAppearance) {
            animateHideControlIfNeeded()
            disableAutoHide()
        }
    }
    
    func isTappingControl(for sender: Any?) -> Bool {
        switch controlAppearance {
        case .hidden:
            return false
        default:
            guard let gesture = sender as? UITapGestureRecognizer else {
                return sender is PlayControlView
            }
            return playerControl.bounds.contains(gesture.location(in: playerControl))
        }
    }
    
    func defaultTapAction() {
        switch controlAppearance {
        case .shown, .goingToShow:
            animateHideControlIfNeeded()
            disableAutoHide()
        case .hidden, .goingToHide:
            animateShowControlIfNeeded()
            delayAutoHide()
        }
    }
    
    func delayAutoHide() {
        disableAutoHide()
        enableAutoHide(after: videoControlShownTimeInterval)
    }
    
    func disableAutoHide() {
        hideWorker?.cancel()
        hideWorker = nil
    }
    
    func enableAutoHide(after timeInterval: TimeInterval) {
        let newWorker = DispatchWorkItem { [weak self] in
            self?.animateHideControlIfNeeded()
            self?.hideWorker = nil
        }
        hideWorker = newWorker
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: newWorker)
    }
    
    func animateShowControlIfNeeded() {
        switch controlAppearance {
        case .hidden, .goingToHide:
            showControl()
        default:
            break
        }
    }
    
    func animateHideControlIfNeeded() {
        switch controlAppearance {
        case .shown, .goingToShow:
            hideControl()
        default:
            break
        }
    }
    
    func seek(to progress: Float) {
        guard let duration = player.currentItem?.duration.seconds else { return }
        let time = duration * Double(progressBar.value)
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(to: cmTime)
        manuallySeek = true
    }
    
    func timeTracked(_ time: CMTime) {
        guard !progressBar.isHighlighted,
              let duration = player.currentItem?.duration,
                !manuallySeek else {
            manuallySeek = false
            return
        }
        let progress = min(max(time.seconds / duration.seconds, 0), 1)
        progressBar.value = Float(progress)
        delegate?.odeum(self, progressingBy: progress)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = object as? AVPlayer,
              player == self.player,
              keyPath == "timeControlStatus",
              player.timeControlStatus != previousTimeStatus else { return }
        defer {
            previousTimeStatus = player.timeControlStatus
        }
        if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            showSpinner()
            delegate?.odeumDidBuffering(self)
        } else if player.timeControlStatus == .playing {
            playerControl.playState = .played
            if previousTimeStatus == .waitingToPlayAtSpecifiedRate {
                hideSpinner()
                delegate?.odeumDidFinishedBuffering(self)
            }
            delegate?.odeumDidPlayVideo(self)
        } else {
            playerControl.playState = .paused
            delegate?.odeumDidPauseVideo(self)
        }
    }
}
#endif
