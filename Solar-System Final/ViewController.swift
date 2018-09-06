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
        addStarsToPlanet()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.clear
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
        
        virtualNode.position = SCNVector3(x,y,z)
        virtualNode.scale = SCNVector3(0.3,0.3,0.3)

        node.addChildNode(virtualNode)

        
//        node.addChildNode(SCNNode)
        
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
                        AudioPlayer.shared.playSound(.Mercury, on: virtualNode)
                        node.removeFromParentNode()
                    }
                }
            }
        }
    }
    
    let planetRadius = [1 , 1.4 , 2 , 2.5 , 3 , 3.5 , 4 ,4.5 , 5]

    func addPlanetArroundSun(){
        //TODO: Update radius
        var speedDistribution = [1.6,0.9,1.2,0.8,1.3,0.2,0.4,0.8,0.2]
        
        for (index,radiu) in planetRadius.enumerated(){
           
            //Sun node
            let sunNode = addSunInCenter()
            sunNode.position = SCNVector3(0,0.5,0 )

            //Planet  node
            let childNode = addCenterNode(ofIndex: index)
            childNode.position = SCNVector3(0,0, -radiu )
            childNode.name = planetsName[index]

            //Planet Name
            createTextNode(title: planetsName[index], size: 0.5, planetNode: childNode)
            
            //Orbit of planet
            let path = pathDrawn(radius: radiu)
            path.name = planetsName[index] + "orbit"
            path.position = SCNVector3(0, 0.5, 0)
            
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
//            addRandomStar(childNode: childNode)
            
            sunNode.addChildNode(childNode)
            
            virtualNode.position = SCNVector3(0, 1,0)
           
            virtualNode.addChildNode(path)
            virtualNode.addChildNode(sunNode)
        }
    }
    
    let virtualNode = SCNNode()

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
        material.diffuse.contents =  UIColor.red //UIImage(named:"sun.jpg")
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


    func createTextNode(title: String, size: CGFloat, planetNode:SCNNode){
        let text = SCNText(string: title, extrusionDepth: 0)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont(name: "Avenir Next", size: size)
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.3,0.3,0.3)
        textNode.position = SCNVector3(x:-0.4  ,y: 0.2, z:0 )
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
    
    var orbitRadius = 0.01
    func repositionPlanet(ifIncrease:Bool){
        for (index,planet) in planetsName.enumerated(){
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                if (node.name  != nil) {
                    orbitRadius = ifIncrease ? (orbitRadius - 0.01) : (orbitRadius + 0.01)

                    if( (planet == node.name!)   )  {
                        node.position =   SCNVector3(0,0, -planetRadius[index] + orbitRadius )
                    }else if  ( planet == node.name! + "orbit" ) {
                        if let nodeshape  =  node.geometry as? SCNTorus {
                            nodeshape.ringRadius = CGFloat(orbitRadius)
                        }
                    }
                }
            }
          }
    }

    
    @IBAction func orbitRadiusIncrease(_ sender: UIButton) {
        repositionPlanet(ifIncrease: true)
    }
    
    @IBAction func orbitRadiusDecrease(_ sender: UIButton) {
        repositionPlanet(ifIncrease: true)
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
    
    
    func addStarsToPlanet(){
        for _ in (1...500) {
            let scene = SCNScene(named: "art.scnassets/starss.scn")!
            let shipNode = scene.rootNode.childNode(withName: "Mesh", recursively: true)!
            shipNode.scale = SCNVector3(0.02,0.02,0.02)
            shipNode.position = SCNVector3(x: Float.random(min: 5.0, max: -5.0), y:Float.random(min: -5, max: 5.0), z: Float.random(min: 6.0, max: -6.0))
            virtualNode.addChildNode(shipNode)
        }
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



// MARK: Double Extension

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}



// MARK: Float Extension

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}



// MARK: CGFloat Extension

public extension CGFloat {
    
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}
