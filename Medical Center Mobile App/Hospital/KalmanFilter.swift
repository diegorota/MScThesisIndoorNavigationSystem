//
//  KalmanFilter.swift
//  Hospital
//
//  Created by Simone Montalto on 19/04/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation
import Upsurge

class KalmanFilter {
    
    // Kalman Settings
    let measnoise:Int = 40
    let accelnoise: Int = 2
    let T: Float = 0.5

    // Kalman Constants and Variables
    var A: Matrix<Float>
    var B: Matrix<Float>
    var C: Matrix<Float>
    var Sz: Matrix<Float>
    var Sw: Matrix<Float>
    var xhat: Matrix<Float>?
    var P: Matrix<Float>
    
    
    init() {
        A = Matrix<Float>([
            [1,  T, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, T],
            [0, 0, 0, 1]
            ])
        
        B = Matrix<Float>([
            [(T*T)/2,  0],
            [T, 0],
            [0, (T*T)/2],
            [0, T]
            ])
        
        C = Matrix<Float>([
            [1, 0, 0, 0],
            [0, 0, 1, 0]
            ])
        
        Sz = Matrix<Float>([
            [Float(measnoise*measnoise), 0],
            [0, Float(measnoise*measnoise)]
            ])
        
        let op11 = (accelnoise*accelnoise)
        let op12 = (T*T*T*T)
        let op1 = Float(op11)*op12/4
        let op2 = Float(op11)*(T*T*T)/2
        let op3 = Float(op11)*op12
        
        Sw = Matrix<Float>([
            [op1,  op2, 0, 0],
            [op1, op3, 0, 0],
            [0, 0, op1, op2],
            [0, 0, op2, op3]
            ])
        
        P = Matrix<Float>([
            [op1,  op2, 0, 0],
            [op1, op3, 0, 0],
            [0, 0, op1, op2],
            [0, 0, op2, op3]
            ])
    }
    
    func kalman_filter(coordX: Int, coordY: Int, accX: Float, accY: Float) -> KalmanPosition {
        
        if xhat != nil {
            
            let u = Matrix<Float>([
                [accX],
                [accY]
                ])

            
            let y = Matrix<Float>([
                [Float(coordX)],
                [Float(coordY)]
                ])
            
            self.xhat = (A * self.xhat!) + (B * u)
            
            let Inn:Matrix<Float> = (y) - (C * self.xhat!)

            
            let s:Matrix<Float> = C*P*transpose(C) + Sz
            
            let K:Matrix<Float> = A*P*transpose(C)*inv(s)
            
            self.xhat = self.xhat! + K*Inn
            
            let op1:Matrix<Float> = A*P*transpose(A)
            let op2:Matrix<Float> = A*P*transpose(C)*inv(s)*C*P*transpose(A)
            P = op1 - op2 + Sw
            
        } else {
            
            self.xhat = Matrix<Float>([
                [Float(coordX)],
                [0],
                [Float(coordY)],
                [0]
                ])
            
        }
        
        let position = KalmanPosition(x: Int(xhat!.column(0)[0]), y: Int(xhat!.column(0)[2]))
        return position
        
    }
    
}
