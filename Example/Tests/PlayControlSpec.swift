//
//  PlayControlSpec.swift
//  Odeum_Tests
//
//  Created by Nayanda Haberty on 26/01/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Odeum

class PlayControlSpec: QuickSpec {
    override func spec() {
        var controlInTest: PlayControlView!
        beforeEach {
            controlInTest = PlayControlView()
            controlInTest.layoutSubviews()
        }
        it("should add custom icons") {
            let image: UIImage = .init()
            controlInTest.set(icon: image, for: .mute)
            expect(controlInTest.icon(for: .mute)).to(equal(image))
            
            controlInTest.set(icon: image, for: .unmute)
            expect(controlInTest.icon(for: .unmute)).to(equal(image))
            
            controlInTest.set(icon: image, for: ForwardStep.fiveSecond)
            expect(controlInTest.icon(for: ForwardStep.fiveSecond)).to(equal(image))
            
            controlInTest.set(icon: image, for: ForwardStep.tenSecond)
            expect(controlInTest.icon(for: ForwardStep.tenSecond)).to(equal(image))
            
            controlInTest.set(icon: image, for: ForwardStep.thirtySecond)
            expect(controlInTest.icon(for: ForwardStep.thirtySecond)).to(equal(image))
            
            controlInTest.set(icon: image, for: ReplayStep.fiveSecond)
            expect(controlInTest.icon(for: ReplayStep.fiveSecond)).to(equal(image))
            
            controlInTest.set(icon: image, for: ReplayStep.tenSecond)
            expect(controlInTest.icon(for: ReplayStep.tenSecond)).to(equal(image))
            
            controlInTest.set(icon: image, for: ReplayStep.thirtySecond)
            expect(controlInTest.icon(for: ReplayStep.thirtySecond)).to(equal(image))
            
            controlInTest.set(icon: image, for: .played)
            expect(controlInTest.icon(for: .played)).to(equal(image))
            
            controlInTest.set(icon: image, for: .paused)
            expect(controlInTest.icon(for: .paused)).to(equal(image))
            
            controlInTest.set(icon: image, for: .fullScreen)
            expect(controlInTest.icon(for: .fullScreen)).to(equal(image))
            
            controlInTest.set(icon: image, for: .minimize)
            expect(controlInTest.icon(for: .minimize)).to(equal(image))
        }
        it("should delegating button tap") {
            let delegate = DelegateForPlayControlTest()
            controlInTest.delegate = delegate
            
            controlInTest.audioButton.sendActions(for: .touchUpInside)
            expect(delegate.audioState).to(equal(.mute))
            controlInTest.audioButton.sendActions(for: .touchUpInside)
            expect(delegate.audioState).to(equal(.unmute))
            
            controlInTest.playButton.sendActions(for: .touchUpInside)
            expect(delegate.playState).to(equal(.paused))
            controlInTest.playButton.sendActions(for: .touchUpInside)
            expect(delegate.playState).to(equal(.played))
            
            controlInTest.forwardButton.sendActions(for: .touchUpInside)
            expect(delegate.forwardStep).toNot(beNil())
            
            controlInTest.replayButton.sendActions(for: .touchUpInside)
            expect(delegate.replayStep).toNot(beNil())
            
            controlInTest.fullScreenButton.sendActions(for: .touchUpInside)
            expect(delegate.fullScreenState).to(equal(.fullScreen))
            controlInTest.fullScreenButton.sendActions(for: .touchUpInside)
            expect(delegate.fullScreenState).to(equal(.minimize))
        }
        it("should have time right time interval") {
            expect(ForwardStep.fiveSecond.timeInterval).to(equal(5))
            expect(ForwardStep.tenSecond.timeInterval).to(equal(10))
            expect(ForwardStep.thirtySecond.timeInterval).to(equal(30))
            expect(ReplayStep.fiveSecond.timeInterval).to(equal(5))
            expect(ReplayStep.tenSecond.timeInterval).to(equal(10))
            expect(ReplayStep.thirtySecond.timeInterval).to(equal(30))
        }
    }
}

class DelegateForPlayControlTest: PlayControlViewDelegate {
    
    var audioState: AudioState?
    func playControl(_ view: PlayControlView, audioDidChangeStateTo state: AudioState) {
        audioState = state
    }
    var playState: PlayState?
    func playControl(_ view: PlayControlView, playDidChangeStateTo state: PlayState) {
        playState = state
    }
    var fullScreenState: FullScreenState?
    func playControl(_ view: PlayControlView, fullScreenDidChangeStateTo state: FullScreenState) {
        fullScreenState = state
    }
    var forwardStep: ForwardStep?
    func playControl(_ view: PlayControlView, didTapForward step: ForwardStep) {
        forwardStep = step
    }
    var replayStep: ReplayStep?
    func playControl(_ view: PlayControlView, didTapReplay step: ReplayStep) {
        replayStep = step
    }
    
    
}
