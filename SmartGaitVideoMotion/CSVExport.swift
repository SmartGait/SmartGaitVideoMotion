//
//  CSVExport.swift
//  SwiftCSVExport
//
//  Created by Vignesh on 07/02/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.
//

import Foundation

//MARK: -  Extension for String to find length
extension String {
  var length: Int {
    return self.characters.count
  }
}

//MARK: -  CSVExport Class
open class CSVExport {

  ///The directory in which the cvs files will be written
  open var directory = CSVExport.defaultDirectory();

  //The name of the csv files.
  open var fileName = "csvfile";


  ///export singleton
  open class var export: CSVExport {

    struct Static {
      static let instance: CSVExport = CSVExport()
    }
    return Static.instance
  }

  ///write content to the current csv file.
  open func getFilePath() -> String{
    let path = "\(directory)/\(csvFileName())"
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
      return "";
    }
    return path;
  }

  open func exportCSV(directory: String = "", filename: String, fields: NSArray, values: NSArray, delimiter: String = ",") -> String{
    if directory.length > 0 {
      CSVExport.export.directory = directory;
    }

    if filename.length > 0 {
      CSVExport.export.fileName = filename;
    }
    CSVExport.export.cleanup();
    if fields.count > 0 && values.count > 0 {
      let  result:String = fields.componentsJoined(by: delimiter);
      CSVExport.export.write( text: result)
      for dict in values {
        let values = fields.map { (dict as! NSDictionary)[$0]! } as NSArray
        let  result:String = values.componentsJoined(by: delimiter);
        CSVExport.export.write( text: result)
      }
      return CSVExport.export.getFilePath();
    }
    return "";
  }


  ///write content to the current csv file.
  open func write(text: String) {
    let path = "\(directory)/\(csvFileName())"
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
      do {
        try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        try "".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
      } catch let error {
        print(error)
      }
    }
    if let fileHandle = FileHandle(forWritingAtPath: path) {
      let writeText = "\(text)\n"
      fileHandle.seekToEndOfFile()
      fileHandle.write(writeText.data(using: String.Encoding.utf8)!)
      fileHandle.closeFile()
      //print(writeText, terminator: "")

    }
  }

  func generateDict(_ fieldsArray: NSArray, valuesArray: NSArray ) -> NSMutableDictionary {
    let rowsDictionary:NSMutableDictionary = NSMutableDictionary()
    for i in 0..<valuesArray.count {
      let key = fieldsArray[i];
      let value = valuesArray[i];
      rowsDictionary.setObject(value, forKey: key as! NSCopying);
    }
    return rowsDictionary;
  }

  func splitUsingDelimiter(_ string: String, separatedBy: String) -> NSArray {
    if string.characters.count > 0 {
      return string.components(separatedBy: separatedBy) as NSArray;
    }
    return [];
  }

  open func read(filename: String) -> NSMutableDictionary {
    let path = "\(directory)/\(filename)"
    return self.readFromPath(filePath:path);
  }

  open func read(filepath: String) -> NSMutableDictionary {
    return self.readFromPath(filePath:filepath);
  }

  /// read content to the current csv file.
  open func readFromPath(filePath: String) -> NSMutableDictionary{
    let fileManager = FileManager.default
    let output:NSMutableDictionary = NSMutableDictionary()

    // Find the CSV file path is available
    if fileManager.fileExists(atPath: filePath) {
      do {
        // Generate the Local file path URL
        let localPathURL: URL = NSURL.fileURL(withPath: filePath);

        // Read the content from Local Path
        let csvText = try String(contentsOf: localPathURL, encoding: String.Encoding.utf8);

        // Check the csv count
        if csvText.characters.count > 0 {

          // Split based on Newline delimiter
          let csvArray = self.splitUsingDelimiter(csvText, separatedBy: "\n") as NSArray
          if csvArray.count >= 2 {
            var fieldsArray:NSArray = [];
            let rowsArray:NSMutableArray  = NSMutableArray()
            for row in csvArray {
              // Get the CSV headers
              if((row as! String).contains(csvArray[0] as! String)) {
                fieldsArray = self.splitUsingDelimiter(row as! String, separatedBy: ",") as NSArray;
              } else {
                // Get the CSV values
                let valuesArray = self.splitUsingDelimiter(row as! String, separatedBy: ",") as NSArray;
                if valuesArray.count == fieldsArray.count  && valuesArray.count > 0{
                  let rowJson:NSMutableDictionary = self.generateDict(fieldsArray, valuesArray: valuesArray)
                  if rowJson.allKeys.count > 0 && valuesArray.count == rowJson.allKeys.count && rowJson.allKeys.count == fieldsArray.count {
                    rowsArray.add(rowJson)
                  }
                }
              }
            }

            // Set the CSV headers & Values and name in the dict.
            if fieldsArray.count > 0 && rowsArray.count > 0 {
              output.setObject(fieldsArray, forKey: "fields" as NSCopying)
              output.setObject(rowsArray, forKey: "rows" as NSCopying)
              output.setObject(localPathURL.lastPathComponent, forKey: "name" as NSCopying)
            }
          }
        }
      }
      catch {
        /* error handling here */
        print("Error while read csv: \(error)", terminator: "")
      }
    }
    return output;
  }

  ///do the checks and cleanup
  open func cleanup() {
    let path = "\(directory)/\(csvFileName())"
    let size = fileSize(path)
    if size > 0 {
      //delete the oldest file
      let deletePath = "\(directory)/\(csvFileName())"
      let fileManager = FileManager.default
      do {
        try fileManager.removeItem(atPath: deletePath)
      } catch _ {
      }
    }
  }

  ///check the size of a file
  func fileSize(_ path: String) -> UInt64 {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: path) {
      let attrs: NSDictionary? = try! fileManager.attributesOfItem(atPath: path) as NSDictionary?
      if let dict = attrs {
        return dict.fileSize()
      }
    }
    return 0
  }


  ///gets the CSV name
  func csvFileName() -> String {
    return "\(fileName).csv"
  }

  ///get the default CSV directory
  class func defaultDirectory() -> String {
    var path = ""
    let fileManager = FileManager.default
    #if os(iOS)
      let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
      path = "\(paths[0])/Exports"
    #elseif os(OSX)
      let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
      if let url = urls.last?.path {
        path = "\(url)/Exports"
      }
    #endif
    if !fileManager.fileExists(atPath: path) && path != ""  {
      do {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
      } catch _ {
      }
    }
    return path
  }

}

