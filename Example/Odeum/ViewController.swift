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
        view.addSubview(odeumPlayer)
        NSLayoutConstraint.activate([
            odeumPlayer.topAnchor.constraint(equalTo: view.topAnchor),
            odeumPlayer.leftAnchor.constraint(equalTo: view.leftAnchor),
            odeumPlayer.rightAnchor.constraint(equalTo: view.rightAnchor),
            odeumPlayer.heightAnchor.constraint(equalTo: odeumPlayer.widthAnchor, multiplier: 9/16)
        ])
        let url = URL(string: "https://www.radiantmediaplayer.com/media/big-buck-bunny-360p.mp4")!
        odeumPlayer.play(url: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
