//
//  OdeumPlayerView+Player.swift
//  Odeum
//
//  Created by Nayanda Haberty on 24/01/21.
//

import Foundation
import AVFoundation
import AVKit

extension OdeumPlayerView {
    
    public func set(url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
    }
    
    public func play() {
        player.play()
        playerControl.playState = .played
    }
    
    public func play(url: URL) {
        set(url: url)
        play()
    }
    
    public func pause() {
        player.pause()
        playerControl.playState = .paused
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
        
    }
    
    public func dismissFullScreen() {
        
    }
}
