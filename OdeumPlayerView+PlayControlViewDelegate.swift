//
//  OdeumPlayerView+PlayControlViewDelegate.swift
//  Odeum
//
//  Created by Nayanda Haberty on 24/01/21.
//

import Foundation

extension OdeumPlayerView: PlayControlViewDelegate {
    public func playControl(_ view: PlayControlView, audioDidChangeStateTo state: AudioState) {
        set(mute: state == .mute)
    }
    
    public func playControl(_ view: PlayControlView, playDidChangeStateTo state: PlayState) {
        switch state {
        case .played:
            play()
        case .paused:
            pause()
        }
    }
    
    public func playControl(_ view: PlayControlView, fullScreenDidChangeStateTo state: FullScreenState) {
        switch state {
        case .fullScreen:
            goFullScreen()
        case .minimize:
            dismissFullScreen()
        }
    }
    
    public func playControl(_ view: PlayControlView, didTapForward step: ForwardStep) {
        forward(by: step.timeInterval)
    }
    
    public func playControl(_ view: PlayControlView, didTapReplay step: ReplayStep) {
        replay(by: step.timeInterval)
    }
}
