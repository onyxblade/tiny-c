# tiny-c

Please check test cases for the usage and supported syntax of this demo. 

I implemented a DSL to generate a parser. It uses DFS to search for sytax rule matches, which allows the definition to be simple but cannot display error messages like "unexpected token xxx".

Only `long` is supported, and `int`s are processed as `long`s. 


## 中文说明

用法参照测试用例，测试用例以外的应该都不支持。。

parser是自己写的DSL，用深度优先搜索，这样定义语法规则比较简洁，但是坏处是没法提示"unexpected token xxx"这样细致的错误信息。

解释器和编译器都是一次递归里完成的，因为搞不定寄存器分配的算法，所以有比较多的压栈出栈，让每个调用都完全隔离了。目前只支持了long类型，int也都是当long处理的。
