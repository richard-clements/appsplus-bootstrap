#if canImport(SwiftCheck)

import XCTest
import SwiftCheck
@testable import AppsPlus

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
    
}

#endif
