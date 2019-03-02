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
    var webView: UIWebView!
    
    override func loadView() {
        super.loadView()
        
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
        let request = URLRequest(url: URL(string: "http://www.amazon.com")!)
        webView.loadRequest(request)
        
        sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = self
        
        let configuration = ARImageTrackingConfiguration()
        let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources",
                                                      bundle: nil)!
        configuration.trackingImages = images
        sceneView.session.run(configuration)
        view.addSubview(sceneView)
    }
    
    private func makeNode(anchor: ARImageAnchor) -> SCNNode? {
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return nil
        }
        let size = anchor.referenceImage.physicalSize
        // 同じサイズの平面ジオメトリを作成
        let plane = SCNPlane(width: size.width, height: size.height)
        plane.firstMaterial?.diffuse.contents = webView
        plane.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: plane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
//        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        node.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
//        node.eulerAngles = SCNVector3(0,0,0)
        
        return node
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let frame = UIScreen.main.bounds
        sceneView.frame = frame
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("anchor:\(anchor), node: \(node), node geometry: \(String(describing: node.geometry))")
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        // 仮想コンテンツを設置
        let madeNode = makeNode(anchor: imageAnchor)
        DispatchQueue.main.async(execute: {
            node.addChildNode(madeNode!)
        })
    }
}

extension ARImageAnchor {
    // 画像アンカーと同じサイズの平面ジオメトリを持つノードを追加する
    func addPlaneNode(on node: SCNNode, color: UIColor) {
        // 物理サイズを取得
        let size = referenceImage.physicalSize
        
        // 同じサイズの平面ジオメトリを作成
        let geometry = SCNPlane(width: size.width, height: size.height)
        geometry.materials.first?.diffuse.contents = color
        
        // 平面ジオメトリを持つノードを作成
        let planeNode = SCNNode(geometry: geometry)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        DispatchQueue.main.async(execute: {
            node.addChildNode(planeNode)
        })
    }
    
    func findPlaneNode(on node: SCNNode) -> SCNNode? {
        for childNode in node.childNodes {
            if childNode.geometry as? SCNPlane != nil {
                return childNode
            }
        }
        return nil
    }
    
    func updatePlaneNode(on node: SCNNode) {
        let size = referenceImage.physicalSize
        DispatchQueue.main.async(execute: {
            guard let planeNode = self.findPlaneNode(on: node) else { return }
            guard let plane = planeNode.geometry as? SCNPlane else { fatalError() }
            // 平面ジオメトリのサイズを更新
            plane.width = size.width
            plane.height = size.height
        })
    }
    
    func removePlaneNode(on node: SCNNode) {
        DispatchQueue.main.async(execute: {
            guard let planeNode = self.findPlaneNode(on: node) else { return }
            planeNode.removeFromParentNode()
        })
    }
}

