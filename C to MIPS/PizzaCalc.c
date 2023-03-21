#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <string.h> 

struct Pizza{
    char name[64];
    float ppd;
    struct Pizza* next;
};

void sortList(struct Pizza* insert);

float calculatePPD(float c, float d);

struct Pizza* head = NULL;
struct Pizza* tail = NULL;

float calculatePPD(float c, float d){
    if(c == 0 || d == 0){
        return 0;
    }

    #define PI 3.14159265358979323846

    float sqin = (1/4)*(d*d)*PI;

    return (sqin / c);
}

int main(int argc, char *argv[]){
    #define PI 3.14159265358979323846
    int checkNum;
    
    //error messages
    //if(argc != 2){
        //printf("Error: syntax for PizzaCalc is PizzaCalc <String>");
        //return EXIT_FAILURE;
    //}

    //empty file
    FILE *file;
    file = fopen(argv[1], "r");
    if(fscanf(file, "%d", &checkNum) == EOF){
        printf("PIZZA FILE IS EMPTY");
        return 0;
    }

    //set up linked list
    int num_pizzas = 0;

    //collect and dynamically add values until DONE
        //add to linked list with insertion sort
    float new_diameter; 
    float new_cost; 
    float new_ppd;
    while(1){
        char new_name[64]; 
        fscanf(file, "%s", new_name);
        
        //leave loop at end of file
        if(strcmp(new_name, "DONE") == 0){
            break;
        }

        fscanf(file, "%f", &new_diameter);
        fscanf(file, "%f", &new_cost);

        #define PI 3.14159265358979323846

        if(new_cost == 0 || new_diameter == 0){
            new_ppd = 0;
        } else {
            float sqin = .25 * new_diameter * new_diameter * PI;
            new_ppd = (sqin/new_cost);
        }

        //make a new struct
        struct Pizza* new_pizza = (struct Pizza*)(malloc(sizeof(struct Pizza)));
        strcpy(new_pizza->name,new_name);
        new_pizza->ppd = new_ppd;
        new_pizza->next = NULL;

        //insert sort into list
        //check if this is the head, add to list accordingly 
        sortList(new_pizza);

        num_pizzas++;
    }

    fclose(file);

    //print sorted list
    struct Pizza* temp = head;
    for(int i = 0; i < num_pizzas; i++){
        printf("%s %f\n", temp->name, temp->ppd);
        temp = temp->next;
    }

    //FREE MEMORYYYYYYY
    while(head!=NULL){
        struct Pizza* temp = head->next;
        free(head);
        head = temp;
    }

    return EXIT_SUCCESS;
}


void sortList(struct Pizza* insert){
    //check if empty
    if (head == NULL) {
        head = insert;
        tail = insert;
        return;
    }
    
    float insert_ppd = insert->ppd;

    //check if better than the head
    float head_ppd = head->ppd;
    if(insert_ppd > head_ppd || (insert_ppd==head_ppd && strcmp(insert->name, head->name) < 0)){
        struct Pizza* temp = head;
        //free(head);
        head = insert;
        insert->next = temp;
        return;
    }

    //check if worse than tail
    float tail_ppd = tail->ppd;
    if(insert_ppd < tail_ppd || (insert_ppd==tail_ppd && strcmp(insert->name, tail->name) > 0)){
        tail->next = insert;
        tail = insert;
        return;
    }

    //inserting in middle
    struct Pizza* one = head;
    struct Pizza* two = head->next;
    while(1){
        float ppd1 = one->ppd;
        float ppd2 = two->ppd;
        if(insert_ppd > ppd2 || (insert_ppd==ppd2 && strcmp(insert->name, two->name) < 0)){
            struct Pizza* temp = two;
            //free(two);
            one->next = insert;
            insert->next = temp;
            return;
        }
        one = two;
        two = two->next;
    }
}