/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation

// TODO: rewrite to seperate files
enum RMBTMapOptionsMapViewType: UInt {
    case standard = 0
    case satellite
    case hybrid
}

public let MapOptionResponseOverlayAuto = MapOptionResponse.MapOverlays(identifier: "auto", title: NSLocalizedString("map.options.overlay.auto", value: "Auto", comment: "Map overlay description"), isDefault: true)

public let RMBTMapOptionsOverlayAuto = RMBTMapOptionsOverlay(
    identifier: "auto",
    localizedDescription: NSLocalizedString("Auto", value: "Auto", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map switches automatically between heatmap and points", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlayHeatmap = RMBTMapOptionsOverlay(
    identifier: "heatmap",
    localizedDescription: NSLocalizedString("Heatmap", value: "Heatmap", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as heatmap", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlayPoints = RMBTMapOptionsOverlay(
    identifier: "points",
    localizedDescription: NSLocalizedString("Points", value: "Points", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as points", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlayShapes = RMBTMapOptionsOverlay(
    identifier: "shapes",
    localizedDescription: NSLocalizedString("map.options.overlay.shapes", value: "Shapes", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as community shapes", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlayRegions = RMBTMapOptionsOverlay(
    identifier: "regions",
    localizedDescription: NSLocalizedString("Regions", value: "Regions", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as regions", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlayMunicipality = RMBTMapOptionsOverlay(
    identifier: "municipality",
    localizedDescription: NSLocalizedString("Municipality", value: "Municipality", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as municipality", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlaySettlements = RMBTMapOptionsOverlay(
    identifier: "settlements",
    localizedDescription: NSLocalizedString("Settlements", value: "Settlements", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as settlements", comment: "Map overlay summary")
)

public let RMBTMapOptionsOverlayWhitespots = RMBTMapOptionsOverlay(
    identifier: "whitespots",
    localizedDescription: NSLocalizedString("Whitespots", value: "White spots", comment: "Map overlay description"),
    localizedSummary: NSLocalizedString("Map shows tests as whitespots", comment: "Map overlay summary")
)

public let RMBTMapOptionsToastInfoTitle = "title"
public let RMBTMapOptionsToastInfoKeys = "keys"
public let RMBTMapOptionsToastInfoValues = "values"

final class RMBTMapOptions {
    public var oldOverlays: [RMBTMapOptionsOverlay] = []
    public var oldActiveSubtype: RMBTMapOptionsSubtype?
    public var oldActiveOverlay: RMBTMapOptionsOverlay?
    public var oldMapViewType: RMBTMapOptionsMapViewType?
    public var oldTypes: [RMBTMapOptionsType] = []
    ///
    public init(response: MapOptionResponse, isSkipOperators: Bool = false, defaultMapViewType: RMBTMapOptionsMapViewType = .standard) {
        
        oldOverlays = [RMBTMapOptionsOverlayAuto, RMBTMapOptionsOverlayHeatmap, RMBTMapOptionsOverlayPoints, RMBTMapOptionsOverlayShapes]

        let filters = response.mapFiltersOld
        let mapTypes = response.mapTypesOld
        
        oldTypes = []

        for typeResponse in mapTypes {
            let type = RMBTMapOptionsType(response: typeResponse.toJSON())
            oldTypes.append(type)
            
            // Process filters for this type
            for filterResponse in filters[type.identifier] as? [[String: Any]] ?? [] {
                let filter = RMBTMapOptionsFilter(with: filterResponse)
                type.add(filter)
            }
        }
        

        // Select first subtype of first type as active per default
        oldActiveSubtype = oldTypes[0].subtypes[0]
        oldActiveOverlay = RMBTMapOptionsOverlayAuto

        oldMapViewType = .standard
        self.restoreSelection()
    }
    
    ///
    public func saveSelection() {
        let selection = RMBTMapOptionsSelection()

        selection.subtypeIdentifier = oldActiveSubtype?.identifier
        selection.overlayIdentifier = oldActiveOverlay?.identifier
        
        var activeFilters: [String: Any] = [:]
        for f in oldActiveSubtype?.type?.filters ?? [] {
            activeFilters[f.title] = f.activeValue?.title
        }
        selection.activeFilters = activeFilters

        RMBTSettings.shared.mapOptionsSelection = selection
    }

    ///
    fileprivate func restoreSelection() {
        let selection: RMBTMapOptionsSelection = RMBTSettings.shared.mapOptionsSelection

        if let id = selection.subtypeIdentifier {
            for t in oldTypes {
                let st = t.subtypes.first(where: { (type) -> Bool in
                    return type.identifier == id
                })
                if st != nil {
                    oldActiveSubtype = st
                    break
                } else if t.identifier == selection.subtypeIdentifier {
                    oldActiveSubtype = t.subtypes[0]
                }
            }
        }
        
        if let id = selection.overlayIdentifier {
            for o in oldOverlays {
                if o.identifier == id {
                    oldActiveOverlay = o
                    break
                }
            }
        }

        if let activeFilters = selection.activeFilters {
            for f in oldActiveSubtype?.type?.filters ?? [] {
                if let activeFilterValueTitle = activeFilters[f.title] as? String {
                    if let v = f.possibleValues.first(where: { fv in
                        return fv.title == activeFilterValueTitle
                    }) {
                        f.activeValue = v
                    }
                }
            }
        }
    }
}

// Used to persist selected map options between map views
final public class RMBTMapOptionsSelection: NSObject {
    @objc public var subtypeIdentifier: String?
    @objc public var overlayIdentifier: String?
    public var typeIdentifier: String?
    @objc public var activeFilters: [String: Any]?

    public var countryIdentifier: String?
    public var periodIdentifier: Int?
    public var cellularTypes: [Int] = []
}

@objc final class RMBTMapOptionsFilterValue: NSObject {
    @objc public var title: String
    @objc public var summary: String
    public var isDefault: Bool
    @objc public var info: [String: Any]
    
    public init(with response: [String: Any]) {
        title = response["title"] as? String ?? ""
        summary = response["summary"] as? String ?? ""
        isDefault = response["default"] as? Bool ?? false
        
        var r = response
        r["title"] = nil
        r["summary"] = nil
        r["default"] = nil
        
        info = response
        for (key, value) in r {
            guard let value = value as? String else { continue }
            if value.isEmpty {
                info[key] = nil
            }
        }
    }
}

