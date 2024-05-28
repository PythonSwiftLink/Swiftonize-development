import Foundation
import PyAst



extension AST.Name: CustomDebugStringConvertible, CustomStringConvertible {
	public var debugDescription: String {
		id
	}
	
	public var description: String { id }
}

extension AST.Arg: CustomStringConvertible {
	public var description: String { (annotation as? CustomStringConvertible)?.description ?? "\(annotation)" }
}
public extension PyWrap {
	
	class Function {
		
		
		public weak var `class`: Class?
		
		public var args: [AnyArg]
		
		public var vararg: AnyArg?
		
		public var kwargs: AnyArg?
		
		public var ast: AST.FunctionDef
		
		public var returns: (any TypeProtocol)?
		
		public var `static`: Bool
		
		public var call_target: String?
		
		init(ast: AST.FunctionDef, cls: Class? = nil) {
			  print("###########################################################")
			self.ast = ast
			self.class = cls
			  print(ast.name)
			
			//self.args = ast.args.args.enumerated().compactMap(PyWrap.fromAST)
			let no_labels = ast.decorator_list.compactMap({ deco in
				switch deco.type {
				case .Call:
					let call = deco as! AST.Call
					if let _func = call._func as? AST.Name {
						switch _func.id {
						case "no_labels": return Self.handleNoLabels(call)
						default: fatalError()
						}
					}
				case .Name: return ["*"]
				default: fatalError(deco.type.rawValue)
				}
				return nil
			})
			let no_labels_all = no_labels.contains(["*"])
			let filtered = ast.args.args.filter({$0.arg != "self"})
			self.args = filtered.enumerated().compactMap({ i, arg in
				if let annotation = arg.annotation {
					var out: AnyArg = PyWrap.fromAST(annotation, ast_arg: arg)
					out.index = i
					if no_labels_all { out.options.append(.no_label)}
					return out
				}
				return PyObjectArg(ast: arg)
			})
			dump(args)
			// so easy to check if *args is used, if not present vararg is nil
//			if let vararg = ast.args.vararg {
//				if let annotation = vararg.annotation {
//					self.vararg = PyWrap.fromAST(annotation, ast_arg: vararg)
//				} else {
//					self.vararg = PyObjectArg(ast: vararg)
//				}
//				
//				print("vararg: *\(self.vararg!.type)")
//			}
			// same with **kwargs, if not present kwarg is nil
//			if let kw = ast.args.kwarg {
//				if let annotation = kw.annotation {
//					kwargs = PyWrap.fromAST(annotation, ast_arg: kw)
//				} else {
//					self.kwargs = PyObjectArg(ast: kw)
//				}
//				
//				print("**kw: \(kwargs!.type)")
//			}
//			
			if let returns = ast.returns {
				self.returns = PyWrap.fromAST(any_ast: returns)
				print("return type: \(self.returns!)")
			}
//			print(self.args.map(\.type))
			self.static = ast.decorator_list.contains(name: "staticmethod")
			  print("###########################################################\n")
		}
		
	}
}



extension PyWrap.Function {
	public var arguments: AST.Arguments { ast.args }
	public var name: String { ast.name }
	public var defaults_name: [String] { arguments.defaults.compactMap({ d in
		if let _name = d as? AST.Name {
			return _name.id
		}
		return nil
	}) }
	
	public var `throws`: Bool { ast.decorator_list.contains { expr in
		if let _name = expr as? AST.Name {
			return _name.id == "throws"
		}
		return false
	}}
	
	static func handleNoLabels(_ call: AST.Call) -> [String] {
		if call.keywords.isEmpty { return ["*"] }
		if call.args.isEmpty { return ["*"] }
		fatalError()
		return ["*"]
		
	}
}
