import Foundation
import PyAstParser


public extension PyWrap {
	
	struct OptionalType: TypeProtocol {

		public var ast: AstType?
		
		public let py_type = PythonType.optional
		public typealias AstType = AST.Subscript
		public var wrapped: any TypeProtocol
		
		public init(from ast: AST.Subscript, type: PythonType) {
			self.ast = ast
			self.wrapped = PyWrap.fromAST(any_ast: ast.slice)
		}
		
		public init(expr ast: ExprProtocol) {
			wrapped = PyWrap.fromAST(any_ast: ast)
		}
		public init(type: any TypeProtocol) {
			wrapped = type
		}
	}
	
}

extension PyWrap {
	
}


extension PyWrap.OptionalType: CustomStringConvertible {
	public var description: String { "\(Self.self)<\(wrapped.self)>"}
}
