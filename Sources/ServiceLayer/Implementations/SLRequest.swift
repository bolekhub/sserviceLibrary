//
//  Request.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

public struct SLRequest {
    private let jsonEncoder = JSONEncoder()
    private var requestType: SLParameterType
    private var method: SLHTTPMethod
    private var url: String = ""
    var body: Data? = nil
    var headers: [SLHeaderField: String] = [:]
    var trafficType: SLRequestType = .data
    var path: String? = nil
}

public extension SLRequest {
        /// This is the basic unit of a request. Contains al elements that dispatcher will throw to network session. Its added to the SLOperation before doing request.
        /// - Parameters:
        ///   - requestType: Specify the type of reques wich can be body or standard qquery items. Body can be     formdata, urlencoded, json so far. body option have asociated types wich guide you on how request should be made
        ///   - method: method automatically is set according to request type. You can specify it if desired
        ///   - serviceName: the name of the service. usualy is the last path component. This parameter will be added to environment baseurl
    init(requestType: SLParameterType, method: SLHTTPMethod = .GET, serviceName: String) {
        self.path = serviceName
        self.requestType = requestType
        self.method = method
        
        switch requestType {
        case .requestURL(let requestParams):
           guard !requestParams.isEmpty else { return }
            let components = requestParams.asQueryItems
            guard let stringComponents = components.string else {
                return
            }
            self.path?.append(stringComponents)
            self.method = method
            
        case .body(let enconding):
        switch enconding {
            case let .json(param):
                guard let encodedParam = param.encodeObject() else { return }
                self.body = encodedParam.data(using: .utf8, allowLossyConversion: true)
                self.headers = enconding.headerValue
                self.method = .POST
                
            case let .urlencoded(param):
                guard !param.isEmpty else { return }
                let orderedParams = param.sorted { this, next in
                 return this.key > next.key
                }
                let components = orderedParams.asQueryItems
                self.body = components.query?.data(using: .utf8, allowLossyConversion: true)
                self.headers = enconding.headerValue
                self.method = .POST
                
            case let .formdata(parameters):
                let bodyString = self.formDataFromParameters(parameters)
                self.body = bodyString.data(using: .utf8)
                self.headers = enconding.headerValue
                self.method = .POST
            }
        }
    }
}

private extension SLRequest {
    func formDataFromParameters(_ parameters: [String: Any]) -> String {
        var stringBody: String = ""
        let boundary = "Boundary-\(UUID().uuidString)"
        for parameter in parameters {
            stringBody += "--\(boundary)\r\n"
            stringBody += "Content-Disposition:form-data; name=\"\(parameter.key)\""
            if type(of: parameter.value) == Data.self {
                let fileContent = String(data: parameter.value as! Data, encoding: .utf8)!
                stringBody += "; filename=\"\(parameter.key)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            } else {
                let value = String(describing: parameter.value)
                stringBody += "\r\n\r\n\(value)\r\n"
            }
        }
        return stringBody
    }
}

extension SLRequest {
    func urlRequest(environment: SLEnvironmentProtocol) -> URLRequest? {
        guard let url = URL(string: environment.baseURL) else {
            return nil
        }
        let fullUrl = url.appendingPathComponent(self.path ?? "", isDirectory: false)
        var urlRequest = URLRequest(url: fullUrl,
                                    cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: environment.timeout)
        self.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        urlRequest.httpBody = self.body
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.url = fullUrl
        return urlRequest
    }
    
    mutating func setBaseURL(_ url: String) {
        self.url = url
    }
}

extension Encodable {
    func encodeObject() -> String? {
        let data = try? JSONEncoder().encode(self)
        return data.flatMap({ String(data: $0, encoding: .utf8) })
    }
}

extension Sequence where Iterator.Element == (key: String, value: AnyObject) {
    var asQueryItems: URLComponents {
        var components = URLComponents()
        components.queryItems = self.map({ key, value in
            return URLQueryItem(name: key, value: String(describing: value))
        })
        return components
    }
}

extension Sequence where Iterator.Element == (key: String, value: String) {
    var asQueryItems: URLComponents {
        var components = URLComponents()
        let ordered = self.sorted(by: {$0.key > $1.key})
        components.queryItems = ordered.map({ key, value in
            return URLQueryItem(name: key, value:  value)
        })
        return components
    }
}
