//
//  CSV.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import SwiftCSV

struct CSVHelper {
  static func readCSV<Data: MotionData>(inPath path: String, delimiter: Character) throws -> (csv: CSV, motionData: [Data]) {
    let csv = try CSV(name: path, delimiter: delimiter)
    var data = [Data]()
    print(csv.header)

    // Access them as a dictionary
    csv.enumerateAsDict { dict in
      do {
        data.append(try Data(dict: dict))
      }
      catch let error {
        print(error)
      }
    }

    data.sort(by: { (m1, m2) -> Bool in
      m1.zTimestamp < m2.zTimestamp
    })

    return (csv: csv, motionData: data)
  }

  static func exportCSV(motionData: [RawMotionData], toPath path: String, withRelativePath relativePath: String) throws {
    let data = NSMutableArray()
    motionData.forEach { data.add($0.toDictionary()) }

    let pathComponents = try parse(path: relativePath)

    let exportedPath = CSVExport.export
      .exportCSV(directory: path + pathComponents.subDirectory, filename: pathComponents.name, fields: ["Z_PK", "Z_ENT", "Z_OPT", "ZMAGNETICFIELDACCURACY", "ZDEVICEMOTIONRESULT", "ZATTITUDEW", "ZATTITUDEX", "ZATTITUDEY", "ZATTITUDEZ", "ZGRAVITYX", "ZGRAVITYY", "ZGRAVITYZ", "ZMAGNETICFIELDX", "ZMAGNETICFIELDY", "ZMAGNETICFIELDZ", "ZROTATIONRATEX", "ZROTATIONRATEY", "ZROTATIONRATEZ", "ZTIMESTAMP", "ZUSERACCELERATIONX", "ZUSERACCELERATIONY", "ZUSERACCELERATIONZ", "ZLABEL"], values: data)

    print(exportedPath)
  }

  static func exportCSV(motionData: [RawClassifiedMotionData], toPath path: String, withRelativePath relativePath: String) throws {
    let data = NSMutableArray()
    motionData.forEach { data.add($0.toDictionary()) }

    let pathComponents = try parse(path: relativePath)

    let exportedPath = CSVExport.export
      .exportCSV(directory: path + pathComponents.subDirectory, filename: pathComponents.name, fields: ["ZIDENTIFIER","ZUSERACCELERATIONX", "ZUSERACCELERATIONY", "ZUSERACCELERATIONZ", "ZGRAVITYX", "ZGRAVITYY", "ZGRAVITYZ", "ZROTATIONRATEX", "ZROTATIONRATEY", "ZROTATIONRATEZ", "ZATTITUDEX", "ZATTITUDEY", "ZATTITUDEZ", "ZATTITUDEW", "ZMAGNETICFIELDACCURACY", "ZMAGNETICFIELDX", "ZMAGNETICFIELDY", "ZMAGNETICFIELDZ", "ZFINALTIMESTAMP", "ZINITIALTIMESTAMP", "ZTIMESTAMP", "ZCURRENTACTIVITY", "ZNEWCURRENTACTIVITY", "ZSAMPLESUSED", "ZCLASSIFICATIONSUMMARY", "ZDATACLASSIFICATION", "ZOLDDATACLASSIFICATION"], values: data, delimiter: ";")

    print(exportedPath)
  }

  private static func parse(path: String) throws -> (name: String, subDirectory: String) {
    let pathComponents = path.components(separatedBy: "/")
    let subDirectoryComponents = pathComponents.dropFirst(pathComponents.count - 3)

    let subDirectory = "/" + subDirectoryComponents.dropLast(1).joined(separator:"/")

    guard let name = subDirectoryComponents.last?.components(separatedBy: ".").first,
      subDirectory.characters.count > 0 else {
        throw "Couldn't parse path"
    }

    return (name: name, subDirectory: subDirectory)
  }
}
