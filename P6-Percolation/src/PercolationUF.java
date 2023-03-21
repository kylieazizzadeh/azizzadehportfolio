public class PercolationUF implements IPercolate{
    private IUnionFind myFinder;
    private boolean[][] myGrid;
    private final int VTOP;
    private final int VBOTTOM;
    private int myOpenCount;

    public PercolationUF(IUnionFind finder, int size){
        myGrid = new boolean[size][size];
        myOpenCount = 0;
        VTOP = size * size;
        VBOTTOM = size*size+1;
        myFinder = finder;
        finder.initialize(size*size +2);
    }

    @Override
    public boolean isOpen(int row, int col){
        if (row<0 || row>myGrid.length-1 || col<0 || col>myGrid.length-1) {
            throw new IndexOutOfBoundsException(String.format("(%d,%d) not in bounds", row,col));
        }
        return myGrid[row][col];
    }

    @Override
    public boolean isFull(int row, int col){
        if (row<0 || row>myGrid.length-1 || col<0 || col>myGrid.length-1) {
            throw new IndexOutOfBoundsException(String.format("(%d,%d) not in bounds", row,col));
        }
        int val = row*myGrid.length + col;
        return myFinder.connected(VTOP, val);
    }

    @Override
    public boolean percolates(){
        return myFinder.connected(VTOP, VBOTTOM);
    }

    @Override
    public int numberOfOpenSites(){
        return myOpenCount;
    }

    @Override
    public void open(int row, int col){
        if (row<0 || row>myGrid.length-1 || col<0 || col>myGrid.length-1) {
            throw new IndexOutOfBoundsException(String.format("(%d,%d) not in bounds", row,col));
        }
        if(!isOpen(row, col)) {
            int val = row*myGrid.length + col;
            myGrid[row][col] = true;
            myOpenCount++;
            if(row==0){
                myFinder.union(VTOP, val);
            }
            if(row==myGrid.length-1){
                myFinder.union(val, VBOTTOM);
            }
            if(row>0 && isOpen(row-1, col)){
                int temp = (row-1)*myGrid.length + col;
                myFinder.union(temp, val);
            }
            if(row<myGrid.length-1 && isOpen(row+1, col)){
                int temp = (row+1)*myGrid.length + col;
                myFinder.union(val, temp);
            }
            if(col>0 && isOpen(row, col-1)){
                int temp = (row)*myGrid.length + (col-1);
                myFinder.union(temp, val);
            }
            if(col<myGrid.length-1 && isOpen(row, col+1)){
                int temp = (row)*myGrid.length + (col+1);
                myFinder.union(val, temp);
            }
        }
    }
}