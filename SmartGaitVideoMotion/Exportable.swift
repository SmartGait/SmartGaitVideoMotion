//
//  Exportable.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 31/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

protocol Exportable {
  func exportCSV(toPath path: String)
}
