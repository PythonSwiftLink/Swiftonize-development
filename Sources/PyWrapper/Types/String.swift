
import Foundation
import PyAstParser



public extension PyWrap {
	
	struct StringType: TypeProtocol {
		public static func fromAST(ast: PyAstParser.AST.Name, type: PythonType) -> PyWrap.StringType {
			fatalError()
		}
		
		
		public var ast: AstType?
		
		public typealias AstType = AST.Name
		
		public var py_type: PythonType
		
		init(ast: PyAstParser.AST.Name, py_type: PythonType) {
			self.ast = ast
			self.py_type = py_type
			
		}
		public init(from ast: AST.Name, type: PythonType) {
			self.ast = ast
			self.py_type = type
			
		}
		public static func fromAST(_ ast: PyAstParser.AST.Name, type: PythonType) -> any TypeProtocol {
			Self.init(ast: ast, py_type: type)
		}
		
	}
	
	
}
extension PyWrap.StringType: CustomStringConvertible {
	public var description: String { "\(Self.self)" }
}


extension PyWrap.StringArg {
	public static func fromAST(_ ast: AST.Name, type: PythonType, ast_arg: AST.Arg) -> AnyArg {
		Self.init(ast: ast_arg, type: PyWrap.StringType.init(ast: ast, py_type: type))
	}
}


