
# ServiceLayer

This is a protocol oriented network layer using URLSession. My intention its to continue improving and completing more features. For now it create Data task to create and receive data. Its orchested using 3 subsystems having as core [URLSession](https://developer.apple.com/documentation/foundation/urlsession).

>The URL Loading System provides access to resources identified by URLs, using standard protocols like https or custom protocols you create. Loading is performed asynchronously, so your app can remain responsive and handle incoming data or errors as they arrive.''

I took in consideration for this the types of [Request Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) and design a fluid api that are easy to understand and have their implementation applied to standards very close as [open api specification](https://swagger.io/specification/). For example a [POST](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST) request with body can be of this 4 types.

* form-data
* x-www-form-urlencoded
* binary
* text ( json for example )

So expressing this on Request i propose a SLRequest wich will be

```swift
    let person = Employee(name: "Jhon", salary: "430000", age: "45")
    let personRequest = SLRequest(requestType: .body(.json(person)),
                                                         serviceName: "create")
```

this is the constructor signature 

```swift
    init(requestType: SLParameterType, method: SLHTTPMethod = .GET, serviceName: String) 
```
Where **RequestType** is :

```swift
enum SLParameterType {
    case body(SLBodyParameterEncodingType)
    case requestURL([String: String])
    
    enum SLBodyParameterEncodingType {
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
```

easy right ?. By this im creating a request wichh will be with body ( become automatically in POST. Take a look to body having an asociated type **SLBodyParameterEncodingType**

```swift
    enum SLBodyParameterEncodingType {
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
```


## All together. 
Asume we want to create an employee in the given url. 

     -> "https://aws4h.example.com/api/v1/create"

Code make look like this. 

```swift
        let person = Employee(name: "Jhon", salary: "430000", age: "45")
        
        let dispatcher = SLRequestDispatcher(env: APIEnv.dev, 
                                             networkSession: SLNetworkSession()) //1
        
        let personRequest = SLRequest(requestType: .body(.json(person)),
                                                         serviceName: "create") //2
        
        let operation = SLOperation(personRequest) //3
        
        operation.execute(in: dispatcher) { response in //4
            // do something with response
        }
```

Basically the idea is separate concerns about request, who make it and who perform it. 
1 - Dispatcher wrap network session with the environment. 
2 - Create the request 
3 - Pass the request to the operation
4 - Execute the operation on the dispatcher.

Thats all. Thank you so much, this is a first try of course theres a lot of improvements. 
