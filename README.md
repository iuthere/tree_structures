# tree_structures

tree_structures is a Dart implementation of (currently only) a red-black self-balancing binary search tree in Dart with a possibility to output to Graphviz for previewing.
Red-black tree solution is based on the logic and structure of the [Franck Bui-Huu's C implementation](https://github.com/fbuihuu/libtree/blob/master/rb.c).

Because of the pure Dart solution, it can't really reach high speeds, so the usage is simply educational.
The implementation focuses on correctness, providing assertion for conformance to the red-black tree rules during testing.
It also takes advantage of the Sound null safety.

The tree is generic, accepting `K extends Comparable` for the key, and any `V` for the value types.

Right now the benchmark is as following (with comparison to a regular `Map`), using `int` as keys:

## Count-based benchmark

```
count: 500000

adding random to a regular [map]: 116ms

adding random to [randomTree]: 309ms
testing conformity of [randomTree]: 71ms
searching in [randomTree]: 227ms

adding sequential to [sequentialTree]: 242ms
testing conformity of [sequentialTree]: 35ms
successor & predecessor in [sequentialTree]: 58ms
deletion in [sequentialTree]: 81ms
```

## Time-based benchmark

```
finished with 1328915 loops (332357 inserts, 996558 skipped inserts, 332272 deletions) within 5000ms, keys in [0..100) range.
```

## Keys output

```dart
var tree = RBTree<int, dynamic>();
tree.insert(100, "data associated with 100");
tree.insert(150, "data associated with 150");
tree.remove(100);
tree.insert(200, "data associated with 200");
tree.insert(20, "data associated with 20");
tree.insert(25, "data associated with 25");
tree.insert(18, "data associated with 18");
tree.insert(120, "data associated with 120");
tree.insert(180, "data associated with 180");
```

Output:
```
(150(20<r(18<b)(25>b(120>r)))(200>b(180<r)))
```

## `forEach`

```dart
tree.forEach((node) {
  print("${node.key}:${node.value}");
  return true; // continue
});
```

Output:
```
18:data associated with 18
20:data associated with 20
25:data associated with 25
120:data associated with 120
150:data associated with 150
180:data associated with 180
200:data associated with 200
```

## Output to `Graphviz`

```dart
print(tree.output(OutputStyle.Graphviz));
```

Output:
```
digraph {
  150[style=filled,color=black,fontcolor=white];
  150 -> 20;
  20[style=filled,color=tomato,fontcolor=white];
  20 -> 18;
  18[style=filled,color=black,fontcolor=white];
  null0 [shape=point];
  18 -> null0;
  null1 [shape=point];
  18 -> null1;
  20 -> 25;
  25[style=filled,color=black,fontcolor=white];
  null2 [shape=point];
  25 -> null2;
  25 -> 120;
  120[style=filled,color=tomato,fontcolor=white];
  null3 [shape=point];
  120 -> null3;
  null4 [shape=point];
  120 -> null4;
  150 -> 200;
  200[style=filled,color=black,fontcolor=white];
  200 -> 180;
  180[style=filled,color=tomato,fontcolor=white];
  null5 [shape=point];
  180 -> null5;
  null6 [shape=point];
  180 -> null6;
  null7 [shape=point];
  200 -> null7;
}
```

Graphviz to svg example output of the above tree (`dot -Tsvg <file.dot> > exmple_output.svg`):

![svg](https://raw.githubusercontent.com/iuthere/tree_structures/master/example_output.svg)