//
//  RawPlotSpaceDelegate.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import CorePlot
import Foundation

final class RawDataScatterPlotSpaceDelegate<DataSource: VideoMotionDataPlotDataSource>: NSObject, CPTScatterPlotDelegate {
  var selecting: Selecting?
  var selectedIn: (graphIdentifier: GraphIdentifier, index: UInt)?
  var selectedOut: (graphIdentifier: GraphIdentifier, index: UInt)?

  var graphs: [CPTGraph]

  weak var dataSource: DataSource?

  init(graphs: [CPTGraph], dataSource: DataSource?) {
    self.graphs = graphs
    self.dataSource = dataSource
  }

  func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecord idx: UInt) {
    guard let id = plot.identifier as? String,
      let graphIdentifier = GraphIdentifier(rawValue: id),
      let selecting = selecting else {
        return
    }

    switch selecting {
    case .in:
      selectedIn = (graphIdentifier: graphIdentifier, index: idx)
      dataSource?.selectedIn = selectedIn
    case .out:
      guard let selectedIn = selectedIn, selectedIn.graphIdentifier == graphIdentifier else {
        return
      }
      selectedOut = (graphIdentifier: graphIdentifier, index: idx)
      dataSource?.selectedOut = selectedOut
    }


    graphs.forEach { $0.allPlots().forEach { $0.reloadData() }}
  }
}
