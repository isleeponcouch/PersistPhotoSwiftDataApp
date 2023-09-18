import Foundation
import SwiftData

@Model
final class Photo {
    var timestamp: Date
    var photoData: Data
    
    init(timestamp: Date, photoData: Data) {
        self.timestamp = timestamp
        self.photoData = photoData
    }
}
