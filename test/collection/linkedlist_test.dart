library spatially.base.linkedlist_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/collection.dart';

main() {
  test("should be able to add an element to the end of list", () {
    LinkedList<int> li = new LinkedList();
    li.add(1);
    li.add(2);
    expect(li, [1,2]);
    expect(li.length, 2);
  });

  test("should be able to add an iterable to the end of a list", () {
    LinkedList<int> li = new LinkedList();
    li.addAll([1,2,3]);
    expect(li, [1,2,3]);
    expect(li.length, 3);
  });

  test("should be able to add an element to the start of a list", () {
    LinkedList<int> li = new LinkedList();
    li.addFirst(2);
    li.addFirst(1);
    expect(li, [1,2]);
    expect(li.length, 2);
  });

  test("should be able to remove an element from the start of a list", () {
    LinkedList<int> li = new LinkedList.from([1,1,2,3,4,5]);
    var removed = li.removeFirst();
    expect(removed, 1);
    expect(li, [1,2,3,4,5]);
    expect(li.length, 5);

    LinkedList li2 = new LinkedList();
    expect(() => li2.removeFirst(), throws, reason: "no elements");
  });

  test("should be able to remove an element from the end of a list", () {
    LinkedList<int> li = new LinkedList.from([1,2,3,4,5,5]);
    var removed = li.removeLast();
    expect(removed, 5);
    expect(li, [1,2,3,4,5]);
    expect(li.length, 5);


    LinkedList li2 = new LinkedList();
    expect(() => li2.removeLast(), throws, reason: "no elements");
  });

  test("should be able to get an element at an index", () {
    LinkedList<int> li = new LinkedList.from([0,1,2,3,4]);
    expect(li.elementAt(3), 3);
    expect(() => li.elementAt(-1), throws, reason: "index < 0");
    expect(() => li.elementAt(5), throws, reason: "index > length");
  });

  test("should be able to get a node at a particular index", () {
    LinkedList<int> li = new LinkedList.from([0,1,2,3,4,5]);
    var node = li.nodeAt(3);
    expect(node.value, 3, reason: "node value");
    expect(node.prev.value, 2, reason: "previous node value");
    expect(node.next.value, 4, reason: "next node value");
  });

  test("should be able to remove a node from the list", () {
    LinkedList<int> li = new LinkedList.from([0,1,2,3,4,5]);

    var node = li.nodeAt(3);
    li.remove(node);
    expect(li, [0,1,2,4,5]);
    expect(li.length, 5);

    expect(() => li.remove(node), throws, reason: "node already removed");

    var node2 = li.nodeAt(2);
    node2.remove();
    expect(li, [0,1,4,5], reason: "removed from node view");
    expect(li.length, 4, reason: "removed from node view");
    expect(() => node2.remove(), throws, reason: "node already removed");
  });

  test("should be able to insert a value after a particular node", () {
    LinkedList<int> l = new LinkedList.from([0,1,2,4,5]);
    var node = l.nodeAt(2);
    l.insertAfter(node, 3);
    expect(l, [0,1,2,3,4,5]);

    node.append(9);
    expect(l, [0,1,2,9,3,4,5], reason: "insert from node");
    expect(l.length, 7);

    node.remove();
    expect(() => l.insertAfter(node, 44), throws, reason: "node already removed");
    expect(() => node.prepend(44), throws, reason: "node already removed");
  });

  test("should be able to insert a value before a particular node", () {
    LinkedList<int> l = new LinkedList.from([0,1,3,4,5]);
    var node = l.nodeAt(2);
    l.insertBefore(node, 2);
    expect(l, [0,1,2,3,4,5]);

    node.prepend(9);
    expect(l, [0,1,2,9,3,4,5], reason: "insert from node");
    expect(l.length, 7);

    node.remove();
    expect(() => l.insertBefore(node, 44), throws, reason: "node already removed");
    expect(() => node.prepend(44), throws, reason: "node already removed");
  });

  test("should be able to clear the list", () {
    LinkedList<int> l = new LinkedList.from([0,1,2,3,4,5]);
    l.clear();
    expect(l, []);
    expect(l.length, 0);
  });

  test("should be able to get the first element of the list", () {
    LinkedList<int> l = new LinkedList.from([0,1,2,3,4,5]);
    expect(l.first, 0);

    LinkedList l2 = new LinkedList();
    expect(() => l2.first, throws, reason: "no elements");
  });

  test("should be able to get the last element of the list", () {
    LinkedList<int> l = new LinkedList.from([0,1,2,3,4,5]);
    expect(l.last, 5);

    LinkedList l2 = new LinkedList();
    expect(() => l2.last, throws, reason: "no elements");
  });

  test("should be able to get the single element from the list", () {
    LinkedList<int> l = new LinkedList.from([1]);
    expect(l.single, 1);

    LinkedList<int> l2 = new LinkedList();
    expect(() => l2.single, throws, reason: "no elements");

    LinkedList<int> l3 = new LinkedList.from([0,1,2,3,4,5]);
    expect(() => l3.single, throws, reason: "too many elements");
  });

  test("should not be able to modify the list while iterating", () {
    LinkedList<int> li = new LinkedList.from([1,2,3,4,5]);
    expect(() => li.forEach((_) => li.removeFirst()), throws, reason: "concurrent modification");
  });

}