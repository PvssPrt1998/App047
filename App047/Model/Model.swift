import Foundation
import CoreData

struct Video: Hashable {
    let id: String
    let isEffect: Bool
    var url: String?
    var date: String?
}

public class VideoID: NSManagedObject {

}

extension VideoID {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoID> {
        return NSFetchRequest<VideoID>(entityName: "VideoID")
    }

    @NSManaged public var videoID: String
    @NSManaged public var isEffect: Bool
    @NSManaged public var url: String?
}

extension VideoID : Identifiable {

}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let response = try? JSONDecoder().decode(Response.self, from: jsonData)

import Foundation

// MARK: - Response
struct ResponseID: Codable {
    let id, userID: String
    let isFinished, isInvalid: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case isFinished = "is_finished"
        case isInvalid = "is_invalid"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let imageGenerationResult = try? JSONDecoder().decode(ImageGenerationResult.self, from: jsonData)

import Foundation

// MARK: - ImageGenerationResult
struct ImageGenerationResult: Codable {
    let error: Bool?
    let data: DataClass?
}

struct DataClass: Codable {
    let generationID: String?
    let totalWeekGenerations, maxGenerations: Int?
    let status: String?
    let resultURL: String?

    enum CodingKeys: String, CodingKey {
        case generationID = "generationId"
        case totalWeekGenerations, maxGenerations
        case status
        case resultURL = "resultUrl"
    }
}

struct Effect {
    let title: String
    let id: Int
    let url: String
}
