import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
//    router.post(<#T##path: PathComponentsRepresentable...##PathComponentsRepresentable#>) { (<#Request#>) -> ResponseEncodable in
//        <#code#>
//    }
    
    router.post("isEmailValid") { (req) -> Future<HTTPStatus> in
        return try! req.content.decode(LoginRequest.self).map(to: HTTPStatus.self) { loginRequest in
            print(loginRequest.email)
            print(loginRequest.password)
            if let _ = Email.init(loginRequest.email) {
                return .ok
            }
            else {
                return .forbidden
            }
        }
    }
    router.post("login") { (req) -> Future<User> in
        return try! req.content.decode(LoginRequest.self).map(to: User.self) { loginRequest in
            print(loginRequest.email)
            print(loginRequest.password)
            return User(name: String(loginRequest.email.split(separator: "@").first ?? ""), email: loginRequest.email)
        }
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}


struct LoginRequest: Content {
    var email: String
    var password: String
}
struct User: Content {
    var name: String
    var email: String
}

struct Email {
    static let  REGEX: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,32}"
    let email: String
    
    init? (_ email : String) {
        
        guard NSPredicate(format: "SELF MATCHES %@", Email.REGEX).evaluate(with: email) else {
            return nil
        }
        self.email = email
    }
}
