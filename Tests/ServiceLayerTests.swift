//
//  VideoClubNOTests.swift
//  VideoClubNOTests
//
//  Created by Boris Chirino on 12/9/22.
//

import XCTest
@testable import ServiceLayer

class VideoClubNOTests: XCTestCase {
    let testEndpoint = "https://dummy.restapiexample.com/api/v1/"

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_json_body_request_type_ok() throws {
        let jhon = Employee(name: "Jhon", salary: "130000", age: "45")
        let bodyRequest = SLRequest(requestType: .body(.json(jhon)),
                                    serviceName: "create")
        XCTAssertTrue(bodyRequest.headers.keys.contains(SLHeaderField.contentType))
        XCTAssertTrue(bodyRequest.headers.values.contains("application/json"))
        let bodyData = try XCTUnwrap(bodyRequest.body)

        let jsonObject = try! JSONSerialization.jsonObject(with: bodyData, options: .fragmentsAllowed)
        XCTAssertNotNil(jsonObject)
        XCTAssertEqual((jsonObject as! NSDictionary).allKeys.count, 3)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonObject))
    }

    func test_formdata_body_request_type_() throws {
        let formData: [String: Any] = ["token": "1992929", "expiration": 1222232, "renew": false]
        let bodyRequest = SLRequest(requestType: .body(.formdata(formData)),
                                    serviceName: "create")
        
        let bodyData = try XCTUnwrap(bodyRequest.body)
        let stringResponse = try XCTUnwrap(String(data: bodyData, encoding: .utf8))

        let boundaryString = "--Boundary-"
        let token = "name=\"token\"\r\n\r\n1992929\r\n"
        let expiration = "name=\"expiration\"\r\n\r\n1222232\r\n"
        let renew = "name=\"renew\"\r\n\r\nfalse\r\n"
        
        XCTAssertTrue(stringResponse.contains(boundaryString))
        XCTAssertTrue(stringResponse.contains(token))
        XCTAssertTrue(stringResponse.contains(expiration))
        XCTAssertTrue(stringResponse.contains(renew))

        XCTAssertTrue(bodyRequest.headers.keys.contains(SLHeaderField.contentType))
        XCTAssertTrue(bodyRequest.headers.values.contains("multipart/form-data"))
    }
    
    func test_urlencoded_body_request_type_ok() throws {
        let info = ["token": "1992929", "expiration": "0"]
        let bodyRequest = SLRequest(requestType: .body(.urlencoded(info)),
                                    serviceName: "create")
        XCTAssertTrue(bodyRequest.headers.keys.contains(SLHeaderField.contentType))
        XCTAssertTrue(bodyRequest.headers.values.contains("application/x-www-form-urlencoded"))
        
        let bodyData = try XCTUnwrap(bodyRequest.body)
        let stringResponse = try XCTUnwrap(String(data: bodyData, encoding: .utf8))
        XCTAssertEqual(stringResponse, "token=1992929&expiration=0")
    }
    
    func test_simple_request_query_params__type_ok() throws {
        let info = ["user": "200", "h": "20"]
        let bodyRequest = SLRequest(requestType: .requestURL(info),
                                    serviceName: "create")
        let url = try XCTUnwrap(bodyRequest.urlRequest(environment: APIEnv.dev)).url?.absoluteString.removingPercentEncoding
        let expectedURL = "https://dummy.restapiexample.com/api/v1/create?user=200&h=20"
        XCTAssertEqual(expectedURL, url)
        XCTAssertNil(bodyRequest.body)
    }
    
    func test_request_single_params_request_type_ok() throws {
        let bodyRequest = SLRequest(requestType: .requestURL([:]),
                                    serviceName: "employee/1")
        XCTAssertNil(bodyRequest.body)
    }
}
