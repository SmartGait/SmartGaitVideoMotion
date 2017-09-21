////
////  ViewController.swift
////  SmartGaitVideoMotion
//// 1-30
//// x - 240 => x = 8
//// 1s-100amostras
//// 8s - x
//// 1segundo - 12,5 amostras
////  Created by Francisco Gonçalves on 27/02/2017.
////  Copyright © 2017 Francisco Gonçalves. All rights reserved.
////
//
//import AVKit
//import AVFoundation
//import Cocoa
//import CorePlot
//import SwiftCSV
//
//class ViewController<ViewModel: VideoMotionViewModel>: NSViewController, CPTPlotAreaDelegate, CPTPlotSpaceDelegate {
//
//  // MARK: - Layout
//  @IBOutlet weak var playPauseButton: NSButton!
//  @IBOutlet weak var selectIn: NSButton!
//  @IBOutlet weak var selectOut: NSButton!
//  @IBOutlet weak var confirm: NSButton!
//  @IBOutlet weak var labelSelectedData: NSTextField!
//
//  @IBOutlet weak var stackView: NSStackView!
//  @IBOutlet weak var gravityXHostingView: CPTGraphHostingView!
//  @IBOutlet weak var gravityYHostingView: CPTGraphHostingView!
//  @IBOutlet weak var gravityZHostingView: CPTGraphHostingView!
//
//  @IBOutlet weak var playerView: AVPlayerView!
//
//  var videoFPS = 50.0 / 30.0
//  lazy var rate: TimeInterval = { [unowned self] in
//    return 1 / self.videoFPS
//  }()
//
//  var stepMark: CMTime?
//
//  weak var iOSTimer: Timer?
//  weak var watchOSTimer: Timer?
//
//  var viewModel: ViewModel!
//  var video: Video?
//
//  init?(nibName: String = "ViewController") {
//    super.init(nibName: nibName, bundle: nil)
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  override func viewDidLoad() {
//    try! setupData()
//  }
//
//  @IBAction func markStep(_ sender: NSButton) {
//    stepMark = video?.currentStep()
//
//    if let stepMark = stepMark {
//      DispatchQueue.main.async {
//        let preferences = UserDefaults.standard
//        preferences.set(stepMark.timescale, forKey: CMTimeKeys.timescale.rawValue)
//        preferences.set(stepMark.seconds, forKey: CMTimeKeys.seconds.rawValue)
//        preferences.synchronize()
//      }
//    }
//  }
//
//  @IBAction func play(_ sender: NSButton) {
//    if viewModel.state.paused {
//      video?.play(atRate: Float(rate))
//    } else {
//      video?.pause()
//    }
//
//    viewModel.state.paused = !viewModel.state.paused
//  }
//
//  @IBAction func reset(_ sender: Any) {
//    video?.pause()
//    if let stepMark = stepMark {
//      video?.seek(to: stepMark)
//    }
//    viewModel.reset()
//    playPauseButton.state = 1
//  }
//
//  @IBAction func hideOrShowGraph(_ sender: NSButton) {
//    guard let id = sender.identifier else { return }
//
//    let isHidden = sender.state == 1
//
//    switch id {
//    case "gravityX":
//      gravityXHostingView.isHidden = isHidden
//    case "gravityY":
//      gravityYHostingView.isHidden = isHidden
//    case "gravityZ":
//      gravityZHostingView.isHidden = isHidden
//    default: break
//    }
//  }
//
//  @IBAction func selectAction(_ sender: NSButton) {
//    guard let id = sender.identifier, let selecting = Selecting(rawValue: id) else { return }
//    viewModel.didPressSelect(selecting: selecting)
//  }
//
//  @IBAction func confirm(_ sender: NSButton) {
//    viewModel.updateData(withLabel: labelSelectedData.stringValue)
//  }
//
//  override func viewDidLayout() {
//    super.viewDidLayout()
//    video?.updateFrame()
//  }
//}
//
//extension ViewController {
//  func setupData() throws {
//    video = Video(videoPath: viewModel.dataPath.videoPath, playerView: playerView)
//
//    viewModel.setupGraph(gravityXHostingView: gravityXHostingView,
//                        gravityYHostingView: gravityYHostingView,
//                        gravityZHostingView: gravityZHostingView)
//
//    viewModel?.video = video
//
//    video?.play(atRate: Float(rate))
//
//    viewModel.printFrequencies()
//
//    let preferences = UserDefaults.standard
//    let timescale = preferences.integer(forKey: CMTimeKeys.timescale.rawValue)
//    let seconds = preferences.double(forKey: CMTimeKeys.seconds.rawValue)
//    stepMark = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(timescale))
//
//    print("iOS: \(viewModel.iOSMotionData.count)")
//    print("watchOS: \(viewModel.watchOSMotionData.count)")
//    startProcessing()
//  }
//
//  func startProcessing() {
//    iOSTimer = startTimer(forData: viewModel.iOSMotionData) { [weak self] _ in
//      guard let `self` = self else {
//        return
//      }
//      self.viewModel.processIOS()
//    }
//
//    watchOSTimer = startTimer(forData: viewModel.watchOSMotionData) { [weak self] _ in
//      guard let `self` = self else {
//        return
//      }
//      self.viewModel.processWatchOS()
//    }
//  }
//
//  func startTimer(forData data: [MotionData], block: @escaping (Timer) -> Swift.Void) -> Timer {
//    let frequency = videoFPS / viewModel.calculateFrequency(data: data)
//    return Timer.scheduledTimer(withTimeInterval: frequency /*0.16,0.08,1/(100/8)*/, repeats: true, block: block)
//  }
//}
