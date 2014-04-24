#include "head.S"

main:
// Initialiser la pile
	movl $(stack + STACK_SIZE),%esp
	movl %esp,%ebp
	
	call hexa	
	hlt

	.size main,.-main


hexa: 
	call getchar
	
	shr $3,%al
	
	call affiche
	ret
	.size hexa,.-hexa

//fonction affiche tape clavier et arrete avec entree
affiche:
	movl $0xb8000,%ebx
glop:
	// recuperer un caractere sur le port serie
	//call getchar
	// On l affiche a l ecran
	movb %al,(%ebx)
	addl $2,%ebx    // sauter 2 octets:  caractere et couleur 
	//subb $13,%al
	jne glop

	.size affiche,.-affiche


getchar:
// On attend qu un caractere arrive sur le port serie
	movw $0x3f8+5,%dx
	movb $1,%cl
loop:
	inb  %dx,%al
	andb %cl,%al    // tester l arrivee
	je   loop

// Il est arrive, on le lit
	movw $0x3f8,%dx
	inb  %dx,%al
        ret

        .size getchar,.-getchar

// void putchar(char);

putchar:
// On emet un charactere sur le port serie
        movl 4(%esp),%eax
	movw $0x3F8,%dx
	outb %al,%dx
	ret

        .size putchar,.-putchar



// Juste un exemple de variable
char0:
	.byte 48


.comm stack,STACK_SIZE
