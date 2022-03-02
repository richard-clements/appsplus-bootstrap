import Foundation

extension URLResponse {
    
    public static func generateHTTPResponse(url: URL, statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
}
