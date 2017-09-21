//
//  CPTXYGraph+Identifier.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import CorePlot

extension CPTXYGraph {
  func plots(withIdentifiers identifiers: [String]) -> [CPTPlot] {
    return identifiers.flatMap { self.plot(withIdentifier: $0 as NSCopying) }
  }

  func plots(withIdentifiers identifiers: [GraphIdentifier]) -> [CPTPlot] {
    return plots(withIdentifiers: identifiers.map { $0.rawValue })
  }
}
