import 'dart:math';

/// [RBNode] represents a generic node for the red-black binary search tree.
class RBNode<K extends Comparable, V> {
  RBNode<K, V>? _left;
  RBNode<K, V>? _right;
  RBNode<K, V>? _parent;

  RBNode<K, V>? get left => _left;
  RBNode<K, V>? get right => _right;
  RBNode<K, V>? get parent => _parent;

  K _key;
  K get key => _key;

  V value;

  bool _red = true;
  bool get red => _red;

  RBNode(K key, V value)
      : _key = key,
        value = value;

  bool get isRoot => _parent == null;
  bool get isLeaf => _left == null && _right == null;
}

/// [InsertNodeResult] consists of two fields to describe a result of calling [RBTree.insertNode].
class InsertNodeResult<K extends Comparable, V> {
  RBNode<K, V> _inserted;

  /// [inserted] represents the node that has been added to the tree during [RBTree.insert]. If it replaced another node, the replaced one is returned as [detached].
  RBNode<K, V> get inserted => _inserted;
  RBNode<K, V>? _detached;

  /// [detached] represents the node that has been detached from the tree during [RBTree.insert], if it had the same key as newly added.
  RBNode<K, V>? get detached => _detached;

  InsertNodeResult(this._inserted, this._detached);
}

/// RBTree is a red-black tree binary search tree based on the [K] as key type, which should extend Comparable.
///
/// If the same key appears twice, it overwrites the node and returns a possible disconnected node via [InsertNodeResult] tuple.
///
/// http://www.cs.cornell.edu/courses/cs312/2004fa/lectures/lecture11.htm
///
/// Thank you Franck Bui-Huu for the C implementation.
/// https://github.com/fbuihuu/libtree/blob/master/rb.c
///
class RBTree<K extends Comparable, V> {
  RBNode<K, V>? _root;
  RBNode<K, V>? get root => _root;

  int _length = 0;
  int get length => _length;

  RBNode<K, V>? _first;
  RBNode<K, V>? get first => _first;

  RBNode<K, V>? _last;
  RBNode<K, V>? get last => _last;

  /// [insert] returns a [InsertNodeResult], consisting of the just [inserted] node and a possibly [detached] from the tree node
  /// if replacement had to happened.
  InsertNodeResult<K, V> insert(K key, V value) {
    var node = RBNode(key, value);
    return InsertNodeResult(node, insertNode(node));
  }

  /// [find] for the [key] in the tree. Provide [from] to search inside a subtree.
  RBNode<K, V>? find(K key, {RBNode<K, V>? from}) {
    if (from == null) from = _root;
    RBNode<K, V>? node = from;
    while (node != null && node._key != key) {
      if (key.compareTo(node._key) < 0)
        node = node._left;
      else
        node = node._right;
    }
    return node;
  }

  /// Syntax sugar for [find].
  RBNode<K, V>? operator [](K key) {
    return find(key);
  }

  /// operator will replace a [RBNode] if an existing [key] is used.
  void operator []=(K key, V value) {
    insert(key, value);
  }

  /// starting with [from] (which can be tree's root), which node is the minimum by key in this subtree.
  /// This may result in [from] itself, if it has no left node.
  RBNode<K, V> min(RBNode<K, V> from) {
    while (from._left != null) {
      from = from._left!;
    }
    return from;
  }

  /// starting with [from] (which can be tree's root), which node is the maximum by key in this subtree.
  /// This may result in [from] itself, if it has no right node.
  RBNode<K, V> max(RBNode<K, V> from) {
    while (from._right != null) {
      from = from._right!;
    }
    return from;
  }

  /// returns the node which key is the biggest of all the smaller than [node.key].
  RBNode<K, V>? predecessor(RBNode<K, V> node) {
    if (node._left != null) return max(node._left!);
    var p = node._parent;
    while (p != null && p._left == node) {
      node = p;
      p = p._parent;
    }
    return p;
  }

