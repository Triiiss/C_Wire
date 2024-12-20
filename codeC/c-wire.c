#include "main.h"

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