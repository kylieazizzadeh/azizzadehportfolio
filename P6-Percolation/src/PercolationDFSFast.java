public class PercolationDFSFast extends PercolationDFS{
    public PercolationDFSFast(int n){
        super(n);
    }

    @Override
    protected void updateOnOpen(int row, int col){
        int run = 0;
        if(row==0){
            run = 1;
        }
        if(row>0 && isFull(row-1, col)){
            run = 1;
        }
        if(row<myGrid.length-1 && isFull(row+1, col)){
            run = 1;
        }
        if(col>0 && isFull(row, col-1)){
            run = 1;
        }
        if(col<myGrid.length-1 && isFull(row, col+1)){
            run = 1;
        }
        if(run==1){
            dfs(row, col);
        }
    }
}
