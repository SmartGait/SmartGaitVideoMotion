//
//  Video.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import AVKit
import AVFoundation
import Foundation

struct Video {
  var playerLayer: AVPlayerLayer?
  fileprivate var playerView: AVPlayerView

  init(videoPath: String, playerView: AVPlayerView) {
    self.playerView = playerView
    let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
    playerView.player = player

    if let orientation = getOrientation(track: player.currentItem?.asset.tracks(withMediaType: AVMediaTypeVideo).first),
      orientation == .landscape {

      let layer = setupLandscapeLayer(forPlayer: player)
      playerLayer = layer
      playerView.layer?.sublayers?.first?.addSublayer(layer)
    }

    print("Frame rate: \(playerView.player?.currentItem?.asset.tracks(withMediaType: AVMediaTypeVideo).last?.nominalFrameRate)")
  }

  private func setupLandscapeLayer(forPlayer player: AVPlayer) -> AVPlayerLayer {
    let layer = AVPlayerLayer(player: player)
    layer.backgroundColor = NSColor.black.cgColor
    layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi/2.0)))
    layer.frame = playerView.bounds
    layer.videoGravity = AVLayerVideoGravityResizeAspect
    return layer
  }

  private func getOrientation(track: AVAssetTrack?) -> VideoOrientation? {
    guard let naturalSize = track?.naturalSize,
      let preferredTransform = track?.preferredTransform else {
        return nil
    }

    let size = naturalSize.applying(preferredTransform)
    return size.width > size.height ? .landscape : .portrait
  }
}

extension Video {
  func play(atRate rate: Float) {
    playerView.player?.playImmediately(atRate: rate)
  }

  func pause() {
    playerView.player?.pause()
  }

  func currentStep() -> CMTime? {
    return playerView.player?.currentTime()
  }

  func seek(to time: CMTime) {
    playerView.player?.seek(to: time)
  }

  func updateFrame() {
    playerLayer?.frame = playerView.bounds
  }
}
