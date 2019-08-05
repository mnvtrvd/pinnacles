//
//  ViewController.swift
//  pinnacles
//
//  Created by Manav Trivedi on 7/31/19.
//  Copyright © 2019 E<Z<>. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let detailsImgView = UIImageView()
    let detailsView = UIView()
    let dismissButtonColor = UIImageView()
    let dismissButton = UIButton()
    let currentLocationButton = UIButton()
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height
    
    var curPin = MKAnnotationView()
    
    let detailsViewLabel: UILabel = {
        let label = UILabel()
        label.text = "Details about this location are written here"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

/****************************************************************************************************************/

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        
        detailsImgView.isHidden = true
        newDismissButton()
        newCurrentLocationButton()
        rainbow(view: dismissButtonColor, duration: 2)
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: regionInMeters,
                                                 longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            
            self.currentLocationButton.tintColor = UIColor(red: 0, green: 0.75, blue: 1, alpha: 1.0)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // notify turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // notify restrictions are on
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            // notify with an error
            break
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // notify turn on permissions
        }
    }

/****************************************************************************************************************/

    func addAnnotations() {
        placePin(title: "Transamerica Pyramid", lat: 37.7952, long: -122.4028)
        placePin(title: "Bay Bridge", lat: 37.7983, long: -122.3778)
        placePin(title: "Alcatraz Island", lat: 37.8270, long: -122.4230)
        placePin(title: "Oracle Park", lat: 37.7786, long: -122.3893)
        placePin(title: "The Castro Theatre", lat: 37.7620, long: -122.4348)
        placePin(title: "Fisherman's Wharf", lat: 37.8080, long: -122.4177)
        placePin(title: "De Young Museum", lat: 37.7715, long: -122.4687)
    }
    
    func placePin(title: NSString, lat: Double, long: Double) {
        let pin = MKPointAnnotation()
        pin.title = title as String
        pin.coordinate = CLLocationCoordinate2D(latitude: lat,
                                                longitude: long)
        
        mapView.addAnnotation(pin)
    }
}

/****************************************************************************************************************/

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate,
                                             latitudinalMeters: regionInMeters,
                                             longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        addAnnotations()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

/****************************************************************************************************************/


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // make image hidden if the user isn't going to click on it for detail view
        detailsImgView.isHidden = true
        
        self.currentLocationButton.tintColor = .lightGray
        
        // attempt to deselect annotations if panning
        curPin.isSelected = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("The annotation was selected: \(String(describing: view.annotation?.title))")
        
        if let pinLoc = view.annotation?.coordinate {
            let region = MKCoordinateRegion.init(center: pinLoc,
                                                 latitudinalMeters: mapView.region.center.latitude*50,
                                                 longitudinalMeters: mapView.region.center.latitude*50)
            
            mapView.setRegion(region, animated: true)
            
            UIView.animate(withDuration: 0.3, delay: 0.0,
                           options: UIView.AnimationOptions.curveLinear, animations: {
                
            }, completion: {(finished:Bool) in
                self.expandImg(pin: view)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation,
                                              reuseIdentifier: "AnnotationView")
        }
        
        if let title = annotation.title, title == "Transamerica Pyramid" {
            if let pinImage = UIImage(named: "pyramid") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        } else if let title = annotation.title, title == "Bay Bridge" {
            if let pinImage = UIImage(named: "bridge") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        } else if let title = annotation.title, title == "Alcatraz Island" {
            if let pinImage = UIImage(named: "island") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        } else if let title = annotation.title, title == "Oracle Park" {
            if let pinImage = UIImage(named: "park") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        } else if let title = annotation.title, title == "The Castro Theatre" {
            if let pinImage = UIImage(named: "theatre") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        } else if let title = annotation.title, title == "Fisherman's Wharf" {
            if let pinImage = UIImage(named: "wharf") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        } else if let title = annotation.title, title == "De Young Museum" {
            // plan to make this else once i figure out how to ignore current location
            if let pinImage = UIImage(named: "defaultPin") {
                annotationView?.image = resizeImg(img: pinImage, small: true)
            }
        }
        
        annotationView?.canShowCallout = true
        
        return annotationView
    }