  /// returns the node which key is the smallest of all the greater than [node.key].
  RBNode<K, V>? successor(RBNode<K, V> node) {
    if (node._right != null) return min(node._right!);
    var p = node._parent;
    while (p != null && p._right == node) {
      node = p;
      p = p._parent;
    }
    return p;
  }

  _leftRotate(RBNode<K, V> node) {
    assert(node._right != null);
    var q = node._right!; // rotate left assumes right side is not null
    var parent = node._parent;
    if (parent == null) {
      _root = q;
    } else {
      if (parent._left == node) {
        parent._left = q;
      } else {
        parent._right = q;
      }
    }
    q._parent = parent;
    node._parent = q;
    node._right = q._left;
    if (node._right != null) node._right!._parent = node;
    q._left = node;
  }

  _rightRotate(RBNode<K, V> node) {
    assert(node._left != null);
    var q = node._left!; // rotate right assumes left side is not null
    var parent = node._parent;
    if (parent == null) {
      _root = q;
    } else {
      if (parent._left == node) {
        parent._left = q;
      } else {
        parent._right = q;
      }
    }
    q._parent = parent;
    node._parent = q;
    node._left = q._right;
    if (node._left != null) node._left!._parent = node;
    q._right = node;
  }

  /// [insertNode] will move the [node] from any current trees it may be at, thus destroying the other tree's integrity.
  ///
  /// [insertNode] implants the [node] into the tree at the right location and performs balancing.
  ///
  /// [insertNode] returns a possibly replaced node, which will be detached from the tree by nullifying its [RBNode.parent], [RBNode.left] and [RBNode.right].
  /// [insertMode] of a node that is already in the tree is a no-op and returns `null`.
  RBNode<K, V>? insertNode(RBNode<K, V> node) {
    RBNode<K, V>? found = root;
    RBNode<K, V>? parent;
    bool leftSide = false;
    while (found != null) {
      var cmp = node._key.compareTo(found._key);
      if (cmp == 0) {
        break;
      }
      parent = found;
      leftSide = cmp < 0;
      if (leftSide) {
        found = found._left;
      } else {
        found = found._right;
      }
    }
    if (found != null) {
      if (found == node) {
        return null;
      }
      // substituting the node
      var oldParent = found._parent;
      node._parent = oldParent;
      if (oldParent == null) {
        _root = node;
      } else {
        if (oldParent._left == found) {
          oldParent._left = node;
        } else {
          oldParent._right = node;
        }
      }
      if (found._left != null) found._left!._parent = node;
      if (found._right != null) found._right!._parent = node;
      node._red = found._red;
      node._left = found._left;
      node._right = found._right;
      if (_first == found) _first = node;
      if (_last == found) _last = node;
      found._parent = null;
      found._left = null;
      found._right = null;
      return found; // detached old node
    }
    node._left = null;
    node._right = null;
    node._red = true;
    node._parent = parent;
    if (parent == null) {
      _root = node;
      _first = node;
      _last = node;
    } else {
      if (leftSide) {
        if (parent == _first) _first = node;
      } else {
        if (parent == _last) _last = node;
      }
      if (leftSide) {
        parent._left = node;
      } else {
        parent._right = node;
      }
    }
    parent = node._parent;
    while (parent != null && parent._red) {
      var grandpa = parent._parent!;
      if (parent == grandpa._left) {
        var uncle = grandpa._right;
        if (uncle != null && uncle._red) {
          parent._red = false;
          uncle._red = false;
          grandpa._red = true;
          node = grandpa;
        } else {
          if (node == parent._right) {
            _leftRotate(parent);
            node = parent;
            parent = node._parent;
          }
          parent!._red = false;
          grandpa._red = true;
          _rightRotate(grandpa);
        }
      } else {
        var uncle = grandpa._left;
        if (uncle != null && uncle._red) {
          parent._red = false;
          uncle._red = false;
          grandpa._red = true;
          node = grandpa;
        } else {
          if (node == parent._left) {
            _rightRotate(parent);
            node = parent;
            parent = node._parent;
          }
          parent!._red = false;
          grandpa._red = true;
          _leftRotate(grandpa);
        }
      }
      parent = node._parent;
    }
    root!._red = false;
    _length++;
    return null;
  }

