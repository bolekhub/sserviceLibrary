//
//  Types.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

public typealias SLProgresHandler = (Float) -> Void
public typealias SLRequestParams = [String: Any?]

enum SLAPIError: Error {
    case badURL
    case invalidResponse
    case incorrectStatus
    case parserError
}

enum SLRequestType {
    case data
    case download
    //case upload
}
enum SLHeaderField: String {
    case contentType = "Content-Type"
    case cookie = "Cookie"
    case auth = "Authorization"
    case accept = "Accept"
    case sendEncoding = "Content-Encoding"
    case receiveEncoding = "Acccept-Encoding"
    case lenght = "Content-Lenght"
    case useragent = "User-Agent"
}

enum SLSessionType {
    case data
    case download
    case upload
}

enum APIEnv: SLEnvironmentProtocol {
    case dev
    case pro
    
    var headers: [String : String] {
        switch self {
        case .dev:
           return ["Client": "Demo"]
        case .pro:
            return [:]
        }
    }
    
    var baseURL: String {
        switch self {
        case .dev:
            return "https://dummy.restapiexample.com/api/v1/"
        case .pro:
            return "https://api.example.com/v1/"
        }
    }
    
    var timeout: TimeInterval {
        switch self {
        case .pro:
            return 10
        case .dev:
            return 40
        }
    }
}

//MARK: - public types

public enum SLHTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
    case OPTIONS
}


public enum SLParameterType {
    case body(SLBodyParameterEncodingType)
    case requestURL([String: String])
    
    public enum SLBodyParameterEncodingType {
        case formdata([String: Any])
        case urlencoded([String: String])
        case json(Encodable)
        
        var headerValue: Dictionary<SLHeaderField, String> {
            switch self {
            case .urlencoded:
                return [.contentType: "application/x-www-form-urlencoded"]
            case .formdata:
                return [.contentType: "multipart/form-data"]
            case .json:
                return [.contentType: "application/json"]
            }
        }
    }
}

public struct ServiceResponse: SLResponseProtocol {
    public var data: Data
    public var headers: [AnyHashable : Any]?
    public var code: Int
}
