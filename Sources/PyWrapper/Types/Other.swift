import Foundation
import PyAstParser


public extension PyWrap {
	
	struct OtherType: TypeProtocol {
		
		public typealias AstType = AST.Name
		
		public var ast: AstType?
		
		public let py_type = PythonType.other
		
		public var wrapped: String
		
		public init(from ast: AstType, type: PythonType) {
			self.ast = ast
			self.wrapped = ast.id
		}
	}
	
}

extension PyWrap {
	
}


extension PyWrap.OtherType: CustomStringConvertible {
	public var description: String { wrapped }
}
