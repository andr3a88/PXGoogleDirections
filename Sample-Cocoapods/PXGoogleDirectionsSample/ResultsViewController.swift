//
//  ResultsViewController.swift
//  PXGoogleDirectionsSample
//
//  Created by Romain on 21/03/2015.
//  Copyright (c) 2015 Poulpix. All rights reserved.
//

import UIKit
import PXGoogleDirections
import GoogleMaps

class ResultsViewController: UIViewController{
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var routesLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var directions: UITableView!
    var request: PXGoogleDirections!
    var results: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRoute()
    }

    @IBAction func previousButtonTouched(_ sender: UIButton) {
        routeIndex -= 1
        updateRoute()
    }

    @IBAction func nextButtonTouched(_ sender: UIButton) {
        routeIndex += 1
        updateRoute()
    }

    @IBAction func closeButtonTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func openInGoogleMapsButtonTouched(_ sender: UIButton) {
        if !request.openInGoogleMaps(center: nil, mapMode: .streetView, view: Set(arrayLiteral: PXGoogleMapsView.satellite, PXGoogleMapsView.traffic, PXGoogleMapsView.transit), zoom: 15, callbackURL: URL(string: "pxsample://"), callbackName: "PXSample") {
            let alert = UIAlertController(title: "PXGoogleDirectionsSample", message: "Could not launch the Google Maps app. Maybe this app is not installed on this device?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func updateRoute() {
        prevButton.isEnabled = (routeIndex > 0)
        nextButton.isEnabled = (routeIndex < (results).count - 1)
        routesLabel.text = "\(routeIndex + 1) of \((results).count)"
        mapView.clear()
        for i in 0 ..< results.count {
            if i != routeIndex {
                results[i].drawOnMap(mapView, approximate: false, strokeColor: UIColor.lightGray, strokeWidth: 3.0)
            }
        }
        mapView.animate(with: GMSCameraUpdate.fit(results[routeIndex].bounds!, withPadding: 40.0))
        results[routeIndex].drawOnMap(mapView, approximate: false, strokeColor: UIColor.purple, strokeWidth: 4.0)
        results[routeIndex].drawOriginMarkerOnMap(mapView, title: "Origin", color: UIColor.green, opacity: 1.0, flat: true)
        results[routeIndex].drawDestinationMarkerOnMap(mapView, title: "Destination", color: UIColor.red, opacity: 1.0, flat: true)
        directions.reloadData()
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let index = self.shouldSelectPath(mapView, coordinate: coordinate, routes: results, currentRouteIndex: routeIndex) {
            routeIndex = index
            updateRoute()
        }
    }

    private func shouldSelectPath(_ mapView: GMSMapView, coordinate: CLLocationCoordinate2D, routes: [PXGoogleDirectionsRoute], currentRouteIndex: Int) -> Int? {
        for (index, route) in routes.enumerated() where index != currentRouteIndex  {
            if self.getMinDistance(mapView, path: route.path!, coordinate: coordinate) < 20 {
                return index
            }
        }
        return nil
    }

    private func getMinDistance(_ mapView: GMSMapView, path: GMSPath, coordinate: CLLocationCoordinate2D) -> Double {
        var minDistance: Double = Double.infinity
        for pathPointIndex in 0..<path.count() {
            let pathCoordinate = path.coordinate(at: pathPointIndex)
            let distance = mapView.distanceInPoints(coordinate1: coordinate, coordinate2: pathCoordinate)
            if distance < minDistance {
                minDistance = distance
            }
        }
        return minDistance
    }
}

extension ResultsViewController: GMSMapViewDelegate {
}

extension ResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (results[routeIndex].legs).count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (results[routeIndex].legs[section].steps).count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let leg = results[routeIndex].legs[section]
        if let dist = leg.distance?.description, let dur = leg.duration?.description {
            return "Step \(section + 1) (\(dist), \(dur))"
        } else {
            return "Step \(section + 1)"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RouteStep")
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RouteStep")
        }
        let step = results[routeIndex].legs[indexPath.section].steps[indexPath.row]
        if let instr = step.rawInstructions {
            cell!.textLabel!.text = instr
        }
        if let dist = step.distance?.description, let dur = step.duration?.description {
            cell!.detailTextLabel?.text = "\(dist), \(dur)"
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let step = results[routeIndex].legs[indexPath.section].steps[indexPath.row]
        mapView.animate(with: GMSCameraUpdate.fit(step.bounds!, withPadding: 40.0))
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let step = results[routeIndex].legs[indexPath.section].steps[indexPath.row]
        var msg: String
        if let m = step.maneuver {
            msg = "\(step.rawInstructions!)\nGPS instruction: \(m)\nFrom: (\(step.startLocation!.latitude); \(step.startLocation!.longitude))\nTo: (\(step.endLocation!.latitude); \(step.endLocation!.longitude))"
        } else {
            msg = "\(step.rawInstructions!)\nFrom: (\(step.startLocation!.latitude); \(step.startLocation!.longitude))\nTo: (\(step.endLocation!.latitude); \(step.endLocation!.longitude))"
        }
        let alert = UIAlertController(title: "PXGoogleDirectionsSample", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ResultsViewController: UITableViewDelegate {
}

extension GMSMapView {

    /// Returns the distance in point between CLLocationCoordinate2D
    ///
    /// - Parameters:
    ///   - coordinate1: The first coordinate
    ///   - coordinate2: The second coordinate
    /// - Returns: The distance
    func distanceInPoints(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> Double {
        let selectedPoint = self.projection.point(for: coordinate1)
        let pathPoint = self.projection.point(for: coordinate2)
        return Double(selectedPoint.distance(toPoint: pathPoint))
    }
}

extension CGPoint {

    /// Get the distance from a point
    ///
    /// - Parameter p: The point
    /// - Returns: The distance
    func distance(toPoint p:CGPoint) -> CGFloat {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
}
