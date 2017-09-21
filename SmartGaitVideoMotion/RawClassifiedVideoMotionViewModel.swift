//
//  RawClassifiedVideoMotionViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 15/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import SwiftCSV
import CorePlot

struct RawClassifiedVideoMotionViewModel: VideoMotionViewModel {
  typealias DataSource = RawClassifiedDataPlotDataSource

  var dataPath: RawClassifiedDataPath

  var iOSCSV: CSV!
  var watchOSCSV: CSV!

  var iOSMotionData: [RawClassifiedMotionData]
  var watchOSMotionData: [RawClassifiedMotionData]

  var state = VideoMotionState()

  var graph: Graph<DataSource>
  var video: Video?

  var dataSource: DataSource
  
  var delegate: VideoMotionViewDelegate?

  init(dataPath: RawClassifiedDataPath) throws {
    self.dataPath = dataPath

    let iOSData: (csv: CSV, motionData: [RawClassifiedMotionData])  = try CSVHelper.readCSV(inPath: dataPath.iOSPath, delimiter: ";")
    iOSCSV = iOSData.csv
    iOSMotionData = iOSData.motionData

    let watchOSData: (csv: CSV, motionData: [RawClassifiedMotionData]) = try CSVHelper.readCSV(inPath: dataPath.watchOSPath, delimiter: ";")
    watchOSCSV = watchOSData.csv
    watchOSMotionData = watchOSData.motionData

    dataSource = DataSource(iOSMotionData: self.iOSMotionData,
                                       watchOSMotionData: self.watchOSMotionData)
    graph = Graph<DataSource>(dataSource: dataSource)
  }

  mutating func setupGraph(gravityXHostingView: CPTGraphHostingView,
                           gravityYHostingView: CPTGraphHostingView,
                           gravityZHostingView: CPTGraphHostingView) {
    graph.setup(gravityXHostingView: gravityXHostingView,
                gravityYHostingView: gravityYHostingView,
                gravityZHostingView: gravityZHostingView)
  }
}

extension RawClassifiedVideoMotionViewModel {
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
    delegate?.didAppend(element: iOSMotionData[state.iOSIndex], toGraph: "iOS")

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

extension RawClassifiedVideoMotionViewModel {
  func performAnalysis() {
    let matchingActivities = numberOfMatchingActivities()
    let matchingClassifications = numberOfMatchingClassifications()
    let matchingClassifiers = numberOfMatchingClassifiersForCorrectActivity()
    let instancesForActivity = countBalancedAndImbalancedInstancesForActivity()
    let meanRatePerActivity = meanBalancedAndImbalancedInstancesForActivity()

    print("Stat: Matching Activities: \(matchingActivities) rates: \(rate(matching: matchingActivities))")
    print("Stat: Matching Classification: \(matchingClassifications) rates: \(rate(matching: matchingClassifications))")
    print("Stat: Classifications for correct activity: \(matchingClassifiers)")
    print("Stat: Number Of Instances per activity: \(instancesForActivity)")
    print("Stat: Mean rate per activity: \(meanRatePerActivity)")

  }

  private func numberOfMatchingActivities() -> (correct: Int, incorrect: Int) {
    return numbeOfMatching(list: iOSMotionData.filter { $0.zNewCurrentActivity != "?" }.map { $0.zCurrentActivity == $0.zNewCurrentActivity })
  }

  private func numberOfMatchingClassifications() -> (correct: Int, incorrect: Int) {
    return numbeOfMatching(list: iOSMotionData.filter { $0.zNewCurrentActivity != "?" }.map { $0.zOldDataClassification == $0.zDataClassification })
  }

  private func numberOfMatchingClassifiersForCorrectActivity() -> [String: (correct: Int, incorrect: Int)] {
    let results = iOSMotionData.flatMap { $0.zClassificationSummary }.map { applyRegex(string: $0) }
    let finalResults = iOSMotionData.map { $0.zDataClassification }
    let classifiers1 = results.map { Classifier(array: Array($0[2...10])) }
    let classifiers2 = results.map { Classifier(array: Array($0[11...19])) }
    let classifiers3 = results.map { Classifier(array: Array($0[20...28])) }
    let activities = iOSMotionData.map { $0.zNewCurrentActivity }

    var rest = (correct: 0, incorrect: 0)
    var walking = (correct: 0, incorrect: 0)
    var both = (correct: 0, incorrect: 0)

    for ((finalResult, activity), (classifier1, (classifier2, classifier3))) in zip(zip(finalResults, activities), zip(classifiers1, zip(classifiers2, classifiers3))) {
      guard let activity = activity, activity != "?" else { continue }

      let currentActivityClassifier = [classifier1, classifier2, classifier3].filter { $0.activity == activity }.first!
      let bothClassifier = [classifier1, classifier2, classifier3].filter { $0.activity == "both" }.first!

      let currentActivityCorrect = finalResult == currentActivityClassifier.result
      let bothCorrect = finalResult == bothClassifier.result

      switch currentActivityClassifier.activity {
      case "stationary":
        rest = currentActivityCorrect ? (correct: rest.correct + 1, incorrect: rest.incorrect) : (correct: rest.correct, incorrect: rest.incorrect + 1)
      case "walking":
        walking = currentActivityCorrect ? (correct: walking.correct + 1, incorrect: walking.incorrect) : (correct: walking.correct, incorrect: walking.incorrect + 1)
      default: continue
      }

      both = bothCorrect ? (correct: both.correct + 1, incorrect: both.incorrect) : (correct: both.correct, incorrect: both.incorrect + 1)
    }

    return ["rest": rest, "walking": walking, "both": both]
  }

