////////////////////////////////////////////////////
//////////////////// KARI IHAB ////////////////////
//////////////////////////////////////////////////
//////////////////// Models cars ////////////////////
//////////////////////////////////////////////////


import Foundation


struct Car: Codable, Sendable {
    let id: Int64?
    var make: String        
    var model: String       
    var year: Int           
    var color: String       
    var mileage: Int        
    var isFavorite: Bool    
}

// extension pour le critere Concepts Swift (+15 pts)
extension Car: CustomStringConvertible {
    var description: String {
        "\(year) \(make) \(model) — \(color)"
    }
}