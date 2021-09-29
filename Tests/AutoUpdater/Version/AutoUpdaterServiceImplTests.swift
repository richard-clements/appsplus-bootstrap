import XCTest
import AppsPlusTesting
import Combine
@testable import AutoUpdater

class AutoUpdaterServiceImplTests: XCTestCase {
    
    var autoUpdaterService: AutoUpdaterServiceImpl!
    var session: URLSession!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        MockNetworkProtocol.setUpForTests()
        session = URLSession.mock
        autoUpdaterService = AutoUpdaterServiceImpl(session: session, currentVersion: Version(major: 1, minor: 0, patch: 0, build: 1), manifestUrl: URL(string: "https://www.test.com")!)
        cancellables = Set()
    }
    
    override func tearDownWithError() throws {
        MockNetworkProtocol.tearDownForTests()
        session = nil
        autoUpdaterService = nil
        cancellables = nil
    }
    
    func testHasUpdates_Error_WhenFailed() {
        MockNetworkProtocol.responseHandler = { _ in
            return (nil, URLError(.notConnectedToInternet))
        }
        let expectation = XCTestExpectation()
        var outputError: AutoUpdaterError?
        autoUpdaterService.availableUpdate()
            .sink {
                if case .failure(let error) = $0 {
                    outputError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(.failed, outputError)
    }
    
    func testHasUpdates_False_VersionLessThanCurrent() {
        let value = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>items</key>
            <array>
                <dict>
                    <key>assets</key>
                    <array>
                        <dict>
                            <key>kind</key>
                            <string>software-package</string>
                            <key>url</key>
                            <string>url</string>
                        </dict>
                        <dict>
                            <key>kind</key>
                            <string>display-image</string>
                            <key>url</key>
                            <string>url</string>
                        </dict>
                        <dict>
                            <key>kind</key>
                            <string>full-size-image</string>
                            <key>url</key>
                            <string>url</string>
                        </dict>
                    </array>
                    <key>metadata</key>
                    <dict>
                        <key>bundle-identifier</key>
                        <string>identifier</string>
                        <key>bundle-version</key>
                        <string>0.0.1</string>
                        <key>bundle-build</key>
                        <string>1</string>
                        <key>kind</key>
                        <string>software</string>
                        <key>title</key>
                        <string>Title</string>
                        <key>expiration-date</key>
                        <date>2022-06-28T11:49:08Z</date>
                    </dict>
                </dict>
            </array>
        </dict>
        </plist>
        """.data(using: .utf8)!
        MockNetworkProtocol.responseHandler = { _ in
            return ((value, 200), nil)
        }
        
        var update: Update?
        let expectation = XCTestExpectation()
        autoUpdaterService.availableUpdate()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                update = $0
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(.latest, update)
    }
    
    func testHasUpdates_True_VersionLessThanCurrent() {
        let value = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>items</key>
            <array>
                <dict>
                    <key>assets</key>
                    <array>
                        <dict>
                            <key>kind</key>
                            <string>software-package</string>
                            <key>url</key>
                            <string>url</string>
                        </dict>
                        <dict>
                            <key>kind</key>
                            <string>display-image</string>
                            <key>url</key>
                            <string>url</string>
                        </dict>
                        <dict>
                            <key>kind</key>
                            <string>full-size-image</string>
                            <key>url</key>
                            <string>url</string>
                        </dict>
                    </array>
                    <key>metadata</key>
                    <dict>
                        <key>bundle-identifier</key>
                        <string>identifier</string>
                        <key>bundle-version</key>
                        <string>1.0.1</string>
                        <key>bundle-build</key>
                        <string>1</string>
                        <key>kind</key>
                        <string>software</string>
                        <key>title</key>
                        <string>Title</string>
                        <key>expiration-date</key>
                        <date>2022-06-28T11:49:08Z</date>
                    </dict>
                </dict>
            </array>
        </dict>
        </plist>
        """.data(using: .utf8)!
        MockNetworkProtocol.responseHandler = { _ in
            return ((value, 200), nil)
        }
        
        var update: Update?
        let expectation = XCTestExpectation()
        autoUpdaterService.availableUpdate()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                update = $0
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
        if case .available(let manifest) = update {
            XCTAssertEqual(Version(major: 1, minor: 0, patch: 1, build: 1), manifest.items.first?.metadata.version)
        } else {
            XCTFail("Should be manifest update")
        }
    }
}
