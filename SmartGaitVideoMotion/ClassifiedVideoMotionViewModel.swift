//
//  ClassifiedVideoMotionViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 30/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import CorePlot
import Foundation
import SwiftCSV

struct ClassifiedVideoMotionViewModel: VideoMotionViewModel {
  typealias DataSource = ClassifiedDataPlotDataSource

  var dataPath: ClassifiedDataPath

  var mergedCSV: CSV!

  var mergedMotionData: [MergedMotionData]
  var iOSMotionData: [ClassifiedMotionData]
  var watchOSMotionData: [ClassifiedMotionData]

  var state = VideoMotionState()

  var dataSource: ClassifiedDataPlotDataSource
  var graph: Graph<ClassifiedDataPlotDataSource>

  var video: Video?

  var delegate: VideoMotionViewDelegate?

  init(dataPath: ClassifiedDataPath) throws {
    self.dataPath = dataPath

    let mergedData: (csv: CSV, motionData: [MergedMotionData]) = try CSVHelper.readCSV(inPath: dataPath.mergedPath, delimiter: ";")
    mergedCSV = mergedData.csv
    mergedMotionData = mergedData.motionData

    iOSMotionData = mergedMotionData.map { $0.iOSClassifiedData }
    watchOSMotionData = mergedMotionData.map { $0.watchOSClassifiedData }

    dataSource = ClassifiedDataPlotDataSource(iOSMotionData: self.iOSMotionData,
                                              watchOSMotionData: self.watchOSMotionData, mergedData: [])
    graph = Graph<ClassifiedDataPlotDataSource>(dataSource: dataSource)
  }

  func exportCSV(toPath path: String) {
    fatalError("TODO exportCSV")
  }

  mutating func setupGraph(gravityXHostingView: CPTGraphHostingView, gravityYHostingView: CPTGraphHostingView,gravityZHostingView: CPTGraphHostingView) {
    graph.setup(gravityXHostingView: gravityXHostingView,
                gravityYHostingView: gravityYHostingView,
                gravityZHostingView: gravityZHostingView)
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
}
