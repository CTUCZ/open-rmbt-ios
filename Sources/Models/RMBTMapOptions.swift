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

public let RMBTMapOptionCountryAll = RMBTMapOptionCountry(code: "all", name: NSLocalizedString("map.options.filter.all_countries", comment: "All Countries"))

public let RMBTMapOptionsToastInfoTitle = "title"

public let RMBTMapOptionsToastInfoKeys = "keys"

public let RMBTMapOptionsToastInfoValues = "values"

final class RMBTMapOptions {
    public var mapViewType: RMBTMapOptionsMapViewType = .standard

    public var overlays: [MapOptionResponse.MapOverlays] = []
    public var periodFilters: [MapOptionResponse.MapPeriodFilters] = []
    public var mapCellularTypes: [MapOptionResponse.MapCellularTypes] = []
    
    public var types: [MapOptionResponse.MapType] = []
    public var subTypes: [MapOptionResponse.MapSubType] = []

    public var activeOverlay: MapOptionResponse.MapOverlays = MapOptionResponseOverlayAuto
    public var activePeriodFilter: MapOptionResponse.MapPeriodFilters?
    public var activeCellularTypes: [MapOptionResponse.MapCellularTypes] = []
    public var activeType: MapOptionResponse.MapType?
    public var activeSubtype: MapOptionResponse.MapSubType?
    
    public var operatorsForCountry: [OperatorsResponse.Operator] = []
    public var activeOperator: OperatorsResponse.Operator?
    public var defaultOperator: OperatorsResponse.Operator? {
        get {
            for op in operatorsForCountry {
                if op.isDefault {
                    return op
                }
            }
            
            return nil
        }
    }
    
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

//        response = response[@"mapfilter"]; // Root element, always the same
//        NSParameterAssert(response);
        
//        NSDictionary* filters = response[@"mapFilters"];

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

        // ..then try to actually select options from app state, if we have one
//        [self restoreSelection];
        
        
        
        
        
//        self.mapViewType = defaultMapViewType
//        // TODO: Check response
//        //Set overlays
//        self.activeOverlay = response.mapOverlays.first(where: { (overlay) -> Bool in
//            return overlay.isDefault == true
//        }) ?? MapOptionResponseOverlayAuto
////        overlays.append(MapOptionResponseOverlayAuto)
//        overlays.append(contentsOf: response.mapOverlays)
//
//        //Set period
//        periodFilters = response.mapPeriodFilters
//
//        self.activePeriodFilter = periodFilters.first(where: { (period) -> Bool in
//            return period.isDefault == true
//        })
//
//        if activePeriodFilter == nil {
//            activePeriodFilter = periodFilters.first
//        }
//
//        //Set technologies
//        self.mapCellularTypes = response.mapCellularTypes
//        for type in self.mapCellularTypes {
//            if type.isDefault == true {
//                self.activeCellularTypes.append(type)
//            }
//        }
//
//        self.types = response.mapTypes
//        self.subTypes = response.mapSubTypes
//
//        self.activeType = types.first(where: { (type) -> Bool in
//            return type.isDefault == true
//        })
//
//        if activeType == nil {
//            activeType = types.first
//        }
//
//        self.activeSubtype = subTypes.first(where: { (type) -> Bool in
//            return type.isDefault == true
//        })
//
//        if activeSubtype == nil {
//            activeSubtype = subTypes.first
//        }
//
//        if self.countries.count > 0 {
//            self.activeCountry = self.countries.first(where: { (country) -> Bool in
//                return country.isDefault == true
//            })
//            if self.activeCountry == nil {
//                self.activeCountry = self.countries.first
//            }
//        }
//
//        if let mapViewIndex = response.mapLayouts.firstIndex(where: { (layout) -> Bool in
//            return layout.isDefault == true
//        }),
//            let mapViewType = RMBTMapOptionsMapViewType(rawValue: mapViewIndex) {
//            self.mapViewType = mapViewType
//        } else {
//            self.mapViewType = .standard
//        }
        
