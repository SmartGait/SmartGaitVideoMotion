//
//  ViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 30/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import SwiftCSV
import CorePlot

struct RawVideoMotionViewModel: VideoMotionViewModel {

  typealias DataSource = RawDataPlotDataSource

  var dataPath: RawDataPath

  var iOSCSV: CSV!
  var watchOSCSV: CSV!

  var iOSMotionData: [RawMotionData]
  var watchOSMotionData: [RawMotionData]

  var state = VideoMotionState()

  var graph: Graph<RawDataPlotDataSource>
  var video: Video?

  var dataSource: RawDataPlotDataSource

  var delegate: VideoMotionViewDelegate?

  init(dataPath: RawDataPath) throws {
    self.dataPath = dataPath

    let iOSData: (csv: CSV, motionData: [RawMotionData])  = try CSVHelper.readCSV(inPath: dataPath.iOSPath, delimiter: ",")
    iOSCSV = iOSData.csv
    iOSMotionData = iOSData.motionData

    let watchOSData: (csv: CSV, motionData: [RawMotionData]) = try CSVHelper.readCSV(inPath: dataPath.watchOSPath, delimiter: ",")
    watchOSCSV = watchOSData.csv
    watchOSMotionData = watchOSData.motionData

    dataSource = RawDataPlotDataSource(iOSMotionData: self.iOSMotionData,
                                       watchOSMotionData: self.watchOSMotionData)
    graph = Graph<RawDataPlotDataSource>(dataSource: dataSource)
  }

  mutating func setupGraph(gravityXHostingView: CPTGraphHostingView,
                           gravityYHostingView: CPTGraphHostingView,
                           gravityZHostingView: CPTGraphHostingView) {
    graph.setup(gravityXHostingView: gravityXHostingView,
                gravityYHostingView: gravityYHostingView,
                gravityZHostingView: gravityZHostingView)
  }
}

extension RawVideoMotionViewModel {
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
    graph.reloadData()
  }

  func calculateFrequency(data: [MotionData]) -> Double {
    guard let first = data.first else {
      return 0.0
    }

    let buffer = Buffer(identifier: "Frequency", initialTimestamp: first.zTimestamp, interval: 1)

    let count = data
      .reduce((buffer: buffer, count: [])) { (result, motionData) -> (buffer: Buffer, count: [Int]) in

        let state = result.buffer.append(motionData: motionData)
        var count = result.count

        if state == .full {
          count.append(buffer.buffer.count)
          buffer.nextBatch()
        }

        return (buffer: buffer, count: count)
      }.count

    return Double(count.reduce(0, +) / count.count)
  }

  func exportCSV(toPath path: String) {
    do {
      try CSVHelper.exportCSV(motionData: iOSMotionData, toPath: path, withRelativePath: dataPath.iOSPath)
      try CSVHelper.exportCSV(motionData: watchOSMotionData, toPath: path, withRelativePath: dataPath.watchOSPath)
    }
    catch let error {
      print(error)
    }
  }
}
