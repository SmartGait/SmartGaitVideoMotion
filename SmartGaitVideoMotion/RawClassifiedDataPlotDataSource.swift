//
//  RawClassifiedDataPlotDataSource.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 15/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import CorePlot

final class RawClassifiedDataPlotDataSource: NSObject, VideoMotionDataPlotDataSource {
  typealias Data = RawClassifiedMotionData

  var iOSMotionData: [Data]
  var watchOSMotionData: [Data]

  var iOSPlotMotionData: [Data]
  var watchOSPlotMotionData: [Data]

  var selectedIn: (graphIdentifier: GraphIdentifier, index: UInt)?
  var selectedOut: (graphIdentifier: GraphIdentifier, index: UInt)?

  var dataLineStyle: CPTLineStyle? = nil

  init(iOSMotionData: [Data], watchOSMotionData: [Data], iOSPlotMotionData: [Data] = [], watchOSPlotMotionData: [Data] = []) {
    self.iOSMotionData = iOSMotionData
    self.watchOSMotionData = watchOSMotionData
    self.iOSPlotMotionData = iOSPlotMotionData
    self.watchOSPlotMotionData = watchOSPlotMotionData
  }

  func horizontalBounds() -> (min: Double, max: Double)? {
    guard let iOSMin = iOSMotionData.first?.zTimestamp, let watchOSMin = watchOSMotionData.first?.zTimestamp, let iOSMax = iOSMotionData.last?.zTimestamp, let watchOSMax = iOSMotionData.last?.zTimestamp else {
      return nil
    }

    let min = iOSMin < watchOSMin ? iOSMin : watchOSMin
    let max = iOSMax > watchOSMax ? iOSMax : watchOSMax
    return (min: min, max: max)
  }

  func verticalBounds(forIdentifiers identifiers: [GraphIdentifier]) -> (min: Double, max: Double)? {
    return identifiers
      .map(data)
      .reduce((min: 0, max:0)) { (result, data) -> (min: Double, max: Double) in
        guard let min = data.min(), let max = data.max() else {
          return result
        }

        return (min: min < result.min ? min : result.min, max: max > result.max ? max : result.max)
    }
  }

  func data(forIdentifier identifier: GraphIdentifier) -> [Double] {
    switch identifier {
    case .iOSGravityX:
      return iOSMotionData.map { $0.zGravityX }
    case .iOSGravityY:
      return iOSMotionData.map { $0.zGravityY }
    case .iOSGravityZ:
      return iOSMotionData.map { $0.zGravityZ }

    case .watchOSGravityX:
      return watchOSMotionData.map { $0.zGravityX }
    case .watchOSGravityY:
      return watchOSMotionData.map { $0.zGravityY }
    case .watchOSGravityZ:
      return watchOSMotionData.map { $0.zGravityZ }
    }
  }
}

extension RawClassifiedDataPlotDataSource {
  //MARK: - CPTPlotDataSource
  public func numberOfRecords(for plot: CPTPlot) -> UInt {
    guard let id = plot.identifier as? String,
      let graphIdentifier = GraphIdentifier(rawValue: id) else {
        return 0
    }

    switch graphIdentifier {
    case .iOSGravityX, .iOSGravityY, .iOSGravityZ:
      return UInt(iOSPlotMotionData.count)
    case .watchOSGravityX, .watchOSGravityY, .watchOSGravityZ:
      return UInt(watchOSPlotMotionData.count)
    }
  }

  func double(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Double {
    let field = CPTCoordinate(rawValue: Int(fieldEnum))!

    guard let id = plot.identifier as? String,
      let graphIdentifier = GraphIdentifier(rawValue: id) else {
        return 0
    }

    switch field {
    case .X:
      switch graphIdentifier {
      case .iOSGravityX, .iOSGravityY, .iOSGravityZ:
        return iOSPlotMotionData[Int(idx)].zTimestamp
      case .watchOSGravityX, .watchOSGravityY, .watchOSGravityZ:
        return watchOSPlotMotionData[Int(idx)].zTimestamp
      }
    case .Y:
      switch graphIdentifier {
      case .iOSGravityX:
        return iOSPlotMotionData[Int(idx)].zGravityX
      case .iOSGravityY:
        return iOSPlotMotionData[Int(idx)].zGravityY
      case .iOSGravityZ:
        return iOSPlotMotionData[Int(idx)].zGravityZ

      case .watchOSGravityX:
        return watchOSPlotMotionData[Int(idx)].zGravityX
      case .watchOSGravityY:
        return watchOSPlotMotionData[Int(idx)].zGravityY
      case .watchOSGravityZ:
        return watchOSPlotMotionData[Int(idx)].zGravityZ
      }
    default:
      return 0
    }
  }
}

extension RawClassifiedDataPlotDataSource {


  //MARK: - CPTScatterPlotDataSource
  func symbol(for plot: CPTScatterPlot, record idx: UInt) -> CPTPlotSymbol? {
    let symbol = CPTPlotSymbol()
    symbol.symbolType = .ellipse
    symbol.fill = CPTFill(color: .blue())
    let lineStyle = CPTMutableLineStyle()
    lineStyle.lineWidth = 0
    lineStyle.lineColor = .clear()
    symbol.lineStyle = lineStyle

    guard let id = plot.identifier as? String,
      let graphIdentifier = GraphIdentifier(rawValue: id) else {
        return nil
    }

    // basic case
    switch graphIdentifier {
    case .iOSGravityX, .iOSGravityY, .iOSGravityZ:
      if let zLabel = iOSMotionData[Int(idx)].zDataClassification, zLabel != "?" {
        if zLabel.lowercased() == "balanced" {
          symbol.fill = CPTFill(color: .red())
        } else if zLabel.lowercased() == "imbalanced" {
          symbol.fill = CPTFill(color: .magenta())
        }
      } else {
        symbol.fill = CPTFill(color: .purple())
      }
    case .watchOSGravityX, .watchOSGravityY, .watchOSGravityZ:
      if let zLabel = watchOSMotionData[Int(idx)].zDataClassification, zLabel != "?" {
        if zLabel.lowercased() == "balanced" {
          symbol.fill = CPTFill(color: .blue())
        } else if zLabel.lowercased() == "imbalanced" {
          symbol.fill = CPTFill(color: .cyan())
        }
      } else {
        symbol.fill = CPTFill(color: .green())
      }
    }

    // selected in
    if let selectedIn = selectedIn,
      graphIdentifier == selectedIn.graphIdentifier,
      idx == selectedIn.index {

      symbol.fill = CPTFill(color: .green())

    } else if let selectedIn = selectedIn, //selected out
      let selectedOut = selectedOut,
      selectedIn.graphIdentifier == selectedOut.graphIdentifier,
      graphIdentifier == selectedOut.graphIdentifier,
      idx == selectedOut.index {

      symbol.fill = CPTFill(color: .black())

    } else if let selectedIn = selectedIn, //selected between in and out
      let selectedOut = selectedOut,
      selectedIn.graphIdentifier == selectedOut.graphIdentifier,
      graphIdentifier == selectedOut.graphIdentifier,
      idx > selectedIn.index && idx < selectedOut.index {

      symbol.fill = CPTFill(color: .orange())
    }

    return symbol
  }
}
