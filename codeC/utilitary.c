#include "main.h"

int max(int a,int b, int c){
    /*Take 3 int in parameter and return the biggset one*/
    if(a>b){
        if(c>a){
            return c;
        }
        else{
            return a;
        }
    }
    else{
        if(c>b){
            return c;
        }
        else{
            return b;
        }
    }
    exit(50);   //there has been a problem
}

int min(int a,int b, int c){
    /*Take 3 int in parameter and return the smallest one*/
    if(a<b){
        if(c<a){
            return c;
        }
        else{
            return a;
        }
    }
    else{
        if(c<b){
            return c;
        }
        else{
            return b;
        }
    }
    exit(50);   //there has been a problem
}