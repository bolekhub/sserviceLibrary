//
//  IntegrationTest.swift
//  VideoClubNOTests
//
//  Created by Boris Chirino on 13/9/22.
//

import XCTest
@testable import ServiceLayer

class IntegrationTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateUser() throws {
        let expectation = XCTestExpectation(description: "integration test create")
        
        let person = Employee(name: "Jhon", salary: "43000", age: "45")
        let dispatcher = SLRequestDispatcher(env: APIEnv.dev, networkSession: SLNetworkSession())
        let personRequest = SLRequest(requestType: .body(.json(person)),
                                                         serviceName: "create")
        
        let operation = SLOperation(personRequest)
        operation.execute(in: dispatcher) { response in
            expectation.fulfill()
            let resp = try! XCTUnwrap(response)
            let dictionaryResponse = try! XCTUnwrap(resp.bodyRepresentation)
            XCTAssertEqual(dictionaryResponse["status"] as! String, "success")
        }
        
        self.wait(for: [expectation], timeout: 8)
    }
    
    func testGetUser() throws {
        let expectation = XCTestExpectation(description: "integration test testGetUser create")
        let dispatcher = SLRequestDispatcher(env: APIEnv.dev, networkSession: SLNetworkSession())
        let employeeRequest = SLRequest(requestType: .requestURL([:]),
                                        method: .GET,
                                        serviceName: "employee/1")
        
        let operation = SLOperation(employeeRequest)

        operation.execute(in: dispatcher) { response in
            if let expectedResponse = response {
                print(expectedResponse.bodyRepresentation ?? "")
                let dictionaryResponse = try! XCTUnwrap(expectedResponse.bodyRepresentation)
                XCTAssertEqual(dictionaryResponse["status"] as! String, "success")
                XCTAssertEqual(expectedResponse.headers?.count, 21)
                XCTAssertEqual(expectedResponse.code, 200)
                
            }
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
}
