;; extends

; Pin statement-level call chains whose argument is a function literal, e.g.
;   ctl.ForPath("start", "deliverer").
;       Description("...").
;       Exec(func(v cf.Viper) error { ... })
; The bundled query only pins the inner `func {` (the func_literal), so when you
; scroll deep into the callback you lose the builder line that says *which*
; command/path you're configuring. We only pin the receiver line itself (a
; @context with no @context.end shows a single line); the bundled func_literal
; rule already pins the inner `func {`, so extending down to it would duplicate
; that line. The (func_literal) below is just a match filter so this only fires
; for callback-style chains, not every statement-level call.
(expression_statement
  (call_expression
    (argument_list
      (func_literal)))) @context
