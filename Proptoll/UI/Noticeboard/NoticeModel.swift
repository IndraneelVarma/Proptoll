import Foundation

struct Notice: Codable, Hashable {
    let title: String
    let content: String
    let subTitle: String
    let noticeCategoryId: Int
    let createdAt: String
    let postNumber: Int
    let attachments: [Attachment]?
}

struct Attachment: Codable, Hashable {
    let s3ResourceUrl: String?
}
