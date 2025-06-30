import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

class PQueueTest {

    // Unit test to check if 2 + 2 == 4
    (:test)
    static function myUnitTest(logger as Logger) as Boolean {
        var x = 2 + 3; logger.debug("x = " + x);
        return (x == 5); // returning true indicates pass, false indicates failure
    }

    // (:test)
    // static function arraySizeBehavior(logger as Logger) as Boolean { 
    //     var a = new Array<Thing>[4];
    //     Test.assert(a.size() == 0);
    //     return true;
    // }

    (:test)
    static function pqueueTest(logger as Logger) as Boolean {
        new PQueueTest().testHeapOperations();
        return true;
    }

    // build a (min) queue and assert as we consume the queue until empty
    // the priorities are in decending order
    (:test)
    static function queueTest1(logger as Logger) as Boolean {
        var q = new PQueueTest().buildTestQueue();
        var temp = null;

        while(!q.isEmpty()) {
            if (temp == null) {
                temp = q.extractNext();
                continue;
            }


            Test.assert((temp as PQAble)[0] <= q.getHighest()[0]);
            temp = q.extractNext();
            System.println(temp);
        }

        return true;
    }

    // function 
    function buildTestQueue() as PQueue {
        var q = new PQueue(10);
        var t = new Thing(0, 0, -1, -1);
        // Insert elements into the heap
        q.insert([45, t]);
        q.insert([20, t]);
        q.insert([14, t]);
        q.insert([12, t]);
        q.insert([31, t]);
        q.insert([7, t]);
        q.insert([11, t]);
        q.insert([13, t]);
        q.insert([7, t]);

        return q;
    }

    function testHeapOperations() as Void {
        var heap = buildTestQueue();

        var i = 0;

        // Priority queue before extracting highest
        System.println("Priority Queue : ");
        while (i < heap.getSize()) {
            System.print(heap.q[i].toString() + " ");
            i += 1;
        }

        System.println("");

        // Node with maximum priority 
        System.println("Node with maximum priority : " + heap.extractNext().toString());

        // Priority queue after extracting highest
        System.println("Priority queue after extracting highest : ");
        var j = 0;
        while (j < heap.getSize()) {
            System.print(heap.q[j].toString() + " ");
            j += 1;
        }

        System.println("");

        // Change the priority of the element at index 2 to 49
        heap.changePriority(2, 49);
        System.println("Priority queue after priority change : ");
        var k = 0;
        while (k < heap.getSize()) {
            System.print(heap.q[k].toString() + " ");
            k += 1;
        }

        System.println("");

        // Remove the element at index 3
        heap.remove(3);
        System.println("Priority queue after removing the element : ");
        var l = 0;
        while (l <= heap.getSize()) {
            System.print(heap.q[l].toString() + " ");
            l += 1;
        }

        System.println("");
    }

}
