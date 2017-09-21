//
//  SelectModeViewController.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Cocoa

class SelectModeViewController: NSViewController {

  @IBOutlet weak var rawDataRadioButton: NSButton!
  @IBOutlet weak var rawClassifiedDataRadioButton: NSButton!
  @IBOutlet weak var classifiedDataRadioButton: NSButton!
  var selectedButton: NSButton?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func didSelectRadioButton(_ sender: NSButton) {
    selectedButton = sender
  }

  @IBAction func didSelectConfirmButton(_ sender: NSButton) {
    selectedButton
      .flatMap(createViewModel)
      .flatMap(pushNextViewController)
    
  }

  func createViewModel(forButton button: NSButton) -> SelectDataViewModel {
    switch button {
    case rawDataRadioButton: return RawDataViewModel()
    case rawClassifiedDataRadioButton: return RawClassifiedDataViewModel()
    case classifiedDataRadioButton: return ClassifiedDataViewModel()
    default: fatalError("Did't match any option")
    }
  }

  func pushNextViewController(withViewModel viewModel: SelectDataViewModel) -> Void {
    let appDelegate = NSApp.delegate as? AppDelegate
    appDelegate?.showSelectDataViewController(withViewModel: viewModel)
  }
}

