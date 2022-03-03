#if canImport(SwiftCheck)

import XCTest
import SwiftCheck
@testable import AppsPlusData

class RequestTests: XCTestCase {
    
    func testAuthenticatedRequest() {
        property("Authenticated request used sames url request as input") <- forAll(URLRequest.arbitrary) {
            let request = AuthenticatedRequest(urlRequest: $0)
            return request.urlRequest == $0
        }
        
        property("Authenticated request requires authentication") <- forAll(URLRequest.arbitrary) {
            let request = AuthenticatedRequest(urlRequest: $0)
            return request.requiresAuthentication
        }
    }
    
    func testPublicRequest() {
        property("Public request used sames url request as input") <- forAll(URLRequest.arbitrary) {
            let request = PublicRequest(urlRequest: $0)
            return request.urlRequest == $0
        }
        
        property("Public request requires authentication") <- forAll(URLRequest.arbitrary) {
            let request = PublicRequest(urlRequest: $0)
            return !request.requiresAuthentication
        }
    }
    
    func testURLRequest_initURL_Version() {
        property("URL Request uses input url") <- forAll(URL.arbitrary, String.arbitrary) { url, version in
            let request = URLRequest(url: url, versionNumber: version)
            return request.url == url
        }
        
        property("URL Request sets version and device type") <- forAll(URL.arbitrary, String.arbitrary) { url, version in
            let request = URLRequest(url: url, versionNumber: version)
            
            #if os(iOS)
            let expectedDeviceType = "ios"
            #elseif os(macOS)
            let expectedDeviceType = "macos"
            #elseif os(watchOS)
            let expectedDeviceType = "watchos"
            #elseif os(tvOS)
            let expectedDeviceType = "tvos"
            #endif
            
            return request.value(forHTTPHeaderField: "Device-Type") == expectedDeviceType &&
                request.value(forHTTPHeaderField: "Device-Version") == version
        }
        
        property("Accept header matches accept") <- forAll(URL.arbitrary, String.arbitrary, String.arbitrary) { url, version, accept in
            let request = URLRequest(url: url, versionNumber: version, accept: .init(accept))
            return request.value(forHTTPHeaderField: "Accept") == accept
        }
    }
    
    func testURLRequest_setHttpBody() {
        property("setHttpBody updates body") <- forAll(URL.arbitrary, MockCodable.arbitrary) { url, codable in
            var request = URLRequest(url: url)
            try? request.set(httpBody: codable)
            let bodyValue = request.httpBody.flatMap { try? JSONDecoder().decode(MockCodable.self, from: $0) }
            return bodyValue == codable
        }
        
        property("setHttpBody updates content type to application/json") <- forAll(URL.arbitrary, MockCodable.arbitrary) { url, codable in
            var request = URLRequest(url: url)
            try? request.set(httpBody: codable)
            return request.value(forHTTPHeaderField: "Content-Type") == "application/json"
        }
    }
    
    func testAppendQuery() {
        property("Append query updates url") <- forAll(URL.arbitrary, String.arbitrary, String?.arbitrary) { url, queryName, queryValue in
            let newComponents = URLComponents(
                url: url.appendingQueryComponent(URLQueryItem(name: queryName, value: queryValue)),
                resolvingAgainstBaseURL: false
            )
            return newComponents?.queryItems?.contains(URLQueryItem(name: queryName, value: queryValue)) == true
        }
        
        property("Append page query updates url") <- forAll(URL.arbitrary, Int.arbitrary) { url, page in
            let newComponents = URLComponents(
                url: url.appendingPageQuery(page),
                resolvingAgainstBaseURL: false
            )
            return newComponents?.queryItems?.contains(URLQueryItem(name: "page", value: page.description)) == true
        }
    }
}

#endif
