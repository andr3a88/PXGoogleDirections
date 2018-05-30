//
//  ItineraryToolbarController.swift
//  PXGoogleDirectionsSample
//
//  Created by Andrea Stevanato on 23/04/2018.
//  Copyright © 2018 RLT. All rights reserved.
//

import UIKit

protocol ItineraryToolbarDelegate: class {

    func itineraryToolbarBackButton()
    func itineraryToolbarSwitchButton()
    func itineraryToolbarTextFieldBeginEditing()
}

class ItineraryToolbarController: UIViewController, UITextFieldDelegate {

    // MARK: IBOutlets

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var switchLocationButton: UIButton!

    // MARK: Properties

    weak var delegate: ItineraryToolbarDelegate?
    
    // MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.itineraryToolbarTextFieldBeginEditing()
    }

    // MARK: Actions
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.delegate?.itineraryToolbarBackButton()
    }

    @IBAction func didTapOnSwitchButton(_ sender: Any) {
        self.delegate?.itineraryToolbarSwitchButton()
    }
}
