#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// faire file statique min et max pour poste lv
typedef struct avl{
    struct avl* sad;
    struct avl* sag;
    int eq;
    int id;    //Id of the station
    int capacity;   
    int load;
    //char type;  //P for power plant, B for HV-B station, A for HV-A stattion, L for LV post, a for HV-A consumers,b for HV-B consumers, l for LV consumers
 
}Avl;

typedef struct ch_list{
    Avl* tree;

    struct ch_list* next;
}ch_list;

char* add_str(char** a, char c){
    /*add the char b to a and return a, if a doesn't exist/is equall to NULL create and return a*/
    char* temp=NULL;
    int size;
    size=strlen(*a);
    temp=malloc(sizeof(size+2));
    if(temp==NULL){
        exit(2);    //malloc didn't work
    }
    for(int i=0;i<size+1;i++){
        temp[i]=*(*a+i);
    }
    *(temp+size)=c;
    *(temp+size+1)='\0';
    *a=temp;
    return temp;
}

ch_list* add_list(ch_list* list,Avl*tree){
    /*Add an Avl tree at the end of the ch_list list*/
    ch_list* rep=NULL;
    if(list==NULL){
        rep=malloc(sizeof(ch_list));
        if(rep==NULL){
            exit(2);    //malloc didn't work
        }
        rep->tree=tree;
        rep->next=NULL;
        return rep;
    }
    list->next=add_list(list->next,tree);
    return list;
}

int power(int num,int index){
    /* return a number num to the power of index */
    if(index==0){
        return 1;
    }
    else if(index>0){
        return num*power(num,index-1);
    }
    else{
        return (power(num,index+1))/num;
    }
}

int stringtoint(char* word){
    /*take a char* and return it's value in int*/
    int size=0,rep=0;
    size=strlen(word);
    for(int i=size;i>0;i--){
        if(word[size-i]<58&&word[size-i]>47){   //check if it is a number in ascii
                    rep+=(word[size-i]-48)*power(10,i-1);
        }
        else{
            printf("\n non \n");    //mettre autre chose invalid argument exit(21)
        }
    }
    return rep;
}

int strequal(char* a,char* b){
    /*take 2 char* and return if they are the same char string, all char* musn't be NULL or it exit*/
    int size=0;
    size=strlen(a);
    if(a==NULL||b==NULL){
        exit(22);
    }
    if(strlen(b)!=size){
        return 0;
    }
    for(int i=i; i<size;i++){
        if(a[i]!=b[i]){
            return 0;
        }
    }
    return 1;
}

int max(int a,int b, int c){
    /*take 3 int in parameter and return the biggset one*/
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
    exit(21);   //there has been a problem
}

int min(int a,int b, int c){
    /*take 3 int in parameter and return the smallest one*/
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
    exit(21);   //there has been a problem
}

int id_exist(ch_list* list ,int nb){
    /*take a list of Avl and return 1 if an Avl with an id of nb exist, else return 0*/
    if(list==NULL){
        return 0;
    }
    if(list->tree->id==nb){
        return 1;
    }
    else{
        return id_exist(list->next,nb);
    }
}

Avl* add_pwr(ch_list* list,int id){
    ch_list* temp;
    if(id_exist(list,id)){
        exit(21);   //invalid arguments
    }
    if(list==NULL){
        temp=malloc(sizeof(ch_list));
        if(temp==NULL){
            exit(2);    //malloc didn't work
        }
    }
}

Avl* create_tree(int id,int consuption,int capacity){
    /*create a tree and return it's address*/
    Avl* temp=NULL;
    temp=malloc(sizeof(Avl));
    if(temp==NULL){
        exit(2); //malloc didn't work
    }
    temp->id=id;
    temp->load=consuption;
    temp->capacity=capacity;
    temp->sad=NULL;
    temp->sag=NULL;
    return temp;
}

Avl* insert_Avl(Avl* tree, int id, int consuption, int capacity,int* eq){
    if(tree==NULL){
        *eq=1;
        return create_tree(id,consuption,capacity);
    }
    else if(tree->id=id){
        tree->capacity+=capacity;
        tree->load=consuption;
    }
    else if(id<tree->id){
        tree->sag=insert_Avl(tree->sag,id,consuption,capacity,eq);
        *eq=-*eq;
    }
    else if(id>tree->id){
        tree->sad=insert_Avl(tree->sad,id,consuption,capacity,eq);
    }
    else{
        *eq=0;
        return tree;
    }
    if(eq!=0){
        tree->eq=tree->eq+*eq;
        if(tree->eq==0){
            *eq=0;
        }
        else{
            *eq=1;
        }
    }   

}

Avl* leftrotation(Avl* tree){
    Avl* pivot;
    int eq_tree=0,eq_p=0;
    pivot=tree->sad;
    tree->sad=pivot->sag;
    pivot->sag=tree;    //faire attention
    eq_tree=tree->eq;
    eq_p=pivot->eq;
    tree->eq=eq_tree-max(eq_p,0,0)-1;
    pivot->eq=min(eq_tree-2,eq_tree+eq_p-2,eq_p-1);
    tree=pivot;
    return tree;
}

Avl* rightrotation(Avl* tree){
    Avl* pivot;
    int eq_tree=0,eq_p=0;
    pivot=tree->sag;
    tree->sag=pivot->sad;
    pivot->sad=tree;    //faire attention
    eq_tree=tree->eq;
    eq_p=pivot->eq;
    tree->eq=eq_tree-min(eq_p,0,0)+1;
    pivot->eq=max(eq_tree+2,eq_tree+eq_p+2,eq_p+1);
    tree=pivot;
    return tree;
}

Avl* double_leftrotaion(Avl* tree){
    tree->sad=rightrotation(tree->sad);
    return leftrotation(tree);
}

Avl* double_rightrotaion(Avl* tree){
    tree->sag=leftrotation(tree->sag);
    return rightrotation(tree);
}

Avl* balance(Avl* tree){
    /*balance an Avl tree*/
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

Avl* add_line(Avl* tree,FILE* fichier ){
    int count=0;
    char c;
    char* id;
    char* capacity;
    char* load;
    int intcapacity=-1;
    int intload=-1;
    int intid=-1;
    c=fgetc(fichier);
    while(c != '\n'||c != EOF){
        if(c==';'){
            count++;
        }
        else{
            switch(count){
                case 0:
                    add_str(&id,c);
                    break;
                case 1: 
                    add_str(&capacity,c);
                    break;
                case 2:
                    add_str(&load,c);
                    break;
                default:
                    exit(51);   //probleme du fichier 
                }


            }
    c=fgetc(fichier);    
    }
    if(*load=='-'){
        intload=0;
    }else{
        intload=stringtoint(load);
    }
    if(*capacity='-'){
        intcapacity=0;
    }
    else{
    intcapacity=stringtoint(capacity);
    }
    if(*id='-'){
        exit(52);   //file problem
    }
    else{
        intid=stringtoint(id);
    }
    tree=insert_Avl(tree,intid,intload,intcapacity,&(tree->eq));
    tree=balance(tree);
    return tree;
}

void Avl_free(Avl* tree){
    /*A recursive function that free all the Avl in parameter*/
    if(tree!=NULL){
        Avl_free(tree->sag);
        Avl_free(tree->sad);
        free(tree);
    }
}

int main(){
    //printf("%d\n",('2'-48)*10);
    //printf("%d\n",stringtoint("10023"));
    FILE* fichier;
    fichier=fopen("c-wire_v00.dat","r");
}