  remove(K key) {
    var node = find(key);
    if (node == null) return;
    var parent = node._parent;
    var left = node._left;
    var right = node._right;
    RBNode<K, V>? next;
    if (node == _first) _first = successor(node);
    if (node == _last) _last = predecessor(node);
    if (left == null) {
      next = right;
    } else if (right == null) {
      next = left;
    } else {
      next = min(right);
    }
    if (parent != null) {
      if (parent._left == node) {
        parent._left = next;
      } else {
        parent._right = next;
      }
    } else {
      _root = next;
    }
    _length--;
    bool r;
    if (left != null && right != null) {
      r = next!._red;
      next._red = node._red;
      next._left = left;
      left._parent = next;
      if (next != right) {
        parent = next._parent;
        next._parent = node._parent;
        node = next._right;
        parent!._left = node;
        next._right = right;
        right._parent = next;
      } else {
        next._parent = parent;
        parent = next;
        node = next._right;
      }
    } else {
      r = node._red;
      node = next;
    }
    if (node != null) {
      node._parent = parent;
    }
    if (r) {
      return;
    }
    if (node != null && node._red) {
      node._red = false;
      return;
    }
    do {
      if (node == root) break;
      if (node == parent!._left) {
        var sibling = parent._right;
        if (sibling!._red) {
          sibling._red = false;
          parent._red = true;
          _leftRotate(parent);
          sibling = parent._right;
        }
        if (sibling != null &&
            ((sibling._left == null || !sibling._left!._red) &&
                (sibling._right == null || !sibling._right!._red))) {
          sibling._red = true;
          node = parent;
          parent = parent._parent;
          continue;
        }
        if (sibling!._right == null || !sibling._right!._red) {
          sibling._left!._red = false;
          sibling._red = true;
          _rightRotate(sibling);
          sibling = parent._right;
        }
        sibling!._red = parent._red;
        parent._red = false;
        sibling._right!._red = false;
        _leftRotate(parent);
        node = root;
        break;
      } else {
        var sibling = parent._left;
        if (sibling!._red) {
          sibling._red = false;
          parent._red = true;
          _rightRotate(parent);
          sibling = parent._left;
        }
        if (sibling != null &&
            ((sibling._left == null || !sibling._left!._red) &&
                (sibling._right == null || !sibling._right!._red))) {
          sibling._red = true;
          node = parent;
          parent = parent._parent;
          continue;
        }
        if (sibling!._left == null || !sibling._left!._red) {
          sibling._right!._red = false;
          sibling._red = true;
          _leftRotate(sibling);
          sibling = parent._left;
        }
        sibling!._red = parent._red;
        parent._red = false;
        sibling._left!._red = false;
        _rightRotate(parent);
        node = root;
        break;
      }
    } while (!node._red);
    node?._red = false;
  }

  /// toString() will act as `output(OutputStyle.KeyDesc).toString()`.
  @override
  String toString() {
    return output(OutputStyle.KeyDesc).toString();
  }

  /// output returns a [StringBuilder] and allows to specify how to output the tree.
  StringBuffer output(OutputStyle style) {
    var b = StringBuffer();
    if (style == OutputStyle.Graphviz) {
      b.write("digraph {");
    }
    _convert(_root, b, style, _PrimitiveWrapper<int>(0), 0);
    if (style == OutputStyle.Graphviz) {
      b.write("\n}");
    }
    return b;
  }