/****************************************************************************************************************/
    
    func newCurrentLocationButton() {
        currentLocationButton.alpha = 1.0
        currentLocationButton.setBackgroundImage(UIImage(named: "currentLocation"),
                                                 for: UIControl.State.normal)
        self.currentLocationButton.tintColor = UIColor(red: 0, green: 0.75, blue: 1, alpha: 1.0)
        currentLocationButton.addTarget(self, action: #selector(centerOnLocation),
                                        for: .touchUpInside)
        
        currentLocationButton.frame = CGRect(x: screenW-75, y: screenH-75,
                                             width: 50, height: 50)
        
        self.view.addSubview(currentLocationButton)
    }
    
    func newDetailsImgView() {
        detailsImgView.isUserInteractionEnabled = true
        detailsImgView.contentMode = .scaleAspectFill
        detailsImgView.clipsToBounds = true
        detailsImgView.isHidden = false
        
        detailsImgView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(animateDetailsView)))
        
        let swipeDown = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(dismissDetailsView))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func newDetailsView() {
        detailsView.backgroundColor = UIColor.white
        self.view.addSubview(detailsView)

        detailsView.addSubview(detailsViewLabel)
        detailsView.addConstraintsWithFormat(hor: "H:|[v0]|", vert: "V:|[v0]|",
                                             views: detailsViewLabel)
        
        self.view.bringSubviewToFront(self.detailsImgView)
    }
    
    func newDismissButton() {
        dismissButton.setBackgroundImage(UIImage(named: "homePin"),
                                         for: UIControl.State.normal)
        dismissButtonColor.image = UIImage(named: "homePinColor")
        
        dismissButton.tintColor = .white
        dismissButtonColor.tintColor = .red
        
        dismissButton.addTarget(self, action: #selector(pinButtonClicked),
                                for: .touchUpInside)
        
        let homeFrame = CGRect(x: screenW/2-35, y: screenH-114,
                               width: 70, height: 94)
        self.applyHomeFrame(frame: homeFrame)
        
        self.view.addSubview(dismissButtonColor)
        self.view.addSubview(dismissButton)
    }

/****************************************************************************************************************/
    
    func resizeImg(img: UIImage, small: Bool) -> UIImage {
        let w = img.size.width
        let h = img.size.height
        
        if small {
            let newH = (50/w)*h
            return img.resize(x: 0, y: 0, w: 50, h: newH)
        }
        
        let newH = (screenW/w)*h
        return img.resize(x: 0, y: 0, w: screenW, h: newH)
    }
    
    @objc func centerOnLocation() {
        centerViewOnUserLocation()
    }

    func expandImg(pin: MKAnnotationView) {
        if let w = pin.image?.size.width {
            if let h = pin.image?.size.height {
                newDetailsImgView()
                detailsImgView.frame = CGRect(x: (screenW - w)/2,
                                              y: (screenH - h)/2 + 5,
                                              width: w, height: h)
                detailsImgView.image = pin.image
                
                curPin = pin
                self.view.addSubview(detailsImgView)
                
        //        this will animate details view immediately on tap, rather than tap again
        //        animateDetailsView()
            }
        }
    }

/****************************************************************************************************************/
    
    @objc func animateDetailsView() {
        if let w = detailsImgView.image?.size.width {
            if let h = detailsImgView.image?.size.height {
                let newH = (screenW*h)/w
//                curPin.isEnabled = false

                UIView.animate(withDuration: 0.3, delay: 0.0,
                               options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.detailsImgView.frame = CGRect(x: 0, y: 0, width: self.screenW, height: newH)
                    self.dismissButton.alpha = 0.0
                    self.dismissButtonColor.alpha = 0.0
                }, completion: {(finished:Bool) in
                    self.newDetailsView()
                    self.newDismissButton()
                    self.detailsView.frame = CGRect(x: 0, y: -(self.screenH - newH),
                                                    width: self.screenW,
                                                    height: self.screenH - newH)
                    
                    let homeFrame = CGRect(x: self.screenW/2-35,
                                           y: newH-35,
                                           width: 70, height: 94)
                    self.applyHomeFrame(frame: homeFrame)
                    
                    self.bounce(obj: self.detailsImgView, up: -5, left: 0)
                    UIView.animate(withDuration: 0.3, delay: 0.0,
                                   options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.detailsView.frame = CGRect(x: 0, y: newH,
                                                        width: self.screenW,
                                                        height: self.screenH - newH)
                    }, completion: {(finished:Bool) in
                        self.fade(obj: self.dismissButton, duration: 0.5)
                        self.fade(obj: self.dismissButtonColor, duration: 0.5)
                        self.bounce(obj: self.detailsView, up: 10, left: 0)
                    })
                })
            }
        }
    }
    
    @objc func pinButtonClicked() {
        if dismissButton.frame.origin.y < screenH-114 {
            dismissDetailsView()
        } else {
            bounce(obj: dismissButton, up: 10, left: 0)
            bounce(obj: dismissButtonColor, up: 10, left: 0)
        }
        rainbow(view: dismissButtonColor, duration: 2)
    }
    
    @objc func dismissDetailsView() {
        if let w = detailsImgView.image?.size.width {
            if let h = detailsImgView.image?.size.height {
                let newH = (screenW*h)/w
        
//                curPin.isEnabled = true
                
                UIView.animate(withDuration: 0.4, delay: 0.0,
                               options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.detailsImgView.frame = CGRect(x: 0, y: self.screenH,
                                                       width: self.screenW,
                                                       height: newH)
                    self.detailsView.frame = CGRect(x: 0, y: newH+self.screenH,
                                                    width: self.screenW,
                                                    height: self.screenH - newH)
                                
                    let homeFrame = CGRect(x: self.screenW/2-35,
                                           y: newH+self.screenH-35,
                                           width: 70, height: 94)
                    self.applyHomeFrame(frame: homeFrame)
                }, completion: {(finished:Bool) in
                    self.detailsImgView.isHidden = true
                    self.animatePin()
                })
            }
        }
    }
    
    func animatePin() {
        UIView.animate(withDuration: 0.25, delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut, animations: {
            let frame = CGRect(x: self.screenW/2-35,
                               y: self.screenH-114,
                               width: 70, height: 94)
            self.applyHomeFrame(frame: frame)
        }, completion: {(finished:Bool) in
            self.bounce(obj: self.dismissButton, up: -10, left: 0)
            self.bounce(obj: self.dismissButtonColor, up: -10, left: 0)
        })
    }
    
