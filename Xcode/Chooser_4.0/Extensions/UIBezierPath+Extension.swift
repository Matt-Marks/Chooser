//
//  UIBezierPath+Extension.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 4/2/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    
    public convenience init(checkIn rect: CGRect, thickness: CGFloat, scale: CGFloat) {
        self.init()
        
        //////////////////////////////////////////////////////////////////////////
        //                                                                      \\
        //                                                                      \\
        //                                                        ___           \\
        //                                                   D  /    \          \\
        //                                                    /       |         \\
        //                                                  /        /  E       \\
        //                                                /        /            \\
        //                                              /        /              \\
        //                                            /        /                \\
        //             __   B                       /        /                  \\
        //           /    \                       /        /                    \\
        //          |       \                   /        /                      \\
        //        A  \        \               /        /                        \\
        //             \        \           /        /                          \\
        //               \        \       /        /                            \\
        //                 \        \ C /        /                              \\
        //                   \        \        /                                \\
        //                     \             /                                  \\
        //                       \         /                                    \\
        //                         \     /                                      \\
        //                           \ /                                        \\
        //                            F                                         \\
        //                                                                      \\
        //          |-------------------------------------------------|         \\
        //                      width = scale * rect.width                      \\
        //                                                                      \\
        //                                                                      \\
        // |------------------------------------------------------------------| \\
        //                              rect.width                              \\
        //                                                                      \\
        //////////////////////////////////////////////////////////////////////////
        
        // Math that we use a lot so we reuse it. 
        let root2: CGFloat = sqrt(2)
        let root8: CGFloat = sqrt(8)
        let width: CGFloat = scale * rect.width
        
        // A
        let a = CGPoint(x: rect.midX - width/2 + thickness/2 - root2*thickness/4,
                        y: rect.midX - thickness/2 + root2*thickness/4)
        move(to: a)
        
        // A -> B
        let leftEndpointCenter = CGPoint(x: rect.midX - width/2 + thickness/2,
                                         y: rect.midX - thickness/2)
        addArc(withCenter: leftEndpointCenter,
               radius: thickness/2,
               startAngle: 3/4 * .pi,
               endAngle: 7/4 * .pi,
               clockwise: true)
        // B -> C
        let c = CGPoint(x: rect.midX - width/4 + thickness/2,
                        y: rect.midX + width/4 - thickness/2 - thickness/root2)
        addLine(to: c)
        
        //  C -> D
        let d = CGPoint(x: rect.midX + width/2 - thickness/root8 - thickness/2,
                        y: rect.midX - width/2 + thickness/2 - thickness/root8)
        addLine(to: d)
        
        // D -> E
        let rightEndpointCenter = CGPoint(x: rect.midX + width/2 - thickness/2,
                                          y: rect.midX - width/2 + thickness/2)
        addArc(withCenter: rightEndpointCenter,
               radius: thickness/2,
               startAngle: 5/4 * .pi,
               endAngle: 1/4 * .pi,
               clockwise: true)
        
        // E -> F
        let f = CGPoint(x: c.x, y: c.y + root2*thickness)
        addLine(to: f)
        
        // F -> A
        close()
        
        // We translate the check vertically so it is always centered.
        let verticalOffset: CGFloat = rect.height/2 - f.y/2 - rect.width/4 + width/4
        apply(.init(translationX: 0, y: verticalOffset))
        
    }
    
    public convenience init(lockIn rect: CGRect, thickness: CGFloat, scale: CGFloat) {
        self.init()
        
        //////////////////////////////////////////////////////////////////////////
        //                                                                      \\
        //           Shackle Diameter  |---------|                              \\
        //                                                                      \\
        //     Shackle Thickness  |----|                                        \\
        //                                                                      \\
        //                            ______________                            \\
        //                           /              \                           \\
        //                          /     ______     \                          \\
        //                         /    /        \    \                         \\
        //                       B/    /          \    \C                       \\
        //                        |    |N        O|    |                        \\
        //                        |    |          |    |                        \\
        //                        |    |          |    |                        \\
        //                        |    |          |    |                        \\
        //    Corner              |    |          |    |                        \\
        //    Radius         _L__A|____|M________P|____|D__E_       --          \\
        //    ----------->  /                                \       |          \\
        //                 K|                                |F      |          \\
        //                  |                                |       |          \\
        //                  |                                |       |          \\
        //                  |                                |       |   Body   \\
        //                  |                                |       |  Height  \\
        //                  |                                |       |          \\
        //                  |                                |       |          \\
        //                 J|                                |G      |          \\
        //                  \________________________________/       |          \\
        //                    I                            H        --          \\
        //                                                                      \\
        //                 |----------------------------------|                 \\
        //                        Body Width = Rect Width                       \\
        //                                                                      \\
        //////////////////////////////////////////////////////////////////////////
    }
    
    
    public convenience init(chevronIn rect: CGRect, thickness: CGFloat) {
        self.init()
        
        //////////////////////////////////////////////////////////////////////////
        //                                 __                                   \\
        //                               /    \ F                               \\
        //                              |       \                               \\
        //                               \        \                             \\
        //                               E \        \                           \\
        //                                   \        \                         \\
        //                                     \        \                       \\
        //                                       \        \                     \\
        //                                         \        \                   \\
        //                                           \        \                 \\
        //                                             \        \               \\
        //                                               \        \             \\
        //                                                 \        \           \\
        //                                                   \        \         \\
        //                                                     \        \       \\
        //                                                       \        \     \\
        //                                                       D |        | A \\
        //                                                       /        /     \\
        //                                                     /        /       \\
        //                                                   /        /         \\
        //                                                 /        /           \\
        //                                               /        /             \\
        //                                             /        /               \\
        //                                           /        /                 \\
        //                                         /        /      |--------|   \\
        //                                       /        /         Thickness   \\
        //                                     /        /                       \\
        //                                   /        /                         \\
        //                               C /        /                           \\
        //                               /        /                             \\
        //                              |       /                               \\
        //                               \ __ / B                               \\
        //                                                                      \\
        //////////////////////////////////////////////////////////////////////////
        
        // Width
        let w = rect.width
        
        // Height
        let h = rect.height
        
        // Thickness
        let t = thickness
        
        // A
        move(to: CGPoint(x: w, y: h/2))
        
        // A -> B
        addLine(to: CGPoint(x: w/2 + t/sqrt(8), y: h - (t/2 - t/sqrt(8)) ))
        
        // B -> C
        addArc(withCenter: CGPoint(x: w/2, y: h - t/2),
               radius: t/2,
               startAngle: 1/4 * .pi,
               endAngle: 5/4 * .pi,
               clockwise: true)
        
        // C -> D
        addLine(to: CGPoint(x: w - sqrt(8)*t/2, y: h/2))
        
        // D -> E
        addLine(to: CGPoint(x: w/2 - t/sqrt(8), y: t/2 + t/sqrt(8)))
        
        // E -> F
        addArc(withCenter: CGPoint(x: w/2, y: t/2),
               radius: t/2,
               startAngle: 3/4 * .pi,
               endAngle: 7/4 * .pi,
               clockwise: true)
        
        // F -> A
        close()
    }
    

    public convenience init(saltireIn rect: CGRect, thickness: CGFloat, scale: CGFloat) {
        self.init()
        
        // c stands for 'center'.
        let c = CGPoint(x: rect.midX, y: rect.midY)
        
        // bl stands for 'branch length'.
        let bl = ((rect.width * scale) - thickness) / sqrt(2)
        
        // tr2 stands for 'thickness over root 2'.
        let tr2 = thickness / sqrt(2)
        
        // tr8 stands for 'thickness over root 8'.
        let tr8 = thickness / sqrt(8)
        
        // blr2 stands for 'branch length over root 2'.
        let blr2 = bl / sqrt(2)
        
        // The inner verticies.
        let vertexN = CGPoint(x: c.x, y: c.y - tr2)
        let vertexE = CGPoint(x: c.x + tr2, y: c.y)
        let vertexS = CGPoint(x: c.x, y: c.y + tr2)
        let vertexW = CGPoint(x: c.x - tr2, y: c.y)
        
        // The center point of the end of each branch.
        let arcCenterNW = CGPoint(x: c.x - blr2, y: c.y - blr2)
        let arcCenterNE = CGPoint(x: c.x + blr2, y: c.y - blr2)
        let arcCenterSE = CGPoint(x: c.x + blr2, y: c.y + blr2)
        let arcCenterSW = CGPoint(x: c.x - blr2, y: c.y + blr2)
        
        // The outter most left point of each branch.
        // (From the perspective of the branch viewed outwards from the center.)
        let arcStartNW = CGPoint(x: arcCenterNW.x - tr8, y: arcCenterNW.y + tr8)
        let arcStartNE = CGPoint(x: arcCenterNE.x - tr8, y: arcCenterNE.y - tr8)
        let arcStartSE = CGPoint(x: arcCenterSE.x + tr8, y: arcCenterSE.y - tr8)
        let arcStartSW = CGPoint(x: arcCenterSW.x + tr8, y: arcCenterSW.y + tr8)
        
        // Drawing path...
        move(to: arcStartNW)
        addArc(withCenter: arcCenterNW,
               radius: thickness / 2,
               startAngle: 3/4 * .pi,
               endAngle: 7/4 * .pi,
               clockwise: true)
        addLine(to: vertexN)
        addLine(to: arcStartNE)
        addArc(withCenter: arcCenterNE,
               radius: thickness / 2,
               startAngle: 5/4 * .pi,
               endAngle: 1/4 * .pi,
               clockwise: true)
        addLine(to: vertexE)
        addLine(to: arcStartSE)
        addArc(withCenter: arcCenterSE,
               radius: thickness / 2,
               startAngle: 7/4 * .pi,
               endAngle: 3/4 * .pi,
               clockwise: true)
        addLine(to: vertexS)
        addLine(to: arcStartSW)
        addArc(withCenter: arcCenterSW,
               radius: thickness / 2,
               startAngle: 1/4 * .pi,
               endAngle: 5/4 * .pi,
               clockwise: true)
        addLine(to: vertexW)
        close()
    }

}