  _convert(RBNode<K, V>? n, StringBuffer b, OutputStyle style,
      _PrimitiveWrapper<int> idx, int side) {
    if (n == null) {
      return;
    }
    switch (style) {
      case OutputStyle.KeyDesc:
        b.write("(${n._key}");
        if (side != 0) {
          b.write(side < 0 ? "<" : ">");
          b.write(n._red ? "r" : "b");
        } // avoid any output for root
        if (n._left != null) _convert(n._left, b, style, idx, -1);
        if (n._right != null) _convert(n._right, b, style, idx, 1);
        b.write(")");
        break;
      case OutputStyle.KeyList:
        if (b.length > 0) b.write(",");
        b.write("${n._key}");
        if (n._left != null) _convert(n._left, b, style, idx, -1);
        if (n._right != null) _convert(n._right, b, style, idx, 1);
        break;
      case OutputStyle.Graphviz:
        if (n._parent != null) {
          if (b.length > 0) {
            b.write("\n");
          }
          b.write("  ${n._parent!._key.toString()} -> ${n._key.toString()};");
        }
        // style is needed for the root node too
        _writeStyle(b, n._key.toString(), n._red ? "tomato" : "black");
        if (n._left == null) {
          _writeNull(b, idx, n);
        } else {
          _convert(n._left, b, style, idx, 1);
        }
        if (n._right == null) {
          _writeNull(b, idx, n);
        } else {
          _convert(n._right, b, style, idx, -1);
        }
    }
  }

  void _writeStyle(StringBuffer b, String name, String color) {
    if (b.length > 0) {
      b.write("\n");
    }
    b.write("  $name[style=filled,color=$color,fontcolor=white];");
  }

  void _writeNull(StringBuffer b, _PrimitiveWrapper<int> idx, RBNode<K, V> n) {
    if (b.length > 0) {
      b.write("\n");
    }
    b.write("  null$idx [shape=point];\n");
    b.write("  ${n._key.toString()} -> null$idx;");
    idx._value++;
  }

  /// forEach visits every node starting with the [min] and moves to [successor] and
  /// calls a callback for each one of the node with an option to interrupt the
  /// flow by returning [false] out of it.
  forEach(bool Function(RBNode<K, V> node) callback) {
    if (root == null) return;
    RBNode<K, V>? node = min(root!);
    while (node != null) {
      if (callback(node)) {
        node = successor(node);
      } else {
        break;
      }
    }
  }

  /// [assertConformity] can be used in tests to check whether the tree conforms to all the red-black tree rules:
  ///
  /// 1. Every node is either red or black (provided by [red] boolean)
  /// 2. The root is black.
  /// 3. Every null-leaf is black (provided by design).
  /// 4. If a node is red, then both its children are black (in other words, a red child can't have a red parent).
  /// 5. For each node, all simple paths from the node to descendant leaves contain the
  /// same number of black nodes.
  assertConformity() {
    if (root != null) assert(root!._red == false); // #2
    var cnt = 0;
    forEach((v) {
      if (v.isLeaf) {
        var count = 0;
        RBNode<K, V>? s = v;
        while (s != null) {
          if (s.red) {
            if (s._parent != null) assert(!s._parent!._red); // #4
          } else {
            count++; // #5 amount of blacks in a leaf
          }
          s = s.parent;
        }
        if (cnt == 0) cnt = count;
        assert(count == cnt);
      }
      return true;
    });
  }

  RBNode<K, V>? randomNode(Random rnd) {
    if (_root == null) return null;
    RBNode<K, V>? toDelete;
    var idx = rnd.nextInt(_length);
    var i = 0;
    forEach((node) {
      if (idx == i) {
        toDelete = node;
        return false;
      }
      i++;
      return true;
    });
    return toDelete;
  }
}

enum OutputStyle {
  /// Outputs as something like `(50.b(45<r(25<b)(48>b(46<r)))(150>r(60<b)(180>b(190>r))))`.
  KeyDesc,

  /// Outputs as comma-separated keys.
  KeyList,

  /// Outputs as `digraph { ... }`.
  Graphviz,
}

class _PrimitiveWrapper<T> {
  T _value;
  _PrimitiveWrapper(this._value);
  @override
  String toString() {
    return _value.toString();
  }
}
