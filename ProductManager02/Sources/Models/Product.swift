import Foundation

struct Product: Identifiable, Codable {
    var id: String // 唯一标识符，UUID字符串
    var name: String
    var description: String
    var price: Double
    var createdAt: Date
}
