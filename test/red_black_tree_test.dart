import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tree_structures/tree_structures.dart';

extension on Stopwatch {
  restart() {
    reset();
    start();
  }

  reportMs(String message) {
    stop();
    stdout.write("$message: ${elapsed.inMilliseconds}ms\n");
    reset();
  }
}

void main() {
  test("Example", () {
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
    print("\n");
    tree.forEach((node) {
      print("${node.key}:${node.value}");
      return true; // continue
    });
    print("\n");
    print(tree.output(OutputStyle.Graphviz));
    // outputToDotAndSvg(tree, "output");
  });
  test("RBTree Expectation", () {
    var tree = RBTree<int, dynamic>();
    var _e = (String v, int size) {
      tree.assertConformity();
      expect(tree.output(OutputStyle.KeyDesc).toString(), v);
      expect(tree.length, size);
    };
    _e("", 0);
    expect(tree.first, null);
    expect(tree.last, null);
    tree.insert(100, "");
    _e("(100)", 1);
    tree.remove(100);
    _e("", 0);
    expect(tree.root, null);
    tree.insert(100, "");
    tree.insert(150, "");
    _e("(100(150>r))", 2);
    tree.insert(90, "");
    _e("(100(90<r)(150>r))", 3);
    tree.insert(50, "");
    _e("(100(90<b(50<r))(150>b))", 4);
    tree.remove(90);
    _e("(100(50<b)(150>b))", 3);
    tree.insert(90, "");
    _e("(100(50<b(90>r))(150>b))", 4);
    tree.insert(80, "");
    _e("(100(80<b(50<r)(90>r))(150>b))", 5);
    expect(tree.first, tree.find(50));
    expect(tree.last, tree.find(150));
    expect("100,80,50,90,150", tree.output(OutputStyle.KeyList).toString());
    tree.remove(80);
    _e("(100(90<b(50<r))(150>b))", 4);
    tree.remove(100);
    _e("(90(50<b)(150>b))", 3);
    tree.insert(60, "");
    _e("(90(50<b(60>r))(150>b))", 4);
    tree.insert(45, "");
    _e("(90(50<b(45<r)(60>r))(150>b))", 5);
    tree.insert(25, "");
    _e("(90(50<r(45<b(25<r))(60>b))(150>b))", 6);
    tree.insert(48, "");
    _e("(90(50<r(45<b(25<r)(48>r))(60>b))(150>b))", 7);
    expect(tree.first, tree.find(25));
    expect(tree.last, tree.find(150));

    tree.insert(48, ""); // duplicate
    tree.insert(60, ""); // duplicate

    tree.insert(46, "");
    _e("(50(45<r(25<b)(48>b(46<r)))(90>r(60<b)(150>b)))", 8);
    tree.insert(180, "");
    _e("(50(45<r(25<b)(48>b(46<r)))(90>r(60<b)(150>b(180>r))))", 9);
    tree.insert(190, "");
    _e("(50(45<r(25<b)(48>b(46<r)))(90>r(60<b)(180>b(150<r)(190>r))))", 10);
    expect(tree.first!.key, 25);
    expect(tree.last!.key, 190);

    var sb = StringBuffer();
    tree.forEach((node) {
      if (sb.length > 0) {
        sb.write(",");
      }
      sb.write("${node.key}");
      return true;
    });
    expect(
      sb.toString(),
      "25,45,46,48,50,60,90,150,180,190",
    );

    //outputToDotAndSvg(tree, "test");
    tree.remove(90);
    _e("(50(45<r(25<b)(48>b(46<r)))(150>r(60<b)(180>b(190>r))))", 9);
    tree.remove(48);
    _e("(50(45<r(25<b)(46>b))(150>r(60<b)(180>b(190>r))))", 8);
    tree.remove(50);
    _e("(60(45<r(25<b)(46>b))(180>r(150<b)(190>b)))", 7);
    tree.remove(45);
    _e("(60(46<b(25<r))(180>r(150<b)(190>b)))", 6);
    tree.remove(46);
    expect(tree.first, tree.find(25));
    expect(tree.last, tree.find(190));
    _e("(60(25<b)(180>r(150<b)(190>b)))", 5);
    tree.remove(150);
    _e("(60(25<b)(180>b(190>r)))", 4);
    tree.remove(25);
    _e("(180(60<b)(190>b))", 3);
    expect(tree.first, tree.find(60));
    expect(tree.last, tree.find(190));
    tree.remove(60);
    _e("(180(190>r))", 2);
    tree.remove(190);
    _e("(180)", 1);
    tree.remove(180);
    _e("", 0);
    expect(tree.root, null);
    expect(tree.first, null);
    expect(tree.last, null);
  });
  test("RBTree Performance", () async {
    //var count = 5000000;
    var count = 500000;
    stdout.write("count: $count\n");

    var rnd = Random();

    var timer = Stopwatch();
    timer.restart();
    var map = Map<int, dynamic>();
    for (int i = 0; i < count; i++) {
      var v = rnd.nextInt(count * 10);
      map[v] = v;
      assert(map[v] == v);
    }
    timer.reportMs("adding random to a regular [map]");

    timer.restart();
    var randomTree = RBTree<int, dynamic>();
    map.forEach((key, value) {
      /*var pair = */ randomTree.insert(key, value);
    });
    assert(randomTree.length == map.length);
    // for (int i = 0; i < count; i++) {
    //   var v = rnd.nextInt(count * 10);
    //   var pair = randomTree.insertKV(v, v);
    //   //var found = randomTree.search(randomTree.root!, v);
    //   //assert(found?.value == v);
    //   //assert(found == pair.added);
    // }
    timer.reportMs("adding random to [randomTree]");

    timer.restart();
    randomTree.assertConformity();
    timer.reportMs("testing conformity of [randomTree]");

    timer.restart();

    assert(randomTree.root != null);
    map.forEach((key, value) {
      assert(key == value);
      var f = randomTree.find(key);
      assert(f != null && f.key == key);
    });

    timer.reportMs("searching in [randomTree]");

    timer.restart();
    var sequentialTree = RBTree<int, dynamic>();
    for (int i = 0; i < count; i++) {
      var pair = sequentialTree.insert(i, i);
      var found = sequentialTree.find(i);
      assert(found?.value == i);
      assert(found == pair.inserted);
      assert(sequentialTree.min(sequentialTree.root!).key == 0);
      assert(sequentialTree.max(sequentialTree.root!).key == i);
    }

    timer.reportMs("adding sequential to [sequentialTree]");

    timer.restart();
    sequentialTree.assertConformity();
    timer.reportMs("testing conformity of [sequentialTree]");

    timer.restart();
    for (int i = 0; i < count; i++) {
      var found = sequentialTree.find(i);
      assert(found != null);
      assert(found?.value == i);
      var successor = sequentialTree.successor(found!);
      if (successor == null) {
        assert(i == count - 1);
      } else {
        assert(i + 1 == successor.key);
      }
      var predecessor = sequentialTree.predecessor(found);
      if (predecessor == null) {
        assert(i == 0);
      } else {
        assert(i - 1 == predecessor.key);
      }
    }
    timer.reportMs("successor & predecessor in [sequentialTree]");

    timer.restart();
    for (int i = 0; i < count; i++) {
      var found = sequentialTree.find(i);
      assert(found != null);
      sequentialTree.remove(found!.key);
      if (sequentialTree.root == null) {
        assert(i == count - 1);
      } else {
        found = sequentialTree.find(i);
        assert(found == null);
      }
    }
    timer.reportMs("deletion in [sequentialTree]");
  });
  test("RBTree Random Insert/Delete", () {
    RBTree<int, dynamic> tree = RBTree<int, dynamic>();
    var rnd = Random();
    var timerMs = 5000;
    var range = 100;

    var timer = Stopwatch();
    timer.start();
    var count = 0;
    var operations = 0;
    var inserts = 0;
    var skippedInserts = 0;
    var deletions = 0;
    while (timer.elapsedMilliseconds < timerMs) {
      var key = rnd.nextInt(range);
      var result = tree.insert(key, key);
      if (result.detached == null) {
        inserts++;
        count++;
      } else {
        skippedInserts++;
      }
      expect(tree.length, count);
      tree.assertConformity();

      if (rnd.nextInt(4) < 1) {
        var toDelete = tree.randomNode(rnd);
        if (toDelete != null) {
          tree.remove(toDelete.key);
          deletions++;
          count--;
          expect(tree.length, count);
          tree.assertConformity();
        }
      }
      operations++;
    }
    stdout.write(
      "finished with $operations loops ($inserts inserts, $skippedInserts skipped inserts, $deletions deletions) within ${timerMs}ms, keys in [0..$range) range.\n",
    );

    //print(tree.output(OutputStyle.KeyList));
    //outputToDotAndSvg(tree, "rb_tree_test");
    //outputToFile(tree.marshal(), "test.txt");
    while (tree.length > 0) {
      var toDelete = tree.randomNode(rnd);
      assert(toDelete != null);
      tree.remove(toDelete!.key);
      tree.assertConformity();
    }
    tree.assertConformity();
  });
}

outputToDotAndSvg(RBTree<int, dynamic> tree, String name) async {
  var path = './test/$name.dot';
  var pathSvg = './test/$name.svg';
  var out = File(path).openWrite();
  out.write(tree.output(OutputStyle.Graphviz).toString());
  await out.flush();
  await out.close();
  var result = await Process.run('dot', ['-Tsvg', path]);
  var outSvg = File(pathSvg).openWrite();
  outSvg.write(result.stdout);
  await outSvg.flush();
  await outSvg.close();
}

outputToFile(Uint8List bytes, String name) {
  var path = './test/$name';
  var out = File(path);
  out.openWrite();
  out.writeAsBytes(bytes, flush: true);
}
