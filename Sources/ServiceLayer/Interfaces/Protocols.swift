//
//  Protocols.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

/// If request was successfully the service will return a type conforming this protocol
public protocol SLResponseProtocol {
    var data: Data { get }
    var code: Int { get }
    var headers: [AnyHashable: Any]? { get }
    var body: String? { get }
    var bodyRepresentation: NSDictionary? { get }
}

extension SLResponseProtocol {
    public var body: String? {
        String(data: data, encoding: .utf8)
    }
    
    public var bodyRepresentation: NSDictionary? {
        let json = try? JSONSerialization.jsonObject(with: self.data, options: .fragmentsAllowed)
        return json as? NSDictionary
    }
}

/// Define environment. Switch easyly between environments applying the most critical parameters.
public protocol SLEnvironmentProtocol {
    var headers: [String: String] { get }
    var baseURL: String { get }
    var timeout: TimeInterval { get }
}

/// Types conforming to this protocols are operations wich execute, cancel session task
public protocol SLOperationProtocol {
    associatedtype Output
    
    var request: SLRequest { get }
    
        /// execute the request using dispatcher
        /// - Returns: Void
    func execute(in requestDispatcher: RequestDispatcherProtocol, completion: @escaping (Output) -> Void) -> Void
    
        /// cancel the task using by dispatcher declared on NetworkSession
    func cancel() -> Void
}

/// dispatch request with the specified environment and network session.
public protocol RequestDispatcherProtocol {
    var environment: SLEnvironmentProtocol { get }
    init(env: SLEnvironmentProtocol, networkSession: NetworkSessionProtocol)
    
    func execute(request: SLRequest, completion: @escaping ((SLResponseProtocol?) -> Void)) -> URLSessionTask?
}


/// define methods used by urlsession responsible creating data/download task, track progres. etc.
public protocol NetworkSessionProtocol {
    func dataTaskWithRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask?
    
    func downloadTaskWithRequest(_ request: URLRequest, progress: SLProgresHandler?,  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask?
}

