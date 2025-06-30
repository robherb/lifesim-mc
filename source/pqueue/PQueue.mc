import Toybox.Lang;
import Toybox.System;

// Min Priority Queue
class PQueue {

    (:initialized)
    var q as Array<PQAble>;
    private var size as Number = -1;

    function initialize(size as Number) {
        // System.println(q.toString());
        q = new Array<PQAble>[size];
    }

    function isEmpty() as Boolean {
        return size < 0;
    }

    function getSize() as Number {
        return size + 1;
    }

    // Function to return the index of the parent node of a given node
    function parent(i as Number) as Number {
        return (i - 1) / 2;
    }

    // Function to return the index of the left child of the given node
    function leftChild(i as Number) as Number {
        return ((2 * i) + 1);
    }

    // Function to return the index of the right child of the given node
    function rightChild(i as Number) as Number {
        return ((2 * i) + 2);
    }

    // Function to shift up the node in order to maintain the heap property
    function shiftUp(i as Number) as Void {
        while (i > 0 && q[parent(i)][0] > q[i][0]) {
            // Swap parent and current node
            swap(parent(i), i);

            // Update i to parent of i
            i = parent(i);
        }
    }

    // Function to shift down the node in order to maintain the heap property
    function shiftDown(i as Number) as Void {
        var maxIndex = i;

        // Left Child
        var l = leftChild(i);

        if (l <= size && q[l][0] < q[maxIndex][0]) {
            maxIndex = l;
        }

        // Right Child
        var r = rightChild(i);

        if (r <= size && q[r][0] < q[maxIndex][0]) {
            maxIndex = r;
        }

        // If i not same as maxIndex
        if (i != maxIndex) {
            swap(i, maxIndex);
            shiftDown(maxIndex);
        }
    }

    // Function to insert a new element in the Binary Heap
    function insert(p as PQAble) as Void {
        size = size + 1;
        p[1].qIdx = size;
        q[size] = p;

        // System.println("insert " + p);

        // Shift Up to maintain heap property
        shiftUp(size);
    }

    // Function to extract the element with highest priority (lowest value)
    function extractNext() as PQAble {
        var result = q[0];

        // Replace the value at the root with the last leaf
        q[0] = q[size];
        size = size - 1;

        // Shift down the replaced element to maintain the heap property
        shiftDown(0);
        return result;
    }

    // Function to change the priority of an element
    function changePriority(i as Number, p as Number) as Void {
        var oldp = q[i];
        q[i][0] = p;

        if (p < oldp[0]) {
            shiftUp(i);
        } else {
            shiftDown(i);
        }
    }

    // Function to get value of the current highest priority (lowest value) element
    function getHighest() as PQAble {
        return q[0];
    }

    // Function to remove the element located at given index
    function remove(i as Number) as PQAble {
        // System.println("killing: " + q[i][1] + " remove param idx: " + i);// + " " + q[i][1].toString());
        q[i][0] = getHighest()[0] - 1;
        q[i][1].qIdx = i;

        // Shift the node to the root of the heap
        shiftUp(i);

        // Extract the node
        var next = extractNext();
        // System.println("Queue remove idx: " + i + " " + next[1].toString());
        return next;
    }

    // Function to swap two elements in the heap
    function swap(i as Number, j as Number) as Void {
        var temp = q[i];
        temp[1].qIdx = j;
        q[j][1].qIdx = i;

        q[i] = q[j];
        q[j] = temp;
    }

}
