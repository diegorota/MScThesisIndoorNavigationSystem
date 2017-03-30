//
//  MapViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var arrowView: UIView!
    
    var minZoom: Double!
    var maxZoom: Double!
    let realRoomWidth:CGFloat = 4170
    let realRoomHeight:CGFloat = 4650
    var imageWidth: CGFloat!
    var imageHeight: CGFloat!
    var lastPosition: CGPoint?
    var lastHeading: CGFloat?
    var firstPosition = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        
        // Memorizzo altezza e larghezza dell'immagine. Verranno usate per le proporzioni dello zoom della mappa
        imageWidth = imageView.frame.width
        imageHeight = imageView.frame.height
        
        // Chiamo la funzione per adattare lo zoom della mappa alla larghezza del display
        setMapZoom(size: view.frame.size)
        
        // Setto riconoscimento doppio tocco per effettuare zoom
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
        
        updateMap(x: CGFloat(1000), y: CGFloat(1100), heading: CGFloat(180))

    }
    
    func updateMap(x: CGFloat, y: CGFloat, heading: CGFloat) {
        lastPosition = normalizePosition(meterX: x, meterY: y)
        var deltaHeading: CGFloat
        
        if let lastHeading = lastHeading {
            deltaHeading = heading - lastHeading
        } else {
            deltaHeading = 0
        }
        lastHeading = heading
        
        if firstPosition {
            addArrowToMap()
            arrowView.center = lastPosition!
            arrowView.transform = CGAffineTransform(rotationAngle: lastHeading!)
            firstPosition = false
        } else {
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                //self.arrowView.transform = CGAffineTransform(translationX: self.lastPosition!.x, y: self.lastPosition!.y)
                self.arrowView.transform = CGAffineTransform(rotationAngle: deltaHeading)
                self.arrowView.center = self.lastPosition!
            })
        }
    }
    
    //Funzione che genera la freccia che comparirà sulla mappa per mostrare posizione utente
    func addArrowToMap() {
        arrowView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        let arrowImage = UIImageView()
        arrowImage.image = UIImage(named: "arrow")
        arrowView.addSubview(arrowImage)
        arrowImage.frame = CGRect(x:0,y:0,width:22,height:22)
        imageView.addSubview(arrowView)
    }
    
    // Funzione che normalizza X e Y passate da Pozyx così da proiettarle sulla mappa (conversione da mm a pixel)
    func normalizePosition(meterX: CGFloat, meterY: CGFloat) -> CGPoint {
        let newX = meterX*(imageView.image?.size.width)!/realRoomWidth
        let newY = meterY*(imageView.image?.size.height)!/realRoomHeight
        return CGPoint(x: newX, y: normalizeYAxes(y: newY))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Funzione chiamata quando si effettua un dippio tocco sulla mappa. Gestisce lo zoom.
    func zoom(sender: UIGestureRecognizer) {
        if (scrollView.zoomScale < 1.5) {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    // Funzione che inverte l'asse Y
    func normalizeYAxes(y: CGFloat) -> CGFloat {
        return CGFloat(imageHeight-y)
    }
    
    // Funzione che setta zoom massimo e minimo della mappa così da occupare sempre l'intera larghezza del diaplay.
    func setMapZoom(size: CGSize) {
        minZoom = Double(size.width.divided(by: CGFloat(imageWidth!)))
        maxZoom = 3*minZoom
        self.scrollView.minimumZoomScale = CGFloat(minZoom)
        self.scrollView.maximumZoomScale = CGFloat(maxZoom)
        self.scrollView.zoomScale = CGFloat(minZoom)
    }

    // Funzione che centra la mappa nel punto in cui si trova l'utente.
    @IBAction func centerView(_ sender: UIButton) {
        self.scrollView.zoom(to: CGRect(origin: CGPoint(x:(lastPosition?.x)!-50,y:(lastPosition?.y)!-50), size: CGSize(width: 100, height: 100)), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Map"
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.scrollView.zoomScale = CGFloat(1)
        setMapZoom(size: size)
    }
    
}
