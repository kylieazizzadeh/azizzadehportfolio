import java.util.*;

public class PercolationBFS extends PercolationDFSFast{
    public PercolationBFS(int n){
        super(n);
    }

    @Override
    protected void dfs(int row, int col) {
        if(!inBounds(row, col)){
            return;
        }
        if (isFull(row, col) || !isOpen(row, col))
            return;
        Queue<int[]> q = new LinkedList<>();
        myGrid[row][col] = FULL;
        q.add(new int[]{row, col});
        while(q.size()!=0){
            int[] temp = q.remove();
            int r = temp[0];
            int c = temp[1];
            if(inBounds(r+1, c) && isOpen(r+1, c) && !isFull(r+1, c)){
                myGrid[r+1][c] = FULL;
                q.add(new int[]{r+1, c});
            }
            if(inBounds(r-1, c) && isOpen(r-1, c) && !isFull(r-1, c)){
                myGrid[r-1][c] = FULL;
                q.add(new int[]{r-1, c});
            }
            if(inBounds(r, c+1) && isOpen(r, c+1) && !isFull(r, c+1)){
                myGrid[r][c+1] = FULL;
                q.add(new int[]{r, c+1});
            }
            if(inBounds(r, c-1) && isOpen(r, c-1) && !isFull(r, c-1)){
                myGrid[r][c-1] = FULL;
                q.add(new int[]{r, c-1});
            }
        }
    }
}
