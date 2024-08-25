import SwiftUI
import SwiftData

@Model
class CloudRecord {
    var imageData: Data?
    var classification: String
    var date: Date
    var comment: String = ""
    
    init(image: UIImage? = nil, classification: String) {
        self.imageData = image?.jpegData(compressionQuality: 0.8)
        self.classification = classification
        self.date = Date()
    }
    
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    var dateStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: self.date)
    }
    
    var cloudType: String {
        let result = self.classification.dropLast(5)
        return String(result)
    }
    
    var pred: String {
        var tmp = self.classification.suffix(5)
        tmp = tmp.dropFirst(1)
        tmp = tmp.dropLast()
        return String(tmp)
    }
}
