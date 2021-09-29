import Foundation

extension URLSession {
    
    static var mock: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockNetworkProtocol.self]
        return URLSession(configuration: configuration)
    }
    
}

class MockNetworkProtocol: URLProtocol {
    
    static var requests = [URLRequest]()
    static var responseHandler: ((URLRequest) -> (response: (data: Data, statusCode: Int)?, error: URLError?)?)?
    static var delay: TimeInterval = 0
    
    private class func reset() {
        requests.removeAll()
        responseHandler = nil
        delay = 0
    }
    
    class func setUpForTests() {
        URLProtocol.registerClass(MockNetworkProtocol.self)
        reset()
    }
    
    class func tearDownForTests() {
        reset()
        URLProtocol.unregisterClass(MockNetworkProtocol.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override class func requestIsCacheEquivalent(_ first: URLRequest, to second: URLRequest) -> Bool {
        false
    }
    
    override func startLoading() {
        var updatedRequest = request
        updatedRequest.httpBody = request.httpBodyStreamData()
        Self.requests.append(updatedRequest)
        guard let result = Self.responseHandler?(request),
              let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotFindHost))
            return
        }
        
        Thread.sleep(forTimeInterval: Self.delay)
        
        if let error = result.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let response = result.response, let urlResponse = HTTPURLResponse(url: url, statusCode: response.statusCode, httpVersion: "1.0", headerFields: nil) {
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        } else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        
        if let data = result.response?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
    
}

extension URLRequest {
    fileprivate func httpBodyStreamData() -> Data? {
        guard let bodyStream = self.httpBodyStream else { return nil }
        
        bodyStream.open()
        
        // Will read 16 chars per iteration. Can use bigger buffer if needed
        let bufferSize: Int = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()
        
        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readData)
        }
        
        buffer.deallocate()
        bodyStream.close()
        
        return data
    }
}
