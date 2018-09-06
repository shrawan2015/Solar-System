//
//  PlanetModel.swift
//  Solar-System Final
//
//  Created by ShrawanKumar Sharma on 06/09/18.
//  Copyright © 2018 ShrawanKumar Sharma. All rights reserved.
//

import Foundation
enum PlanetEnum : Int {
    case MERCURY = 0
    case VENUS = 1
    case EARTH = 2
    case MARS = 3
    case JUPITER = 4
    case SATURN = 5
    case URANUS = 6
    case NEPTUNE = 7
    
    var descrition:String {
        switch self {
        case .MERCURY:
            return "mercury.jpg"
        case .VENUS:
            return "venus.jpg"
        case .EARTH:
            return "earth.jpg"
        case .MARS:
            return  "mars.jpg"
        case .JUPITER:
            return "jupiter.jpg"
        case .SATURN:
            return "saturn.jpg"
        case .URANUS:
            return "uranus.jpg"
        case .NEPTUNE:
            return "neptune.jpg"
        default:
            return "neptune.jpg"
        }
    }
}

//TODO:- Class structure
var planetsImage = ["mercury.jpg" , "venus.jpg" , "earth.jpg" , "mars.jpg" , "jupiter.jpg" , "saturn.jpg" , "uranus.jpg" , "neptune.jpg" , "neptune.jpg"]
var planetsName = ["mercury" , "venus" , "earth" , "mars" , "jupiter" , "saturn" , "uranus" , "neptune" , "neptune"]
