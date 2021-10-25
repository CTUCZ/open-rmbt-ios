//
//  RMBTHistoryResult2ViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import TUSafariActivity

final class RMBTHistoryResult2ViewController: UIViewController {

    enum Section {
        case map
        case network
        case basicInfo
        case speedGraphs
        case title(_ title: String)
        case qoe
        case netInfo
        case qos
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView!
    
    private var qosItems: [Any] = []
    private var measurementItems: [Any] = []
    
    public var historyResult: RMBTHistoryResult?
    
    private var sections: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.historyResult?.timeString
        
        self.tableView.register(UINib(nibName: RMBTHistoryMapCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryMapCell.ID)
        self.tableView.register(UINib(nibName: RMBTHistoryNetworkCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryNetworkCell.ID)
        self.tableView.register(UINib(nibName: RMBTHistoryBasicInfoCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryBasicInfoCell.ID)
        self.tableView.register(UINib(nibName: RMBTHistorySpeedGrapshCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistorySpeedGrapshCell.ID)
        self.tableView.register(UINib(nibName: RMBTHistoryTitleCell.ID, bundle: nil), forCellReuseIdentifier: RMBTHistoryTitleCell.ID)
        self.tableView.register(UINib(nibName: RMBTQOEListCell.ID, bundle: nil), forCellReuseIdentifier: RMBTQOEListCell.ID)
        self.tableView.register(UINib(nibName: RMBTNetInfoListCell.ID, bundle: nil), forCellReuseIdentifier: RMBTNetInfoListCell.ID)
        self.tableView.register(UINib(nibName: RMBTQOSListCell.ID, bundle: nil), forCellReuseIdentifier: RMBTQOSListCell.ID)
        
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        self.fetchHistoryResultInformation()
        self.prepareSections()
    }
    
    private func prepareSections() {
        var sections: [Section] = []
        guard let historyResult = self.historyResult else {
            self.sections = []
            self.tableView.reloadData()
            return
        }
        
        if CLLocationCoordinate2DIsValid(historyResult.coordinate) {
            sections.append(.map)
        }
        
        if historyResult.netItems?.count ?? 0 > 0 {
            sections.append(.network)
        }
        
        sections.append(.basicInfo)
        
        if (historyResult.downloadGraph != nil) || (historyResult.uploadGraph != nil) {
            sections.append(.speedGraphs)
        }
        
        if historyResult.qoeClassificationItems?.count ?? 0 > 0 ||
            historyResult.netItems?.count ?? 0 > 0 ||
            historyResult.qosResults?.count ?? 0 > 0 {
            sections.append(.title(NSLocalizedString("Weitere Details", comment: "")))
            
            if historyResult.qoeClassificationItems?.count ?? 0 > 0 {
                sections.append(.qoe)
            }
            
            if historyResult.netItems?.count ?? 0 > 0 {
                sections.append(.netInfo)
            }
            
            if historyResult.qosResults?.count ?? 0 > 0 {
                sections.append(.qos)
            }
        }
        
        self.sections = sections
        self.tableView.reloadData()
    }
    
    private func fetchHistoryResultInformation() {
        self.historyResult?.ensureBasicDetails({ [weak self] in
            guard let self = self else { return }
            guard let historyResult = self.historyResult else { return }
            guard historyResult.dataState != .index else {
                Log.logger.error("Result not filled with basic data")
                return
            }
            
            var items: [Any] = []
            
            for item in historyResult.measurementItems ?? [] {
                items.append(item)
                
            }
            
            // Add a summary "Quality tests 100% (90/90)" row
            if (historyResult.qosResults != nil) {
                self.qosItems = historyResult.qoeClassificationItems ?? []
            }
            
            self.measurementItems = items

            historyResult.ensureSpeedGraph({ [weak self] in
                self?.prepareSections()
            })
            
            if CLLocationCoordinate2DIsValid(historyResult.coordinate) {
                self.sections.append(.map)
            }
            
            if historyResult.netItems.count > 0 {
                self.sections.append(.network)
            }
            
            self.sections.append(.basicInfo)
            
            self.sections.append(.title(NSLocalizedString("Weitere Details", comment: "")))
            
            if historyResult.qoeClassificationItems.count > 0 {
                self.sections.append(.qoe)
            }
            
            if historyResult.netItems.count > 0 {
                self.sections.append(.netInfo)
            }
            
            if historyResult.qosResults?.count ?? 0 > 0 {
                self.sections.append(.qos)
            }
            
            self.loadingIndicatorView.stopAnimating()
            self.shareButton.isEnabled = true
            self.prepareSections()
        })
    }
    
    @IBAction private func share(_ sender: Any) {
        var activities: [UIActivity]?
        var items: [Any] = []
        
        guard let historyResult = self.historyResult else { return }
        
        if let text = historyResult.shareText { items.append(text) }
        if let url = historyResult.shareURL {
            items.append(url)
            activities = [TUSafariActivity()]
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
        activityViewController.setValue(RMBTAppTitle(), forKey: "subject")
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func showQosGroup(_ item: RMBTHistoryQoSGroupResult) {
        self.performSegue(withIdentifier: "show_qos_group", sender: item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_qos_group",
           let vc = segue.destination as? RMBTHistoryQoSGroupViewController {
            vc.result = sender as? RMBTHistoryQoSGroupResult
        }
    }
}

extension RMBTHistoryResult2ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.row]
        switch section {
        case .map:
            return 116
        case .network:
            return 73
        case .basicInfo:
            return 61
        case .speedGraphs:
            return 178
        case .title(_):
            return 48
        case .qoe:
            return CGFloat(48 + (historyResult?.qoeClassificationItems.count ?? 0) * 48)
        case .netInfo:
            return CGFloat(48 + (historyResult?.netItems.count ?? 0) * 48)
        case .qos:
            return CGFloat(48 + (historyResult?.qosResults.count ?? 0) * 48)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let historyResult = self.historyResult else {
            return UITableViewCell()
        }
        let section = sections[indexPath.row]
        switch section {
        case .map:
            let mapCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryMapCell.ID, for: indexPath) as! RMBTHistoryMapCell
            mapCell.coordinate = historyResult.coordinate
            mapCell.selectionStyle = .none
            return mapCell
        case .network:
            let networkCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryNetworkCell.ID, for: indexPath) as! RMBTHistoryNetworkCell
            networkCell.networkName = (historyResult.netItems[0] as? RMBTHistoryResultItem)?.value
            networkCell.networkType = historyResult.networkTypeServerDescription
            networkCell.selectionStyle = .none
            return networkCell
        case .basicInfo:
            let networkCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryBasicInfoCell.ID, for: indexPath) as! RMBTHistoryBasicInfoCell
            networkCell.pingValue = historyResult.shortestPingMillisString
            networkCell.downloadValue = historyResult.downloadSpeedMbpsString
            networkCell.uploadValue = historyResult.uploadSpeedMbpsString
            networkCell.selectionStyle = .none
            return networkCell
        case .speedGraphs:
            let speedGraphsCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistorySpeedGrapshCell.ID, for: indexPath) as! RMBTHistorySpeedGrapshCell
            speedGraphsCell.graphs = [
                ("Download", historyResult.downloadGraph),
                ("Upload", historyResult.uploadGraph)
            ]
            speedGraphsCell.selectionStyle = .none
            return speedGraphsCell
        case .title(let title):
            let titleCell = tableView.dequeueReusableCell(withIdentifier: RMBTHistoryTitleCell.ID, for: indexPath) as! RMBTHistoryTitleCell
            titleCell.title = title
            titleCell.selectionStyle = .none
            return titleCell
        case .qoe:
            let qoeCell = tableView.dequeueReusableCell(withIdentifier: RMBTQOEListCell.ID, for: indexPath) as! RMBTQOEListCell
            qoeCell.title = NSLocalizedString("Qualität", comment: "")
            qoeCell.items = historyResult.qoeClassificationItems as? [RMBTHistoryQOEResultItem] ?? []
            qoeCell.selectionStyle = .none
            return qoeCell
        case .netInfo:
            let netInfoCell = tableView.dequeueReusableCell(withIdentifier: RMBTNetInfoListCell.ID, for: indexPath) as! RMBTNetInfoListCell
            netInfoCell.title = NSLocalizedString("Netz", comment: "")
            netInfoCell.items = historyResult.netItems as? [RMBTHistoryResultItem] ?? []
            netInfoCell.selectionStyle = .none
            return netInfoCell
        case .qos:
            let qosCell = tableView.dequeueReusableCell(withIdentifier: RMBTQOSListCell.ID, for: indexPath) as! RMBTQOSListCell
            qosCell.title = NSLocalizedString("QoS", comment: "")
            qosCell.items = historyResult.qosResults ?? []
            qosCell.selectionStyle = .none
            qosCell.onQosSelectHandler = { [weak self] item in
                self?.showQosGroup(item)
            }
            return qosCell
        }
    }
   
}
