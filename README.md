# RedBlack Readme

This is an implementation of red-black trees using Objective-C and plain-old C. The primary class of interest is PGRedBlackTree, which is a pure Objective-C class that does not support ARC. A lot of the internals are implemented using the PGRedBlackTreeNode abstract data type. I used C primarily for tail recursion, inline functions, and a little memory efficiency. I likely could have used Objective-C and achieved similar performance, but its dynamism is wasted on something like this, so we may as well drop into C.

All code is licensed under the MIT license. Do with it as you will.
