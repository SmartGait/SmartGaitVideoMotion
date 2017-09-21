//
//  VideoMotionViewController.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 31/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//
// 1-30
// x - 240 => x = 8
// 1s-100amostras
// 8s - x
// 1segundo - 12,5 amostras
//  Created by Francisco Gonçalves on 27/02/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import AVKit
import AVFoundation
import Cocoa
import CorePlot
import SwiftCSV

class VideoMotionViewController<ViewModel: VideoMotionViewModel>: NSViewController, CPTPlotAreaDelegate, CPTPlotSpaceDelegate, VideoMotionViewDelegate {
  // MARK: - Layout
  @IBOutlet weak var playPauseButton: NSButton!
  @IBOutlet weak var selectIn: NSButton!
  @IBOutlet weak var selectOut: NSButton!
  @IBOutlet weak var confirm: NSButton!
  @IBOutlet weak var labelSelectedData: NSTextField!

  @IBOutlet weak var stackView: NSStackView!
  @IBOutlet weak var gravityXHostingView: CPTGraphHostingView!
  @IBOutlet weak var gravityYHostingView: CPTGraphHostingView!
  @IBOutlet weak var gravityZHostingView: CPTGraphHostingView!

  @IBOutlet weak var playerView: AVPlayerView!

  @IBOutlet weak var summaryLabel: NSTextField!
  @IBOutlet weak var activityLabel: NSTextField!

  var videoFPS = 240 / 30.0
  lazy var rate: TimeInterval = { [unowned self] in
    return 1 / self.videoFPS
    }()

  var stepMark: CMTime?

  weak var iOSTimer: Timer?
  weak var watchOSTimer: Timer?

  var viewModel: ViewModel!
  var video: Video?

  init?(nibName: String) {
    super.init(nibName: nibName, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func markStep(_ sender: NSButton) {
    stepMark = video?.currentStep()

    if let stepMark = stepMark {
      DispatchQueue.main.async {
        let preferences = UserDefaults.standard
        preferences.set(stepMark.timescale, forKey: CMTimeKeys.timescale.rawValue)
        preferences.set(stepMark.seconds, forKey: CMTimeKeys.seconds.rawValue)
        preferences.synchronize()
      }
    }
  }

  @IBAction func play(_ sender: NSButton) {
    if viewModel.state.paused {
      video?.play(atRate: Float(rate))
    } else {
      video?.pause()
    }

    viewModel.state.paused = !viewModel.state.paused
  }

  @IBAction func reset(_ sender: Any) {
    video?.pause()
    if let stepMark = stepMark {
      video?.seek(to: stepMark)
    }
    viewModel.reset()
    playPauseButton.state = 1
  }

  @IBAction func hideOrShowGraph(_ sender: NSButton) {
    guard let id = sender.identifier else { return }

    let isHidden = sender.state == 1

    switch id {
    case "gravityX":
      gravityXHostingView.isHidden = isHidden
    case "gravityY":
      gravityYHostingView.isHidden = isHidden
    case "gravityZ":
      gravityZHostingView.isHidden = isHidden
    default: break
    }
  }

  @IBAction func selectAction(_ sender: NSButton) {
    guard let id = sender.identifier, let selecting = Selecting(rawValue: id) else { return }
    viewModel.didPressSelect(selecting: selecting)
  }

  @IBAction func confirmLabel(_ sender: NSButton) {
    viewModel.updateData(withLabel: labelSelectedData.stringValue, in: .label)
  }

  @IBAction func confirmActivity(_ sender: NSButton) {
    viewModel.updateData(withLabel: labelSelectedData.stringValue, in: .activity)
  }

  @IBAction func dataAnalysis(_ sender: NSButton) {
    viewModel.performAnalysis()
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    video?.updateFrame()
  }
}

extension VideoMotionViewController {
  func setupData() throws {
    viewModel.delegate = self
  
    video = Video(videoPath: viewModel.dataPath.videoPath, playerView: playerView)

    viewModel.setupGraph(gravityXHostingView: gravityXHostingView,
                         gravityYHostingView: gravityYHostingView,
                         gravityZHostingView: gravityZHostingView)

    viewModel?.video = video

    video?.play(atRate: Float(rate))

    viewModel.printFrequencies()

    let preferences = UserDefaults.standard
    let timescale = preferences.integer(forKey: CMTimeKeys.timescale.rawValue)
    let seconds = preferences.double(forKey: CMTimeKeys.seconds.rawValue)
    stepMark = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(timescale))

    print("iOS: \(viewModel.iOSMotionData.count)")
    print("watchOS: \(viewModel.watchOSMotionData.count)")
    startProcessing()
  }

  func startProcessing() {
    iOSTimer = startTimer(frequency: 100, forData: viewModel.iOSMotionData) { [weak self] _ in
      guard let `self` = self else {
        return
      }
      self.viewModel.processIOS()
    }

    watchOSTimer = startTimer(frequency: 50, forData: viewModel.watchOSMotionData) { [weak self] _ in
      guard let `self` = self else {
        return
      }
      self.viewModel.processWatchOS()
    }
  }

  func startTimer(frequency: Double = 0, forData data: [MotionData], block: @escaping (Timer) -> Swift.Void) -> Timer {
    let timerFrequency = videoFPS / (frequency == 0 ? viewModel.calculateFrequency(data: data) : frequency)
    return Timer.scheduledTimer(withTimeInterval: timerFrequency /*0.16,0.08,1/(100/8)*/, repeats: true, block: block)
  }
}

extension VideoMotionViewController: Exportable {
  func exportCSV(toPath path: String) {
    viewModel.exportCSV(toPath: path)
  }
}

extension VideoMotionViewController {
  func didAppend(element: MotionData, toGraph graph: String) {
    print(element.zClassificationSummary)
    summaryLabel.stringValue = element.zClassificationSummary ?? ""
    activityLabel.stringValue = element.zCurrentActivity ?? ""
  }
}
