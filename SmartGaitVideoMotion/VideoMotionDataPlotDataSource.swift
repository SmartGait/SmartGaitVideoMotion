//
//  VideoMotionDataPlotDataSource.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 30/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import CorePlot

protocol VideoMotionDataPlotDataSource: CPTScatterPlotDataSource {
  associatedtype Data: MotionData

  var iOSMotionData: [Data] { get set }
  var watchOSMotionData: [Data] { get set }

  var iOSPlotMotionData: [Data] { get set }
  var watchOSPlotMotionData: [Data] { get set }

  var selectedIn: (graphIdentifier: GraphIdentifier, index: UInt)? { get set }
  var selectedOut: (graphIdentifier: GraphIdentifier, index: UInt)? { get set }

  var dataLineStyle: CPTLineStyle? { get set }

  func appendNewIOSEntry(index: Int)
  func appendNewWatchOSEntry(index: Int)
  func reset()
  func data(forIdentifier identifier: GraphIdentifier) -> [Double]
  func horizontalBounds() -> (min: Double, max: Double)?
  func verticalBounds(forIdentifiers identifiers: [GraphIdentifier]) -> (min: Double, max: Double)?
}

extension VideoMotionDataPlotDataSource {
  func appendNewIOSEntry(index: Int) {
    iOSPlotMotionData.append(iOSMotionData[index])
  }

  func appendNewWatchOSEntry(index: Int) {
    watchOSPlotMotionData.append(watchOSMotionData[index])
  }

  func reset() {
    iOSPlotMotionData = []
    watchOSPlotMotionData = []
  }
}

