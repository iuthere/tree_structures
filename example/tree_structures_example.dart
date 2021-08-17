import 'package:tree_structures/tree_structures.dart';

main() {
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
  print(tree);
  tree.forEach((node) {
    print("${node.key}:${node.value}");
    return true; // continue
  });
  print(tree.output(OutputStyle.Graphviz));
  var sb = StringBuffer();
  tree.forEach((node) {
    if (sb.length > 0) {
      sb.write(",");
    }
    sb.write("${node.key}");
    return true;
  });
  print(sb.toString());
}