  private func countBalancedAndImbalancedInstancesForActivity() -> [String: (balanced: Int, imbalanced: Int)] {
    let results = iOSMotionData.flatMap { $0.zClassificationSummary }.map { applyRegex(string: $0) }
    let classifiers1 = results.map { Classifier(array: Array($0[2...10])) }
    let classifiers2 = results.map { Classifier(array: Array($0[11...19])) }
    let classifiers3 = results.map { Classifier(array: Array($0[20...28])) }
    let activities = iOSMotionData.map { $0.zNewCurrentActivity }

    let rest = numberOfBalancedAndImbalancedInstances(for: classifiers1, with: activities)
    let walking = numberOfBalancedAndImbalancedInstances(for: classifiers2, with: activities)
    let both = numberOfBalancedAndImbalancedInstances(for: classifiers3, with: activities)
    return ["rest": rest, "walking": walking, "both": both]
  }

  private func numberOfBalancedAndImbalancedInstances(for classifiers: [Classifier], with activities: [String?]) -> (balanced: Int, imbalanced: Int) {
    return zip(classifiers, activities).reduce((balanced: 0, imbalanced: 0)) { result, element  in
      let (classifier, activityString) = element

      guard let activity = activityString, activity != "?", (activity == classifier.activity || classifier.activity == "both") else { return result }

      return (balanced: result.balanced + Int(classifier.numberOfBalancedInstances)!,
              imbalanced: result.imbalanced + Int(classifier.numberOfImbalancedInstances)!)
    }
  }

  private func meanBalancedAndImbalancedInstancesForActivity() -> [String: (balanced: Double, imbalanced: Double)] {
    let results = iOSMotionData.flatMap { $0.zClassificationSummary }.map { applyRegex(string: $0) }
    let classifiers1 = results.map { Classifier(array: Array($0[2...10])) }
    let classifiers2 = results.map { Classifier(array: Array($0[11...19])) }
    let classifiers3 = results.map { Classifier(array: Array($0[20...28])) }
    let activities = iOSMotionData.map { $0.zNewCurrentActivity }

    let rest = meanBalancedAndImbalancedInstances(for: classifiers1, with: activities)
    let walking = meanBalancedAndImbalancedInstances(for: classifiers2, with: activities)
    let both = meanBalancedAndImbalancedInstances(for: classifiers3, with: activities)
    return ["rest": rest, "walking": walking, "both": both]
  }

  private func meanBalancedAndImbalancedInstances(for classifiers: [Classifier], with activities: [String?]) -> (balanced: Double, imbalanced: Double)  {

    let totals = zip(classifiers, activities).reduce((balanced: 0.0, imbalanced: 0.0, count: 0)) { result, element  in
      let (classifier, activityString) = element

      guard let activity = activityString, activity != "?", (activity == classifier.activity || classifier.activity == "both") else { return result }

      let balanced = Double(classifier.numberOfBalancedInstances)!
      let imbalanced = Double(classifier.numberOfImbalancedInstances)!
      let total = balanced + imbalanced

      let balancedRate = balanced / total
      let imbalancedRate = imbalanced / total

      return (balanced: result.balanced + balancedRate,
              imbalanced: result.imbalanced + imbalancedRate, count: result.count + 1)
    }

    return (balanced: totals.balanced / Double(totals.count), imbalanced: totals.imbalanced / Double(totals.count))
  }

  private func applyRegex(string: String) -> [String] {
    let pattern = "([A-Z]\\w+): ([a-z]\\w+) - \\[(.+?(?=:)): ([a-z]\\w+): ([a-z]\\w+): ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+\\.\\d), (.+?(?=:)): ([a-z]\\w+): ([a-z]\\w+): ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+\\.\\d), (.+?(?=:)): ([a-z]\\w+): ([a-z]\\w+): ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+\\.\\d)]"

    let _ = "([A-Z]\\w+): ([a-z]\\w+) - \\[(.+?(?=:)): ([a-z]\\w+): ([a-z]\\w+): ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+\\.\\d), (.+?(?=:)): ([a-z]\\w+): ([a-z]\\w+): ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+), ([a-z]\\w+): (\\d+\\.\\d)]"

    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))

    let result: [String] = matches.flatMap { (match) -> [String] in
      return (0..<match.numberOfRanges).map { n -> String in
        let range = match.rangeAt(n)
        let r = string.index(string.startIndex, offsetBy: range.location) ..< string.index(string.startIndex, offsetBy: range.location + range.length)
        return string.substring(with: r)
      }
    }

    return Array(result.dropFirst(1))
  }

  private func rate(matching: (correct: Int, incorrect: Int)) -> (correct: Double, incorrect: Double) {
    let total = matching.correct + matching.incorrect
    return (correct: Double(matching.correct) / Double(total), incorrect: Double(matching.incorrect) / Double(total))
  }

  private func numbeOfMatching(list: [Bool]) -> (correct: Int, incorrect: Int) {
    return list.reduce((correct: 0, incorrect: 0)) {
      return $0.1 ? (correct: $0.0.correct + 1, incorrect: $0.0.incorrect) : (correct: $0.0.correct, incorrect: $0.0.incorrect + 1)
    }
  }

}

struct Classifier {
  let title: String
  let result: String
  let numberOfBalancedInstances: String
  let numberOfImbalancedInstances: String
  let sensivity: String
  let activity: String

  init(array: [String]) {
    title = array[0]
    result = array[1]
    numberOfBalancedInstances = array[4]
    numberOfImbalancedInstances = array[6]
    sensivity = array[8]

    activity = title.contains("Resting") ? "both" : (title.contains("Rest") ? "stationary" : "walking")
  }
}
