
import Foundation

public struct Book: Sendable, Identifiable, Equatable {
    public var id: String
    public let name: String
    public let audioBookId: String
    public let readBookId: String
    public let chapters: [Chapter]
    
    public init(
        id: String,
        name: String,
        audioBookId: String,
        readBookId: String,
        chapters: [Chapter])
    {
        self.id = id
        self.name = name
        self.audioBookId = audioBookId
        self.readBookId = readBookId
        self.chapters = chapters
    }
}


extension Book {
    public static var preview:Self{
        .init(
            id: UUID().uuidString,
            name: .init(),
            audioBookId: "test_2",
            readBookId: "udsadsad",
            chapters: []
        )
    }
}


public struct Chapter: Sendable, Equatable, Identifiable {
    public var id: String
    public let title: String
    public let startsAt: TimeInterval
    public let endsAt: TimeInterval
    public let duration: TimeInterval
    
    public init(
        id: String,
        title: String,
        startsAt: TimeInterval,
        endsAt: TimeInterval,
        duration: TimeInterval
    ) {
        self.id = id
        self.title = title
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.duration = duration
    }
}

public struct AudioBook: Sendable, Identifiable, Equatable {
    public var id: String
    public let chapters: [Chapter]
    public let assetUrl:URL
    public let preview:Data?
    
    public init(
        id: String = UUID().uuidString,
        chapters: [Chapter],
        assetUrl:URL,
        preview: Data? = nil
    ) {
        self.id = id
        self.chapters = chapters
        self.assetUrl = assetUrl
        self.preview = preview
    }
}