/****************************************************************************************************************/
    
    func applyHomeFrame(frame: CGRect) {
        dismissButton.frame = frame
        dismissButtonColor.frame = frame
    }
    
    func bounce(obj: UIView, up: CGFloat, left: CGFloat) {
        let curX = obj.frame.origin.x
        let curY = obj.frame.origin.y
        let curW = obj.frame.size.width
        let curH = obj.frame.size.height
        
        UIView.animate(withDuration: 0.15, animations: {
            obj.frame = CGRect(x: curX-left, y: curY-up,
                               width: curW, height: curH)
        }, completion: {(finished:Bool) in
            UIView.animate(withDuration: 0.15, animations: {
                obj.frame = CGRect(x: curX, y: curY,
                                   width: curW, height: curH)
            })
        })
    }
    
    func fade(obj: UIView, duration: Double) {
        if obj.alpha == 0 {
            UIView.animate(withDuration: duration, animations: { obj.alpha = 1 })
        } else {
            UIView.animate(withDuration: duration, animations: { obj.alpha = 0 })
        }
    }
    
    func rainbow(view: UIView, duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            view.tintColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        }, completion: {(finished:Bool) in
            UIView.animate(withDuration: duration, animations: {
                view.tintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1.0)
            }, completion: {(finished:Bool) in
                UIView.animate(withDuration: duration, animations: {
                    view.tintColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1.0)
                }, completion: {(finished:Bool) in
                    UIView.animate(withDuration: duration, animations: {
                        view.tintColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
                    }, completion: {(finished:Bool) in
                        UIView.animate(withDuration: duration, animations: {
                            view.tintColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1.0)
                        }, completion: {(finished:Bool) in
                            UIView.animate(withDuration: duration, animations: {
                                view.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                            })
                        })
                    })
                })
            })
        })
    }
}

/****************************************************************************************************************/

extension UIImage {
    func resize(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> UIImage {
        let targetSize = CGSize.init(width: w, height: h)
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            let location = CGPoint.init(x: x, y: y)
            self.draw(in: CGRect(origin: location, size: targetSize))
        }
    }
}

/****************************************************************************************************************/

extension UIView {
    func addConstraintsWithFormat(hor: String, vert: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if hor != "" {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hor,
                                                          options: NSLayoutConstraint.FormatOptions(),
                                                          metrics: nil, views: viewsDictionary))
        }
        if vert != "" {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vert,
                                                          options: NSLayoutConstraint.FormatOptions(),
                                                          metrics: nil, views: viewsDictionary))
        }
    }
}

/****************************************************************************************************************/

/*      Features added:
 - Basic map kit and location initializations
 - When app is open, it will automatically center on the
   user's location
 - Images for pins, width is set to 50 everytime and height
   is relative
 - If pin image exists, it will be displayed, otherwise
   default pin is displayed
 - Tapping on a pin, centers and zooms view to the pin
 - If you move away from the pin, the image will be
   disabled so there isn't a random image hanging
   around on the screen
 - Tapping on pin again opens up detail view, the image
   will move to the top and grow until width is the same
   of the screen's
 - Detail view text slides out of the image, this is
   currently a UIView that can just function as a
   container view for all the details later
 - Pin fades in between image and text view
 - Bounce animations for image and detail view text
 - Tapping on detail view pin causing entire detail
   view to slide downwards
 - Swiping down on the image will accomplish the same
 - Pin will bounce back to the bottom of the screen
 - Current location button centers region to your
   location
 - If region is your location, the button will be blue,
   otherwise gray
 - "Home" pin does tiny animation evertime its clicked
  - Deselect annotations when panning
 */

/*      Issues:
 - Image gets completely blown out when enlarged
 - Trigger image after animation complete
 - Disable pin while image is active
 - Blue dot disappeared
 - Both tall and long images are bad for us, in both the
   map view and the detail view as the become too big or
   too small respectively
*/

/*      Things to still add:
 - Add pins to map view
 - Expand on the detail view
 - Dynamically swipe and move detail view
*/

/*      Ideas:
 - If UIView completely scrolled through, if the user
   scrolls more, the detail view will animate out of
   view in direction of scrolling
 - Tapping on the home pin provides options to add
   new pins, upload/take pics, etc.
 - Slightly dragging up on the home pin opens the
   drawer view, when drawer view is open, the pin
   will hide behind the drawer and swiping up again
   will hide the drawer and show the pin again
 - Swiping right and left on the image in the detail
   view will show more images
 - Swiping right and left on the text of the detail
   view will show more pin detail views
 - Consider max of 5:4 or 4:5 image ratio, anything
   else would likely make it too large or small
*/
