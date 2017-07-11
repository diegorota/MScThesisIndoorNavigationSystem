//
//  MedicalCenterMapViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 29/04/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class MedicalCenterMapViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mapScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    // Variabili necessarie per zoom e posizione freccia su mappa
    var minZoom: Double!
    var maxZoom: Double!
    var imageWidth: CGFloat!
    var imageHeight: CGFloat!
    let realImageWidth: CGFloat = 833
    let realImageHeight: CGFloat = 574
    
    // View della freccia
    var arrowView: UIView!
    
    var POIPosition: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Memorizzo altezza e larghezza dell'immagine. Verranno usate per le proporzioni dello zoom della mappa
        imageWidth = imageView.frame.width
        imageHeight = imageView.frame.height
        
        // Chiamo la funzione per adattare lo zoom della mappa alla larghezza del display
        setMapZoom(size: view.frame.size)
        
        // Setto riconoscimento doppio tocco per effettuare zoom
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        tap.numberOfTapsRequired = 2
        mapScrollView.addGestureRecognizer(tap)
        
        self.mapScrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Funzione chiamata quando si effettua un doppio tocco sulla mappa. Gestisce lo zoom.
    func zoom(sender: UIGestureRecognizer) {
        if (mapScrollView.zoomScale < 1.5) {
            mapScrollView.setZoomScale(mapScrollView.maximumZoomScale, animated: true)
        } else {
            mapScrollView.setZoomScale(mapScrollView.minimumZoomScale, animated: true)
        }
        
    }
    
    // Funzione che setta zoom massimo e minimo della mappa così da occupare sempre l'intera larghezza del diaplay.
    func setMapZoom(size: CGSize) {
        minZoom = Double(size.width.divided(by: CGFloat(imageWidth!)))
        maxZoom = 3*minZoom
        self.mapScrollView.minimumZoomScale = CGFloat(minZoom)
        self.mapScrollView.maximumZoomScale = CGFloat(maxZoom)
        self.mapScrollView.zoomScale = CGFloat(Double(size.height.divided(by: CGFloat(imageHeight!))))
    }
    
    func addArrowToMap(x: CGFloat, y: CGFloat) {
        arrowView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        let arrowImage = UIImageView()
        arrowImage.image = UIImage(named: "position_mark")?.withRenderingMode(.alwaysTemplate)
        arrowImage.tintColor = Colors.darkColor
        arrowView.addSubview(arrowImage)
        arrowImage.frame = CGRect(x:0,y:0,width:22,height:22)
        imageView.addSubview(arrowView)
        arrowView.center = normalizePosition(positionX: x, positionY: y)
        centerView(x: x, y: y)
    }
    
    // Funzione che normalizza X e Y così da proiettarle sulla mappa (conversione da mm a pixel)
    func normalizePosition(positionX: CGFloat, positionY: CGFloat) -> CGPoint {
        let newX = positionX*imageWidth/realImageWidth
        let newY = positionY*imageHeight/realImageHeight
        
        return CGPoint(x: newX, y: newY)
    }
    
    // Funzione che centra la mappa nel punto in cui si trova l'utente.
    func centerView(x: CGFloat, y: CGFloat) {
        let normalizedPosition = normalizePosition(positionX: x, positionY: y)
        self.mapScrollView.zoom(to: CGRect(origin: CGPoint(x:normalizedPosition.x-50,y: normalizedPosition.y-50), size: CGSize(width: 100, height: 100)), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Map"
        self.mapScrollView.zoomScale = 1.0
        setMapZoom(size: self.view.bounds.size)
        
        if let POIPosition = POIPosition {
            addArrowToMap(x: POIPosition.x, y: POIPosition.y)
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if navigationController?.visibleViewController?.title == "Map" {
            super.viewWillTransition(to: size, with: coordinator)
            if mapScrollView != nil {
                self.mapScrollView.zoomScale = 1.0
                setMapZoom(size: size)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
