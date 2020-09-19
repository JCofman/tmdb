
import Foundation
import Vapor
import GraphZahl
import NIO

enum MovieDB : GraphQLSchema {
    class ViewerContext {
        let request: Request
        let tmdbImageBase: URL
        let justWatchImageBase: URL
        let tmdb: Client
        let justWatch: Client
        let geoLocation: Client

        init(request: Request, tmdbImageBase: URL, justWatchImageBase: URL, tmdb: Client, justWatch: Client, geoLocation: Client) {
            self.request = request
            self.tmdbImageBase = tmdbImageBase
            self.justWatchImageBase = justWatchImageBase
            self.tmdb = tmdb
            self.justWatch = justWatch
            self.geoLocation = geoLocation
        }
    }

    class Query: QueryType {
        let viewerContext: ViewerContext

        var movies: Movies {
            return Movies(viewerContext: viewerContext)
        }

        var people: People {
            return People(viewerContext: viewerContext)
        }

        var tv: TV {
            return TV(viewerContext: viewerContext)
        }

        func search(term: String) -> EventLoopFuture<Paging<MovieOrTVOrPeople>> {
            return viewerContext.tmdb.get(at: "search", "multi", query: ["query" : term])
        }

        func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Paging<MovieOrTVOrPeople>> {
            return viewerContext.tmdb.get(at: "trending", "all", .constant(timeWindow.rawValue))
        }

        func find(externalId: String, source: ExternalSource) -> EventLoopFuture<FromExternalIds> {
            return viewerContext.tmdb.get(at: "find", .constant(externalId), query: ["external_source" : source.rawValue + "_id"])
        }

        required init(viewerContext: ViewerContext) {
            self.viewerContext = viewerContext
        }
    }
}
