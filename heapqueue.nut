class HeapQueue {
    heap = null;
    constructor() {
        this.heap = [];
    }

    function test(){
        this.push(1, 1);
        this.push(2, 2);
        this.push(3, 3);
        this.push(4, 4);
        this.push(5, 5);

        AILog.Info(this.pop()[0])
        AILog.Info(this.pop()[0])
        AILog.Info(this.pop()[0])
        AILog.Info(this.pop()[0])
        AILog.Info(this.pop()[0])
        AILog.Info(this.pop()[0])
        AILog.Info("LENGTH " + this.len())

        AILog.Info("Test Integer Division " + 7 / 2);


    }
    function len(){
        return this.heap.len();
    }
    // Push an item into the heap
    function push(weight, item) {
        this.heap.push([weight, item]);
        this._heapifyUp(this.heap.len() - 1);
    }

    // Pop the smallest item from the heap
    function pop() {
        if (this.isEmpty()) {
            return null;
        }

        local root = this.heap[0];
        local lastItem = this.heap.pop();

        if (this.heap.len() > 0) {
            this.heap[0] = lastItem;
            this._heapifyDown(0);
        }

        return root;
    }

    // Peek at the smallest item without removing it
    function peek() {
        if (this.isEmpty()) {
            return null;
        }
        return this.heap[0];
    }

    // Check if the heap is empty
    function isEmpty() {
        return this.heap.len() == 0;
    }

    function _heapifyUp(index) {
        local p = (index - 1) / 2;

        if (index > 0 && this.heap[index][0] < this.heap[p][0]) {
            this._swap(index, p);
            this._heapifyUp(p);
        }
    }


    // Internal function to ensure the heap property is maintained during "down" movement
    function _heapifyDown(index) {
        local leftChild = 2 * index + 1;
        local rightChild = 2 * index + 2;
        local smallest = index;

        if (leftChild < this.heap.len() && this.heap[leftChild][0] < this.heap[smallest][0]) {
            smallest = leftChild;
        }

        if (rightChild < this.heap.len() && this.heap[rightChild][0] < this.heap[smallest][0]) {
            smallest = rightChild;
        }

        if (smallest != index) {
            this._swap(index, smallest);
            this._heapifyDown(smallest);
        }
    }

    // Swap two elements in the heap
    function _swap(i, j) {
        local temp = this.heap[i];
        this.heap[i] = this.heap[j];
        this.heap[j] = temp;
    }
}
