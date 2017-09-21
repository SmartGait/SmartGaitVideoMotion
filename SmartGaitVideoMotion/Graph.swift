//
//  Graph.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import CorePlot

struct Graph<DataSource: VideoMotionDataPlotDataSource> {
  let graphGravityX = CPTXYGraph(frame: .zero)
  let graphGravityY = CPTXYGraph(frame: .zero)
  let graphGravityZ = CPTXYGraph(frame: .zero)
  var graphs: [CPTXYGraph]

  // MARK: - CorePlot
  var dataSource: DataSource
  var scatterPlotSpaceDelegate: RawDataScatterPlotSpaceDelegate<DataSource>

  init (
    dataSource: DataSource) {
    self.dataSource = dataSource

    graphs = [graphGravityX, graphGravityY, graphGravityZ]
    scatterPlotSpaceDelegate = RawDataScatterPlotSpaceDelegate(graphs: graphs, dataSource: dataSource)
  }

  func setup(gravityXHostingView: CPTGraphHostingView,
             gravityYHostingView: CPTGraphHostingView,
             gravityZHostingView: CPTGraphHostingView) {
    setup(graph: graphGravityX, inHostingView: gravityXHostingView, iOSGraphIdentifier: .iOSGravityX, watchOSGraphIdentifier: .watchOSGravityX)
    setup(graph: graphGravityY, inHostingView: gravityYHostingView, iOSGraphIdentifier: .iOSGravityY, watchOSGraphIdentifier: .watchOSGravityY)
    setup(graph: graphGravityZ, inHostingView: gravityZHostingView, iOSGraphIdentifier: .iOSGravityZ, watchOSGraphIdentifier: .watchOSGravityZ)
  }

  fileprivate func setup(graph: CPTXYGraph, inHostingView hostingView: CPTGraphHostingView, iOSGraphIdentifier: GraphIdentifier,
                         watchOSGraphIdentifier: GraphIdentifier) {
    let theme = CPTTheme(named: .plainWhiteTheme)
    graph.apply(theme)
    hostingView.hostedGraph = graph

    // Setup scatter plot space
    let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace
    plotSpace?.allowsUserInteraction = true

    let horizontalBounds = dataSource.horizontalBounds()
    let xLow = horizontalBounds!.min
    let xMax = horizontalBounds!.max

    let verticalBounds = dataSource.verticalBounds(forIdentifiers: [iOSGraphIdentifier, watchOSGraphIdentifier])
    let yLow = verticalBounds!.min
    let yMax = verticalBounds!.max

    plotSpace?.setPlotRange(CPTPlotRange(location: NSNumber(value: xLow), length: NSNumber(value: xMax-xLow)), for: .X)
    plotSpace?.setPlotRange(CPTPlotRange(location: NSNumber(value: yLow + 0.1 * yLow), length: NSNumber(value: yMax-yLow + 0.1 * yMax)), for: .Y)

    // Axes
    let axisSet = graph.axisSet
    let x = (axisSet as? CPTXYAxisSet)?.xAxis
    x?.labelingPolicy = .none
    x?.orthogonalPosition = NSNumber(value: 0)

    let y = (axisSet as? CPTXYAxisSet)?.yAxis
    y?.labelingPolicy = .automatic
    y?.paddingLeft = 20
    y?.orthogonalPosition = NSNumber(value: xLow)

    graph.axisSet?.axes = [x!, y!]

    let iOSScatterPlot = setupPlot(identifier: iOSGraphIdentifier , title: iOSGraphIdentifier.rawValue)
    let watchOSScatterPlot = setupPlot(identifier: watchOSGraphIdentifier , title: watchOSGraphIdentifier.rawValue)

    graph.add(iOSScatterPlot)
    graph.add(watchOSScatterPlot)
  }


  fileprivate func setupPlot(identifier: GraphIdentifier, title: String) -> CPTScatterPlot {
    let scatterPlot = CPTScatterPlot()

    scatterPlot.identifier = identifier.rawValue as NSString
    scatterPlot.dataSource = dataSource
    scatterPlot.dataLineStyle = dataSource
      .isKind(of: RawDataPlotDataSource.self) || dataSource.isKind(of: RawClassifiedDataPlotDataSource.self) ? nil : CPTLineStyle()
    scatterPlot.title = title
    scatterPlot.showLabels = true
    scatterPlot.delegate = scatterPlotSpaceDelegate
    scatterPlot.plotSymbolMarginForHitDetection = 0.1

    return scatterPlot
  }
}

extension Graph {
  func reloadData() {
    graphs.forEach { $0.allPlots().forEach { $0.reloadData() }}
  }

  func reset() {
    dataSource.reset()
    reloadData()
  }

  func updateData(withLabel label: String, in attribute: SettableAttribute) -> (iOSMotionData: [DataSource.Data], watchOSMotionData: [DataSource.Data])? {
    guard let selectedIn = scatterPlotSpaceDelegate.selectedIn,
      let selectedOut = scatterPlotSpaceDelegate.selectedOut,
      selectedIn.graphIdentifier == selectedOut.graphIdentifier,
      Int(selectedIn.index) < Int(selectedOut.index),
      label.characters.count > 0 else {
        return nil
    }

    var data: [DataSource.Data]
    switch selectedIn.graphIdentifier {
    case .iOSGravityX, .iOSGravityY, .iOSGravityZ:
      data = dataSource.iOSMotionData
    case .watchOSGravityX, .watchOSGravityY, .watchOSGravityZ:
      data = dataSource.watchOSMotionData
    }

    let range: CountableClosedRange = Int(selectedIn.index)...Int(selectedOut.index)

    let dataModified = data[range].map { (motionData) -> DataSource.Data in
      var motionData = motionData
      motionData.set(element: label, in: attribute)
      return motionData
    }

    data.replaceSubrange(range, with: dataModified)

    switch selectedIn.graphIdentifier {
    case .iOSGravityX, .iOSGravityY, .iOSGravityZ:
      dataSource.iOSMotionData = data
    case .watchOSGravityX, .watchOSGravityY, .watchOSGravityZ:
      dataSource.watchOSMotionData = data
    }

    return (iOSMotionData: dataSource.iOSMotionData, watchOSMotionData: dataSource.watchOSMotionData)
  }

  // MARK: - iOSGraphs
  func appendNewIOSEntry(index: Int) {
    dataSource.appendNewIOSEntry(index: index)
  }

  func didInsertDataOnIOSGraph() {
    graphs
      .flatMap { $0.plots(withIdentifiers: [.iOSGravityX, .iOSGravityY, .iOSGravityZ]) }
      .forEach { $0.insertData(at: UInt(dataSource.iOSPlotMotionData.count - 1), numberOfRecords: 1) }

  }

  // MARK: - watchOSGraphs
  func appendNewWatchOSEntry(index: Int) {
    dataSource.appendNewWatchOSEntry(index: index)
  }

  func didInsertDataOnWatchOSGraph() {
    graphs
      .flatMap { $0.plots(withIdentifiers: [.watchOSGravityX, .watchOSGravityY, .watchOSGravityZ]) }
      .forEach { $0.insertData(at: UInt(dataSource.watchOSPlotMotionData.count - 1), numberOfRecords: 1)}
    
  }
}
