

function quickSort(arr) {
    if (arr.len() <= 1) {
        return arr;
    }

    local pivot = arr[arr.len() / 2];
    local left = [];
    local right = [];
    local middle = [];

    foreach (item in arr) {
        if (item < pivot) {
            left.push(item);
        } else if (item > pivot) {
            right.push(item);
        } else {
            middle.push(item);
        }
    }

    return quickSort(left) + middle + quickSort(right);
}