//MARK: -  Export public Methods

///a free function to make export the CSV file from file name, fields and values
public func exportCSV(_ filename:String, fields: NSArray, values: NSArray) -> String{
  return CSVExport.export.exportCSV(filename: filename, fields: fields, values: values);
}

///a free function to make export the CSV file from file name, fields and values
public func exportCSV(_ filename:String, fields: [String], values: NSArray) -> String{
  return CSVExport.export.exportCSV(filename: filename, fields: fields as NSArray, values: values);
}

///a free function to make export the CSV file from file name, fields and values
public func exportCSV(_ filename:String, fields: [String], values: String) -> String{

  // Convert String into NSArray of objects.
  if let data = (values as NSString).data(using: String.Encoding.utf8.rawValue)
  {
    do {
      let parsedObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSArray
      if parsedObject.count > 0
      {
        return CSVExport.export.exportCSV(filename: filename, fields: fields as NSArray, values: parsedObject);
      }
    } catch  {
      print("error handling...\(error)")
      return "";
    }
  }
  return "";
}

///a free function to make read the CSV file
public func readCSV(_ filePath:String) -> NSMutableDictionary{
  return CSVExport.export.read(filepath: filePath);
}

///a free function to make read the CSV file
public func readCSVFromDefaultPath(_ fileName:String) -> NSMutableDictionary{
  return CSVExport.export.read(filename: fileName);
}


