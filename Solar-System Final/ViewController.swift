//
//  ViewController.swift
//  Solar-System Final
//
//  Created by ShrawanKumar Sharma on 05/09/18.
//  Copyright © 2018 ShrawanKumar Sharma. All rights reserved.
//

import UIKit
import SceneKit
import ARKit




class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var customView: UIView!
    @IBOutlet var  sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        addPlanetArroundSun()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    //Method called when tap
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if hits.first?.node.name == node.name && (node.name  != nil) {
                        node.removeFromParentNode()
                    }
                }
            }
        }
    }
    
    func addPlanetArroundSun(){
        //TODO: Update radius
        let radius = [1 , 1.4 , 2 , 2.5 , 3 , 3.5 , 4 ,4.5 , 5]
        var speedDistribution = [1.6,0.9,1.2,0.8,1.3,0.2,0.4,0.8,0.2]
        
        for (index,radiu) in radius.enumerated(){
           
            //Sun node
            let sunNode = addSunInCenter()
            sunNode.position = SCNVector3(0,0.5,0 )

            //Planet  node
            let childNode = addCenterNode(ofIndex: index)
            childNode.position = SCNVector3(0,0, -radiu )
            childNode.name = planetsName[index]

            //Planet Name
            createTextNode(title: planetsName[index], size: 0.25, x: 0.9, y: 0.9, planetNode: childNode)
            
            //Orbit of planet
            let path = pathDrawn(radius: radiu)
            path.position = SCNVector3(0, 0.5, 0)
            sceneView.scene.rootNode.addChildNode(path)
            
            //TODO: Ring aroud saturn
            if index > 20{
                let geometry = SCNCylinder(radius: 0.5, height: 2)
                let material = SCNMaterial()
                material.diffuse.contents = #imageLiteral(resourceName: "saturn_loop.png")
                geometry.materials = [material]
                let ringnode = SCNNode(geometry: geometry)
                ringnode.position = SCNVector3(0,0.5,0 )
                childNode.addChildNode(ringnode)
            }
            
            //Animation of every sun node which has planets
            let rotateAction = SCNAction.rotate(by: .pi , around: SCNVector3(0, 1,0), duration: TimeInterval(speedDistribution[index] * 10) )
            let repeataction = SCNAction.repeatForever(rotateAction)
            repeataction.speed = CGFloat(veleocity)
            
            //"rotate" key to change the velocity dynamically
            sunNode.runAction(repeataction , forKey:"rotate")
            addRandomStar(childNode: childNode)
            sunNode.addChildNode(childNode)
            
            sceneView.scene.rootNode.addChildNode(sunNode)
        }
    }
    
    func addCenterNode(ofIndex:Int) -> SCNNode{
        let shape = SCNSphere(radius: 0.25)
        let material = SCNMaterial()
        material.diffuse.contents =  UIImage(named:planetsImage[ofIndex])
        shape.materials = [material]
        let node = SCNNode(geometry: shape)
        return node
    }
    
    func addSunInCenter() -> SCNNode{
        let shape = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        shape.materials = [material]
        let node = SCNNode(geometry: shape)
        return node
    }
    
    func pathDrawn(radius:Double) -> SCNNode {
        let geometry = SCNTorus(ringRadius: CGFloat(radius),
                                pipeRadius: Dimensions.FIGURE_RADIUS)
        let node = SCNNode(geometry: geometry)
        return node
    }


   
    
    func createTextNode(title: String, size: CGFloat, x: Float, y: Float , planetNode:SCNNode){
        let text = SCNText(string: title, extrusionDepth: 0)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont(name: "Avenir Next", size: size)
        let textNode = SCNNode(geometry: text)
        print("posoioon \(planetNode.position)")
        textNode.position = SCNVector3(x:planetNode.position.x - 0.2 ,y: planetNode.position.y , z:planetNode.position.z)
        planetNode.addChildNode(textNode)
    }
    
    @IBAction func velocityIncrease(_ sender: UIButton) {
        updateSpeed(ifIncrease: true)
    }
    
    @IBAction func velocityDecrease(_ sender: UIButton) {
        updateSpeed(ifIncrease: false)
    }
    
    @IBAction func SizeDecrease(_ sender: UIButton) {
        updateSize(ifIncrease: false)
    }
    
    @IBAction func SizeIncrease(_ sender: Any) {
        updateSize(ifIncrease: true)
    }
    
    
    var veleocity = 0.5
    func updateSpeed(ifIncrease:Bool) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            let nodeAction = node.action(forKey: "rotate")
            nodeAction?.speed = CGFloat(veleocity * 0.1)
            if ifIncrease {
                veleocity = veleocity + 0.5
            }else{
                if (veleocity - 0.5) > 0 {
                    veleocity = veleocity - 0.5
                }
            }
        }
    }
    
    
    var radius = 0.08
    func updateSize(ifIncrease:Bool){
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if let nodeshape  =  node.geometry as? SCNSphere {
                if ifIncrease {
                    radius = radius + 0.001
                    if radius > 0 {
                        nodeshape.radius  = CGFloat(radius)
                    }
                }else{
                    radius = radius - 0.001
                    if radius > 0 {
                        nodeshape.radius  = CGFloat(radius )
                    }
                }
            }
        }
    }
    
    func updateTexture(ifIncrease:Bool){
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            let randomNumber = random( min: 0 ,max: 8)
            node.geometry?.materials[0].diffuse.contents = UIImage(named: planetsImage[randomNumber])
        }
    }
    
    func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }


    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}


func addRandomStar(childNode:SCNNode){
    let scene = SCNScene(named: "art.scnassets/starss.scn")!
    let shipNode = scene.rootNode.childNode(withName: "Mesh", recursively: true)!
    shipNode.position = SCNVector3(x: childNode.position.x + 0.2, y: childNode.position.y + 2, z: childNode.position.z + 0.5)
    childNode.addChildNode(shipNode)
}


class Dimensions {
    static let FIGURE_RADIUS:CGFloat = 0.4/40.0
}
