(module
  (func $log (import "imports" "ilog") (param i32))
  (func $add (export "add") (param $a i32) (param $b i32) (result i32)
    i32.const 42
    call $log

    local.get $a
    local.get $b
    i32.add)
)
