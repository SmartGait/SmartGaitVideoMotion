//
//  VideoMotionViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 30/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import CorePlot

protocol VideoMotionViewModel {
  associatedtype DataSource: VideoMotionDataPlotDataSource
  associatedtype Path: DataPath

  var iOSMotionData: [DataSource.Data] { get set }
  var watchOSMotionData: [DataSource.Data] { get set }
  var state: VideoMotionState { get set }
  var dataSource: DataSource { get set }
  var graph: Graph<DataSource> { get set }
  var video: Video? { get set }
  var dataPath: Path { get set }
  var delegate: VideoMotionViewDelegate? { get set }

  mutating func processIOS()
  mutating func processWatchOS()
  mutating func updateData(withLabel label: String, in attribute: SettableAttribute) 
  mutating func reset()
  mutating func setupGraph(gravityXHostingView: CPTGraphHostingView, gravityYHostingView: CPTGraphHostingView,gravityZHostingView: CPTGraphHostingView)
  func didPressSelect(selecting: Selecting)
  func calculateFrequency(data: [MotionData]) -> Double
  func printFrequencies()
  func performAnalysis()
  func exportCSV(toPath path: String)
}

extension VideoMotionViewModel {
  func printFrequencies() {
    print("iOS Frequency \(calculateFrequency(data: iOSMotionData))")
    print("WatchOS Frequency \(calculateFrequency(data: watchOSMotionData))")
  }

  mutating func processIOS() {
    guard !state.paused, state.iOSIndex < iOSMotionData.count else {
      return
    }

    graph.appendNewIOSEntry(index: state.iOSIndex)
    graph.didInsertDataOnIOSGraph()

    state.iOSIndex += 1
  }

  mutating func processWatchOS() {
    guard let watchOSFirst = watchOSMotionData.first,
      let iOSPlotLast = graph.dataSource.iOSPlotMotionData.last,
      !state.paused,
      state.watchOSIndex < watchOSMotionData.count else {
        return
    }

    if state.watchInitialCheck {
      if iOSPlotLast.zTimestamp - watchOSFirst.zTimestamp >= 0 {
        state.watchInitialCheck = false
      } else {
        return
      }
    }

    graph.appendNewWatchOSEntry(index: state.watchOSIndex)
    graph.didInsertDataOnWatchOSGraph()

    state.watchOSIndex += 1
  }

  mutating func updateData(withLabel label: String, in attribute: SettableAttribute) {
    let newData = graph.updateData(withLabel: label, in: attribute)

    newData.flatMap {
      iOSMotionData = $0.iOSMotionData
      watchOSMotionData = $0.watchOSMotionData
    }

    graph.reloadData()
  }

  mutating func reset() {
    state.reset()
    graph.reset()
  }

  func didPressSelect(selecting: Selecting) {
    graph.scatterPlotSpaceDelegate.selecting = selecting
  }

  func performAnalysis() {
    print("Not implemented")
  }
}

protocol VideoMotionViewDelegate {
  func didAppend(element: MotionData, toGraph graph: String)
}
