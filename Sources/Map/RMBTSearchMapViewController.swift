//
//  RMBTSearchMapViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 29.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import MapKit

class RMBTSearchMapViewController: UIViewController {
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    var onFindItem: (_ item: MKMapItem?) -> Void = { _ in }
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    private var places: [MKMapItem]?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        self.searchButton.isEnabled = !(self.searchTextField.text?.isEmpty ?? true)
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonClick(_ sender: Any) {
        self.search()
    }
    
    func search() {
        self.search(for: searchTextField.text)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
//        searchRequest.region = boundingRegion
        
        // Include only point of interest results. This excludes results based on address matches.
        if #available(iOS 13.0, *) {
            searchRequest.resultTypes = [.pointOfInterest, .address]
        }
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                self.displaySearchError(error)
                return
            }
            
            self.places = response?.mapItems
            
            if self.places?.count ?? 0 > 0 {
                self.onFindItem(self.places?.first)
                self.dismiss(animated: true, completion: nil)
            } else {
                UIAlertController.presentAlert(title: "Not found anything", text: nil) { _ in }
            }
        }
    }
    
    func displaySearchError(_ error: Error?) {
        UIAlertController.presentAlert(title: error?.localizedDescription, text: nil) { _ in }
    }
    
    @objc func keyboardDidChange(_ notification: Notification) {
        let userInfo = notification.userInfo
        guard let frame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let selfFrame = self.view.convert(self.view.frame, to: self.view.window)
        let middleOfScreen = (selfFrame.height + selfFrame.origin.y) / 2
        var bottomOffset = middleOfScreen - ((selfFrame.height + selfFrame.origin.y) - frame.origin.y / 2)
        if bottomOffset > 0 {
            bottomOffset = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.centerConstraint.constant = bottomOffset
            self.view.layoutIfNeeded()
        }
    }
}
