

import Foundation
import PyWrapper
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftParser


extension PyWrap.Module {
	public func file() throws -> SourceFileSyntax {
		.init(statements: try .init {
			"Foundation".import
			"PySwiftCore".import
			"PySwiftObject".import
			"PyUnpack".import
			
			for cls in classes {
				try cls.codeBlock()
			}
			PyMethods(methods: functions, is_public: true, custom_title: "\(filename)PyMethods").output
			createPyInitExt
		})
		
		
	}
}



extension PyWrap.Module {
	
	fileprivate func PyModule_AddType(ext cls: PyWrap.Class) -> FunctionCallExprSyntax {
		
		
		return .init(callee: ExprSyntax(stringLiteral: "PyModule_AddType")) {
			.init {
				LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "m"))
				LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "\(cls.name).PyType"))
			}
		}
	}
	fileprivate var createPyModuleDef: VariableDeclSyntax {
		.init(.var, name: "", type: .init(type:TypeSyntax(stringLiteral: "PyModuleDef")), initializer: .init(value: ExprSyntax(stringLiteral: """
		.init(
			m_base: _PyModuleDef_HEAD_INIT,
			m_name: cString("\(filename)"),
			m_doc: nil,
			m_size: -1,
			m_methods: .init(&\(filename)PyMethods),
			m_slots: nil,
			m_traverse: nil,
			m_clear: nil,
			m_free: nil
		)
		""")))
	}
	
	fileprivate var createPyInitExt: FunctionDeclSyntax {
		
		
		let sig = FunctionSignatureSyntax(
			input: .init(parameterList: .init([])),
			output: .init(returnType: OptionalTypeSyntax(wrappedType: TypeSyntax(stringLiteral: "PyPointer")))
		)
		let f_expr = FunctionCallExprSyntax(name: "PyModule_Create2") {
			LabeledExprSyntax(expression: ExprSyntax(stringLiteral: ".init(&\(filename)_module)"))
			LabeledExprSyntax(expression: IntegerLiteralExprSyntax(integerLiteral: 3))
		}
		let initializer = InitializerClauseSyntax(value: f_expr)
		
		return .init(
			modifiers: [.init(name: .keyword(.public))],
			identifier: .identifier("PyInit_\(filename)"),
			signature: sig) {
				let pattern = PatternSyntax(stringLiteral: "m")
				let con = ConditionElementListSyntax {
					OptionalBindingConditionSyntax(bindingSpecifier: .keyword(.let), pattern: pattern, initializer: initializer)
				}
				IfExprSyntax(conditions: con) {
					for cls in classes {
						PyModule_AddType(ext: cls)
					}
					"return m"
				}

				"return nil"
			}
	}
	
}
