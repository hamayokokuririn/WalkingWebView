//
//  ViewController.swift
//  WalkingWebView
//
//  Created by 齋藤健悟 on 2019/03/02.
//  Copyright © 2019 齋藤健悟. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    var sceneView: ARSCNView!
    
    override func loadView() {
        super.loadView()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        sceneView = ARSCNView(frame: .zero)
        sceneView.addGestureRecognizer(gesture)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        view.addSubview(sceneView)
    }
    
    @objc private func tapped() {
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        let uiWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
        let request = URLRequest(url: URL(string: "http://www.amazon.com")!)
        
        uiWebView.loadRequest(request)
        
        let plane = SCNPlane(width: 1.0, height: 0.75)
        plane.firstMaterial?.diffuse.contents = uiWebView
        plane.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: plane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        node.eulerAngles = SCNVector3(0,0,0)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let frame = UIScreen.main.bounds
        sceneView.frame = frame
    }
}
