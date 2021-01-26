# Odeum

Odeum is a simple iOS Video player library with basic control

[![CI Status](https://img.shields.io/travis/24823437/Odeum.svg?style=flat)](https://travis-ci.org/24823437/Odeum)
[![Version](https://img.shields.io/cocoapods/v/Odeum.svg?style=flat)](https://cocoapods.org/pods/Odeum)
[![License](https://img.shields.io/cocoapods/l/Odeum.svg?style=flat)](https://cocoapods.org/pods/Odeum)
[![Platform](https://img.shields.io/cocoapods/p/Odeum.svg?style=flat)](https://cocoapods.org/pods/Odeum)

<p align="center">
<img src="ScreenShot.png"/>
<p align="center">
  
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift 5.0 or higher
- iOS 10.0 or higher

## Installation

Odeum is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Odeum'
```

## Author

Nayanda Haberty, nayanda1@outlook.com

## License

Odeum is available under the MIT license. See the LICENSE file for more info.

## Usage

Using Odeum is very easy. You could see the sample project or just read this documentation.

Since odeum player is subclass of `UIView`. adding player is same like adding simple `UIView`:

```swift
var odeumPlayer = OdeumPlayerView()
view.addSubview(odeumPlayer)
```
Is up to you how you want it to framed, using `NSLayoutConstraints` or by manually framing it.

You could also add it using storyboard, xib.

To play the player, just add url:

```swift
odeumPlayer.play(url: myURL)
```

there are methods to manipulate video playing in odeum:
- `func set(url: URL)` to set url but not automatically play the video
- `func play()` to play the video if video is ready to play
- `func play(url: URL)` to set url and automatically play it if video is ready
- `func pause()` to pause the video
- `func set(mute: Bool)` to mute or unmute the video
- `func forward(by second: TimeInterval) -> Bool` to forward a video by given `TimeInterval`
- `func replay(by second: TimeInterval) -> Bool` to rewind a video by given `TimeInterval`
- `func goFullScreen()` to go to full screen
- `func dismissFullScreen()` to dismiss full screen

All those function will run automatically on the player control hover buttons

### Delegate

You could observe event in the OdeumPlayerView by give them delegate:

```swift
public protocol OdeumPlayerViewDelegate: class {
    func odeumDidPlayVideo(_ player: OdeumPlayerView)
    func odeumDidPauseVideo(_ player: OdeumPlayerView)
    func odeumViewControllerToPresentFullScreen(_ player: OdeumPlayerView) -> UIViewController
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
```

All the methods are optionals

### PlayerControl

If user tap the video player, it will show `PlayerControlView` which will control how the video will be played in `OdeumPlayerView`. You could also change the icon of the `PlayerControlView`:

```swift
odeumPlayer.set(icon: myIcon, for: ReplayStep.tenSecond)
```

the states are:

```swift
public enum PlayState: String, StatedIcon {
    case played = "ic_pause"
    case paused = "ic_play"
}

public enum AudioState: String, StatedIcon {
    case mute = "ic_mute"
    case unmute = "ic_umute"
}

public enum ReplayStep: String, StatedIcon {
    case fiveSecond = "ic_5_replay"
    case tenSecond = "ic_10_replay"
    case thirtySecond = "ic_30_replay"
}

public enum ForwardStep: String, StatedIcon {
    case fiveSecond = "ic_5_forward"
    case tenSecond = "ic_10_forward"
    case thirtySecond = "ic_30_forward"
}

public enum FullScreenState: String, StatedIcon {
    case fullScreen = "ic_minimize"
    case minimize = "ic_fullscreen"
}
```

### Contribute

You know how, just clone and do pull request
