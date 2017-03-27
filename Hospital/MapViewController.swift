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
    var minZoom = 1.0
    var maxZoom = 3.0
    let realRoomWidth:CGFloat = 4170
    let realRoomHeight:CGFloat = 4650
    var imageWidth: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        
        minZoom = Double(view.frame.width.divided(by: imageView.frame.width))
        maxZoom = 3*minZoom
        imageWidth = imageView.frame.width
        
        self.scrollView.minimumZoomScale = CGFloat(minZoom)
        self.scrollView.maximumZoomScale = CGFloat(maxZoom)
        self.scrollView.zoomScale = CGFloat(minZoom)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
        
        let locationView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        locationView.backgroundColor = UIColor.blue

        imageView.addSubview(locationView)
        locationView.center = normalizePosition(meterX: 4170, meterY: 4650)
        print((tabBarController?.tabBar.frame.height)!)
        
//        for i in 0...100 {
//            UIView.animate(withDuration: 5, delay: 0, options: [], animations: {
//                let oldX = locationView.center.x
//                let oldY = locationView.center.y
//                locationView.transform = CGAffineTransform(translationX: oldX+CGFloat(i), y: oldY+CGFloat(i))
//            }) { [unowned self] (finished: Bool) in
//                
//            }
//        }

    }
    
    func normalizePosition(meterX: CGFloat, meterY: CGFloat) -> CGPoint {
        let newX = meterX*(imageView.image?.size.width)!/realRoomWidth
        let newY = meterY*(imageView.image?.size.height)!/realRoomHeight
        return CGPoint(x: newX, y: normalizeYAxes(y: newY))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func zoom(sender: UIGestureRecognizer) {
        if (scrollView.zoomScale < 1.5) {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func normalizeYAxes(y: CGFloat) -> CGFloat {
        return CGFloat(self.imageView.frame.height-y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Map"
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print(size.width)
        self.scrollView.zoomScale = CGFloat(1)
        minZoom = Double(size.width.divided(by: CGFloat(imageWidth!)))
        maxZoom = 3*minZoom
        print(minZoom)
        print(maxZoom)
        self.scrollView.minimumZoomScale = CGFloat(minZoom)
        self.scrollView.maximumZoomScale = CGFloat(maxZoom)
        self.scrollView.zoomScale = CGFloat(minZoom)
    }


}
