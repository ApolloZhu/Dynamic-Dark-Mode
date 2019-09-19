//
//  main.swift
//  Tools
//
//  Created by Apollo Zhu on 9/10/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Foundation

import XMLCoder

let releasesURL = "https://github.com/ApolloZhu/Dynamic-Dark-Mode/releases.atom"

struct Feed: Codable {
    struct Entry: Codable {
        let id: String
        let updated: Date
        let title: String
        let content: String
    }
    let entry: [Entry]
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"

extension Feed.Entry {
    func appcastItem(sparkleVersion: Int = 0) -> String {
        let version = id[id.index(after: id.lastIndex(of: "/")!)...]
        return """
        <item>
        <title>\(title)</title>
        <pubDate>\(dateFormatter.string(from: updated))</pubDate>
        <sparkle:minimumSystemVersion>10.14</sparkle:minimumSystemVersion>
        <description><![CDATA[\(content)]]></description>
        <enclosure url="https://github.com/ApolloZhu/Dynamic-Dark-Mode/releases/download/\(version)/Dynamic_Dark_Mode-\(version).zip" sparkle:version="\(sparkleVersion)" sparkle:shortVersionString="\(version)" type="application/octet-stream"/>
        </item>
        """
    }
}

URLSession.shared.dataTask(with: URL(string: releasesURL)!) { data, _, _ in
    guard let data = data else { return }
    let decoder = XMLDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let feed = try! decoder.decode(Feed.self, from: data)
    print(feed.entry.first!.appcastItem())
    /*
    let items = feed.entry.enumerated().reduce("") { (result, item) -> String in
        return result + item.1.appcastItem(sparkleVersion: feed.entry.count - item.0 - 1)
    }
    let string = """
    <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
    <channel>
    <title>Dynamic Dark Mode</title>
    <link>
    https://apollozhu.github.io/Dynamic-Dark-Mode/appcast.xml
    </link>
    <language>en</language>
    \(items)
    </channel>
    </rss>
    """
    try! string.write(toFile: "appcast.xml", atomically: true, encoding: .utf8)
    print(FileManager.default.currentDirectoryPath)
    */
    exit(EXIT_SUCCESS)
}.resume()

RunLoop.main.run()
