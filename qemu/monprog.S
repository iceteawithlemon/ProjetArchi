#include "head.S"

main:
// Initialiser la pile
	movl $(stack + STACK_SIZE),%esp
	movl %esp,%ebp

// On affiche deux caracteres
	movl $0xb8000,%ebx
	movb charA,%al
	movb %al,(%ebx)
        addl $2,%ebx    // sauter 2 octets: un pour le caractere, l autre pour la couleur
        addb $1,%al     // passer a un B
	movb %al,(%ebx) // et l afficher

        addb $1,%al     // passer a un C
        pushl %eax
        call putchar	// et l envoyer sur le port serie
        popl %eax

	// recuperer un caractere sur le port serie
	call getchar

// On l affiche a l ecran
	movl $0xb8004,%ebx
	movb %al,(%ebx)

// On s arrete
	hlt

	.size main,.-main

// char getchar(void);

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
charA:
	.byte 65

.comm stack,STACK_SIZE
