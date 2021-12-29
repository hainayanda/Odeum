//
//  PlayControlView.swift
//  Odeum
//
//  Created by Nayanda Haberty on 23/01/21.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: Delegate

public protocol PlayControlViewDelegate: AnyObject {
    func playControl(_ view: PlayControlView, audioDidChangeStateTo state: AudioState)
    func playControl(_ view: PlayControlView, playDidChangeStateTo state: PlayState)
    func playControl(_ view: PlayControlView, fullScreenDidChangeStateTo state: FullScreenState)
    func playControl(_ view: PlayControlView, didTapForward step: ForwardStep)
    func playControl(_ view: PlayControlView, didTapReplay step: ReplayStep)
}

// MARK: PlayControlView

public class PlayControlView: UIView {
    
    // MARK: Views
    
    public private(set) lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let effect = UIVisualEffectView(effect: blurEffect)
        effect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return effect
    }()
    public private(set) lazy var buttonStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                audioButton,
                replayButton,
                playButton,
                forwardButton,
                fullScreenButton
            ]
        )
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.layoutMargins = .zero
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    public private(set) lazy var audioButton: UIButton = createButton(
        with: audioState.icon,
        selector: #selector(didTapAudio(_:))
    )
    public private(set) lazy var replayButton: UIButton = createButton(
        with: replayStep.icon,
        selector: #selector(didTapReplay(_:))
    )
    public private(set) lazy var playButton: UIButton = createButton(
        with: playState.icon,
        selector: #selector(didTapPlay(_:))
    )
    public private(set) lazy var forwardButton: UIButton = createButton(
        with: forwardStep.icon,
        selector: #selector(didTapForward(_:))
    )
    public private(set) lazy var fullScreenButton: UIButton = createButton(
        with: fullScreenState.icon,
        selector: #selector(didTapFullScreen(_:))
    )
    
    // MARK: State
    
    public var audioState: AudioState = .unmute {
        didSet {
            audioButton.setImage(icon(for: audioState), for: .normal)
        }
    }
    public var replayStep: ReplayStep = .fiveSecond {
        didSet {
            replayButton.setImage(icon(for: replayStep), for: .normal)
        }
    }
    public var playState: PlayState = .played {
        didSet {
            playButton.setImage(icon(for: playState), for: .normal)
        }
    }
    public var forwardStep: ForwardStep = .fiveSecond {
        didSet {
            forwardButton.setImage(icon(for: forwardStep), for: .normal)
        }
    }
    public var fullScreenState: FullScreenState = .minimize {
        didSet {
            fullScreenButton.setImage(icon(for: fullScreenState), for: .normal)
        }
    }
    
    // MARK: Icons
    
    var customIcons: [AnyHashable: UIImage] = [:]
    
    // MARK: Delegate
    
    public weak var delegate: PlayControlViewDelegate?
    
    // MARK: Initializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildView() {
        setupBlurEffectView()
        setupButtonStack()
    }
    
    func setupBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setupButtonStack() {
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.leftAnchor.constraint(equalTo: leftAnchor),
            buttonStack.topAnchor.constraint(equalTo: topAnchor),
            buttonStack.rightAnchor.constraint(equalTo: rightAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonStack.widthAnchor.constraint(equalTo: buttonStack.heightAnchor, multiplier: 5)
        ])
    }
    
    func createButton(
        with icon: UIImage,
        selector: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let insets = bounds.height / 3
        let playInsets = insets / 3
        let buttonInsets: UIEdgeInsets = .init(top: insets, left: insets, bottom: insets, right: insets)
        let playButtonInsets: UIEdgeInsets = .init(top: playInsets, left: playInsets, bottom: playInsets, right: playInsets)
        audioButton.imageEdgeInsets = buttonInsets
        replayButton.imageEdgeInsets = buttonInsets
        playButton.imageEdgeInsets = playButtonInsets
        forwardButton.imageEdgeInsets = buttonInsets
        fullScreenButton.imageEdgeInsets = buttonInsets
    }
    
    // MARK: Public
    
    public func icon(for audioState: AudioState) -> UIImage {
        customIcons[audioState] ?? audioState.icon
    }
    
    public func icon(for replayState: ReplayStep) -> UIImage {
        customIcons[replayState] ?? replayState.icon
    }
    
    public func icon(for playState: PlayState) -> UIImage {
        customIcons[playState] ?? playState.icon
    }
    
    public func icon(for forwardState: ForwardStep) -> UIImage {
        customIcons[forwardState] ?? forwardState.icon
    }
    
    public func icon(for fullScreenState: FullScreenState) -> UIImage {
        customIcons[fullScreenState] ?? fullScreenState.icon
    }
    
    public func set(icon: UIImage, for audioState: AudioState) {
        customIcons[audioState] = icon
    }
    
    public func set(icon: UIImage, for replayState: ReplayStep) {
        customIcons[replayState] = icon
    }
    
    public func set(icon: UIImage, for playState: PlayState) {
        customIcons[playState] = icon
    }
    
    public func set(icon: UIImage, for forwardState: ForwardStep) {
        customIcons[forwardState] = icon
    }
    
    public func set(icon: UIImage, for fullScreenState: FullScreenState) {
        customIcons[fullScreenState] = icon
    }
    
    // MARK: Delegate
    
    @objc func didTapAudio(_ sender: UIButton) {
        audioState = audioState == .mute ? .unmute : .mute
        delegate?.playControl(self, audioDidChangeStateTo: audioState)
    }
    
    @objc func didTapReplay(_ sender: UIButton) {
        delegate?.playControl(self, didTapReplay: replayStep)
    }
    
    @objc func didTapPlay(_ sender: UIButton) {
        playState = playState == .played ? .paused : .played
        delegate?.playControl(self, playDidChangeStateTo: playState)
    }
    
    @objc func didTapForward(_ sender: UIButton) {
        delegate?.playControl(self, didTapForward: forwardStep)
    }
    
    @objc func didTapFullScreen(_ sender: UIButton) {
        fullScreenState = fullScreenState == .minimize ? .fullScreen : .minimize
        delegate?.playControl(self, fullScreenDidChangeStateTo: fullScreenState)
    }
}
#endif
