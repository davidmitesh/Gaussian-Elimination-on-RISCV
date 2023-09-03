//
//  main.c
//  gausian_elimination_with_pivoting
//
//  Created by mitesh pandey on 19/08/23.
//

#include <stdio.h>
#include <math.h>
#include <string.h>


void printMatrix(int m, int n, float matrix[m][n])
{
    int i, j;
    for (i = 0; i < m; i++)
    {
        for (j = 0; j < n; j++)
        {
                unsigned int ui;
                memcpy(&ui, &matrix[i][j], sizeof (ui));
            //
                printf("%x\t", ui);
//            printf("%f\t", matrix[i][j]);
        }
        printf("\n");
    }
}
int gaussEliminationLS(int m, int n, float a[m][n], float x[n - 1])
{
    int i, j, k;
    for (i = 0; i < m - 1; i++)
    {
        // Partial Pivoting
        for (k = i + 1; k < m; k++)
        {
            // If diagonal element(absolute vallue) is smaller than any of the terms below it
            if (fabs(a[i][i]) < fabs(a[k][i]))
            {
                // Swap the rows
                for (j = 0; j < n; j++)
                {
                   float temp;
                    temp = a[i][j];
                    a[i][j] = a[k][j];
                    a[k][j] = temp;
                }
            }
        }
        printMatrix(m, n, a);
        // Begin Gauss Elimination
        for (k = i + 1; k < m; k++)
        {
            if (a[i][i] == 0){
                break;
            }
            float term = a[k][i] / a[i][i];
            for (j = 0; j < n; j++)
            {
                a[k][j] = a[k][j] - term * a[i][j];
            }
        }
    }
    // Begin Back-substitution
    for (i = m - 1; i >= 0; i--)
    {
        x[i] = a[i][n - 1];
        for (j = i + 1; j < n - 1; j++)
        {
            x[i] = x[i] - a[i][j] * x[j];
        }
        if (x[i] == 0){
            if (a[i][i] == 0){
                printf("Infinite solution exists\n");
                return -1;
            }
        }
        if (x[i] != 0){
            if (a[i][i] == 0){
                printf("No solution exists\n");
                return -1;
            }
        }
        x[i] = x[i] / a[i][i];
    }
    return 0;
}


int main()
{
    int  i;
    int m = 5 , n= 6;
    float U[5][6] = {{-6,4,6,-8,-3,-50},{-4,3,4,-4,-9,11},{-3,-1,-1,-6,2,-29},{-2,-4,6,-5,7,-53},{-7,-9,-10,5,9,12}};
    float x[5];
    gaussEliminationLS(m, n, U, x);
    printf("\nThe Upper Triangular matrix after Gauss Eliminiation is:\n\n");
    printMatrix(m, n, U);
    printf("\nThe solution of linear equations is:\n\n");
    for (i = 0; i < n - 1; i++)
    {
        printf("x[%d]=\t%f\n", i + 1, x[i]);
        unsigned int ui;
        memcpy(&ui, &x[i], sizeof (ui));
        printf("%x\n", ui);
    }
}