        self.restoreSelection()
    }
    
    public func merge(with previousMapOptions: RMBTMapOptions) {
        self.activeOverlay = previousMapOptions.activeOverlay
        self.activeSubtype = previousMapOptions.activeSubtype
        self.activeOperator = previousMapOptions.activeOperator
        self.operatorsForCountry = previousMapOptions.operatorsForCountry
        self.mapViewType = previousMapOptions.mapViewType
        
        // ..then try to actually select options from app state, if we have one
        restoreSelection()
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
        
//        selection.subtypeIdentifier = activeSubtype?.id.rawValue ?? ""
//        selection.typeIdentifier = activeType?.id.rawValue ?? ""
//        selection.overlayIdentifier = activeOverlay.identifier
//        selection.countryIdentifier = activeCountry?.code ?? ""
//        selection.periodIdentifier = activePeriodFilter?.period ?? 180
//        selection.cellularTypes = activeCellularTypes.map({ (type) -> Int in
//            return type.id ?? 0
//        })
//
        
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
        
//        let selection: RMBTMapOptionsSelection = RMBTSettings.shared.mapOptionsSelection
//
//        if let id = selection.subtypeIdentifier {
//            activeSubtype = self.subTypes.first(where: { (type) -> Bool in
//                return type.id.rawValue == id
//            })
//        }
//        if let id = selection.typeIdentifier {
//            activeType = self.types.first(where: { (type) -> Bool in
//                return type.id.rawValue == id
//            })
//        }
//        if let id = selection.overlayIdentifier {
//            activeOverlay = self.overlays.first(where: { (overlay) -> Bool in
//                return overlay.identifier == id
//            }) ?? MapOptionResponseOverlayAuto
//        }
//        if let countryIdentifier = selection.countryIdentifier {
//            activeCountry = self.countries.first(where: { (country) -> Bool in
//                return country.code?.lowercased() == countryIdentifier.lowercased()
//            })
//        }
//        if let id = selection.periodIdentifier {
//            activePeriodFilter = self.periodFilters.first(where: { (period) -> Bool in
//                return period.period == id
//            })
//        }
//        if selection.cellularTypes.count > 0 {
//            activeCellularTypes = mapCellularTypes.filter({ (type) -> Bool in
//                return selection.cellularTypes.contains(type.id ?? 0)
//            })
//        }
    }
    
    public func subTypes(for type: MapOptionResponse.MapType) -> [MapOptionResponse.MapSubType] {
        var subtypes: [MapOptionResponse.MapSubType] = []
        
        for index in type.mapSubTypeOptions {
            if let subtype = self.subTypes.first(where: { (type) -> Bool in
                return type.index == index
            }) {
                subtypes.append(subtype)
            }
        }
        
        return subtypes
    }
    
    ///
    public func paramsDictionary() -> [String: Any] {
        var params: [String: Any] = [:]
        if let activeType = self.activeType,
            let activeSubType = self.activeSubtype {
            params["map_options"] = activeType.id.rawValue + "/" + activeSubType.id.rawValue
        }
        if let activePeriod = self.activePeriodFilter {
            params["period"] = activePeriod.period
        } else {
            params["period"] = 180
        }
        if self.activeType?.id == .cell {
            if self.activeCellularTypes.count > 0 {
                params["technology"] = self.activeCellularTypes.map({ (type) -> String in
                    return String(type.id ?? 0)
                }).joined(separator: "")
            }
        }
        
        if let activeOperator = self.activeOperator {
            params["provider"] = activeOperator.providerForRequest
        } else {
            params["provider"] = ""
        }
        
        return params
    }
    
    ///
    public func markerParamsDictionary() -> [String: Any] {
        var params: [String: Any] = [:]
        var optionsParams: [String: Any] = [:]
        var filterParams: [String: Any] = [:]
        if let activeType = self.activeType,
            let activeSubType = self.activeSubtype {
            optionsParams["map_options"] = activeType.id.rawValue + "/" + activeSubType.id.rawValue
        }
        optionsParams["overlay_type"] = activeOverlay.identifier
        if let activePeriod = self.activePeriodFilter {
            filterParams["period"] = activePeriod.period
        } else {
            filterParams["period"] = 6
        }
        if self.activeCellularTypes.count > 0 {
            filterParams["technology"] = self.activeCellularTypes.map({ (type) -> String in
                return String(type.id ?? 0)
            }).joined(separator: "")
        }
        if let activeOperator = self.activeOperator {
            filterParams["mobile_provider_name"] = activeOperator.title
        }
        
        params["options"] = optionsParams
        params["filter"] = filterParams
        return params
    }

}

open class RMBTMapOptionCountry: Equatable {
    open var code: String?
    open var name: String?
    open var isDefault: Bool = false
    
    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    
    init(response: [String: Any]) {
        self.code = response["country_code"] as? String
        self.name = response["country_name"] as? String
    }
    
    public static func == (lhs: RMBTMapOptionCountry, rhs: RMBTMapOptionCountry) -> Bool {
        return lhs.code == rhs.code
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

