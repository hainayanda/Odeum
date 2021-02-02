//
//  ViewController.swift
//  Odeum
//
//  Created by 24823437 on 01/23/2021.
//  Copyright (c) 2021 24823437. All rights reserved.
//

import UIKit
import Odeum

class ViewController: UIViewController {

    var odeumPlayer: OdeumPlayerView = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odeumPlayer.translatesAutoresizingMaskIntoConstraints = false
        odeumPlayer.placeholderImage = #imageLiteral(resourceName: "placeholder")
        view.addSubview(odeumPlayer)
        NSLayoutConstraint.activate([
            odeumPlayer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            odeumPlayer.leftAnchor.constraint(equalTo: view.leftAnchor),
            odeumPlayer.rightAnchor.constraint(equalTo: view.rightAnchor),
            odeumPlayer.heightAnchor.constraint(equalTo: odeumPlayer.widthAnchor, multiplier: 9/16)
        ])
        odeumPlayer.delegate = self
        let url = URL(string: "https://www.radiantmediaplayer.com/media/big-buck-bunny-360p.mp4")!
        odeumPlayer.play(url: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController: OdeumPlayerViewDelegate {
    func odeumDidMuted(_ player: OdeumPlayerView) {
        print("muted")
    }
    func odeumDidUnmuted(_ player: OdeumPlayerView) {
        print("unmuted")
    }
    func odeumDidBuffering(_ player: OdeumPlayerView) {
        print("buffering")
    }
    func odeumDidPlayVideo(_ player: OdeumPlayerView) {
        print("played")
    }
    func odeumDidPauseVideo(_ player: OdeumPlayerView) {
        print("paused")
    }
    func odeumDidFinishedBuffering(_ player: OdeumPlayerView) {
        print("ready to play")
    }
    func odeumDidDismissFullScreen(_ player: OdeumPlayerView) {
        print("full screen dismissed")
    }
    func odeumDidGoToFullScreen(_ player: OdeumPlayerView) {
        print("go full screen")
    }
    func odeumViewControllerToPresentFullScreen(_ player: OdeumPlayerView) -> UIViewController {
        return self
    }
    func odeum(_ player: OdeumPlayerView, progressingBy percent: Double) {
        print("progressing \(percent)")
    }
    func odeum(_ player: OdeumPlayerView, rewindedBy interval: TimeInterval) {
        print("rewinded \(interval)")
    }
    func odeum(_ player: OdeumPlayerView, forwardedBy interval: TimeInterval) {
        print("forwarded \(interval)")
    }
}
