import Foundation

// MARK: - Model Struct
struct Computer: Identifiable {
    let id = UUID()           // Mã định danh duy nhất[cite: 6, 10]
    var name: String          // Tên máy (vd: PC01)[cite: 6, 10]
    var location: String      // Vị trí (vd: Lab A)[cite: 6, 10]
    var isAvailable: Bool     // Trạng thái khả dụng[cite: 6, 10]
}
