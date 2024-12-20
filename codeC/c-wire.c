#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct avl{
    long unsigned int capacity;   
    long unsigned int load;
    struct avl* sad;
    struct avl* sag;
    int eq;
    int id;    //Id of the station
}Avl;


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

Avl* create_tree(int id,long unsigned int load,long unsigned int capacity){
    /*Create a tree and return it's address*/
    Avl* temp=NULL;

    temp = malloc(sizeof(Avl));

    if(temp==NULL){
        exit(51); //malloc didn't work
    }

    temp->id=id;
    temp->load=load;
    temp->capacity=capacity;
    temp->eq=0;
    temp->sad=NULL;
    temp->sag=NULL;

    return temp;
}

Avl* leftrotation(Avl* tree){
    /*Make an avl left rotation and return the avl tree, if tree is NULL return tree*/
    Avl* pivot;
    int eq_tree=0,eq_p=0;
    
    if (tree != NULL){
        pivot=tree->sad;
        tree->sad=pivot->sag;
        pivot->sag=tree;    //faire attention
        eq_tree=tree->eq;
        eq_p=pivot->eq;

        tree->eq=eq_tree-max(eq_p,0,0)-1;
        pivot->eq=min(eq_tree-2,eq_tree+eq_p-2,eq_p-1);
        tree=pivot;
    }

    return tree;
}

Avl* rightrotation(Avl* tree){
    /*Make an avl right rotation and return the avl tree, if tree is NULL return tree*/
    Avl* pivot;
    int eq_tree=0,eq_p=0;

    if (tree != NULL){
        pivot=tree->sag;
        tree->sag=pivot->sad;
        pivot->sad=tree;
        eq_tree=tree->eq;
        eq_p=pivot->eq;

        tree->eq=eq_tree-min(eq_p,0,0)+1;
        pivot->eq=max(eq_tree+2,eq_tree+eq_p+2,eq_p+1);
        tree=pivot;
    }

    return tree;
}

Avl* double_leftrotaion(Avl* tree){
    /*Make an avl double left rotation and return the avl tree, if tree is NULL return tree*/
    if (tree != NULL){
        tree->sad=rightrotation(tree->sad);
    }
    return leftrotation(tree);
}

Avl* double_rightrotaion(Avl* tree){
    /*Make an avl double right rotation and return the avl tree, if tree is NULL return tree*/
    if (tree != NULL){
        tree->sag=leftrotation(tree->sag);
    }
    return rightrotation(tree);
}

Avl* balance(Avl* tree){
    /*Balance an Avl tree*/
    if (tree == NULL){
        return tree;
    }

    if(tree->eq>=2){
        if(tree->sad->eq>=0){
            return leftrotation(tree);
        }
        else{
            return double_leftrotaion(tree);
        }
    }
    else if(tree->eq<=-2){
        if(tree->sag->eq<=0){
            return rightrotation(tree);
        }
        else{
            return double_rightrotaion(tree);
        }
    }

    return tree;
}
Avl* insert_Avl(Avl* tree, int id, long unsigned int load, long unsigned int capacity,int* eq){
    /*A function that add a node with id ,load and cpacity to the avl tree*/
    if(tree==NULL){
        *eq=1;
        return create_tree(id,load,capacity);
    }
    else if(tree->id==id){
        tree->capacity+=capacity;
        tree->load+=load;

        return tree;
    }
    else if(id<tree->id){
        tree->sag=insert_Avl(tree->sag,id,load,capacity,eq);
        *eq=-*eq;
    }
    else if(id>tree->id){
        tree->sad=insert_Avl(tree->sad,id,load,capacity,eq);
    }
    else{
        *eq=0;
        return tree;
    }
    if(*eq!=0){ //this section of the code is changing the equiliber of the tree
       tree->eq=tree->eq+*eq;
        tree=balance(tree);
        if(tree->eq==0){
            *eq=0;
        }
        else{
            *eq=1;
        }
    }   
    return tree;
}

Avl* add_line(Avl* tree, FILE* fp){
    /*Take a line in the file fp and add it inside the avl tree*/
    int id=-1;
    long unsigned int load=-1,capacity=-1;  //ligne changé
    int h=0;

    if (fp == NULL){
        exit(52);
    }

    fscanf(fp,"%d;%lu;%lu",&id,&capacity,&load);    //take the variable in the file 

    if(id<0||capacity<0||load<0){
        exit(53);   //problem with fscanf
    }

    if(tree==NULL){ 
        return create_tree(id,load,capacity);
    }
    tree=insert_Avl(tree,id,load,capacity,&(h)); 
    return tree;
}

void Avl_free(Avl* tree){
    /*A recursive function that free all the Avl in parameter*/
    if(tree!=NULL){
        tree->eq = 0;
        tree->id = 0;
        tree->capacity = 0;
        tree->load = 0;

        Avl_free(tree->sag);
        Avl_free(tree->sad);

        tree->sad = NULL;
        tree->sag = NULL;

        free(tree);
    }
}

void Avlwriting(FILE* fp,Avl* tree){
    /*Write the avl tree inside the file fp*/
    if(fp==NULL){
        exit(52);   //invalid argument
    }
    if(tree!=NULL){
        fprintf(fp,"%d:%lu:%lu\n",tree->id,tree->capacity,tree->load);  //add the line in the file
        Avlwriting(fp,tree->sag);
        Avlwriting(fp,tree->sad);
    }
}

void show(Avl* tree){
    /*Show the Avl tree put into parameter in your command prompt, isn't used in the programm*/
    if(tree!=NULL){
        printf("id :%d\n capcity : %lu , load : %lu \n eq : %d \n",tree->id,tree->capacity,tree->load,tree->eq);
        show(tree->sag);
        show(tree->sad);
    }
}


int programm(){
    /*Main programm, take the file in tmp and create an avl tree and write the results of ths avl tree inside the file output.csv*/
    char c;
    FILE* fp=NULL;
    Avl* tree=NULL;

    fp=fopen("tmp/c-wire_data.csv","r");
        if (fp == NULL){
            return 52;
        }
        tree=add_line(tree,fp);

        while(c!=EOF){ 
            c=fgetc(fp);
            if(c!='\n'){    //check if we are at the end of the file, c value would be EOF
                break;
            }  
            tree=add_line(tree,fp); 
        }
    fclose(fp);
    
    
    fp=fopen("tmp/output.csv","w+");
        if (fp == NULL){
            return 52;
        }
        Avlwriting(fp,tree);
    fclose(fp);
    Avl_free(tree);
    return 0;
}

int main(){
    int error = 0;
    error = programm();

    if (error != 0){
        printf("Error");
        return error;
    }

    return 0;
}