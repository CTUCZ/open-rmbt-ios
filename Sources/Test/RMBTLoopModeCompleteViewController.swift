//
//  RMBTLoopModeCompleteViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 02.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

final class RMBTLoopModeCompleteViewController: UIViewController {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var onRunAgainHandler: () -> Void = {}
    var onResultsHandler: () -> Void = {}
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    private func initUI() {
        self.titleLabel.text = .title
        self.subtitleLabel.text = .titleDescription
        self.resultsButton.setTitle(.results, for: .normal)
        self.homeButton.setTitle(.runAgain, for: .normal)
    }
    
    @IBAction func resultsButtonClick(_ sender: Any) {
        onResultsHandler()
    }
    
    @IBAction func homeButtonClick(_ sender: Any) {
        onRunAgainHandler()
    }
}

private extension String {
    static let title = NSLocalizedString("loop_mode_finished", comment: "")
    static let titleDescription = NSLocalizedString("loop_mode_finished_description", comment: "")
    static let results = NSLocalizedString("loop_continue_to_results", comment: "")
    static let runAgain = NSLocalizedString("loop_run_again", comment: "")
}
