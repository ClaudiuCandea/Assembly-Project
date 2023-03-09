.386
.model flat, stdcall
includelib msvcrt.lib

extern exit:proc
extern printf:proc
extern scanf:proc
extern fopen:proc
extern fclose:proc
extern fscanf:proc
extern fprintf:proc
extern  strcmp:proc
extern strcpy:proc
extern strlen:proc
extern tolower:proc 
extern sscanf:proc
extern toupper:proc

public start

.data
cuvant struct
	sir db 30 dup(0)
	key dd 0
cuvant ends
cuvinte cuvant 30 dup({"000000000000000000000000000000",0})
mesaj db "Introduceti calea absoluta spre fisier:",0
mesaj2 db "Introduceti calea absoluta spre fisierul ce trebuie decomprimat:",0
mesaj3 db "Introduceti calea absoluta spre dictionar:",0
scanmeniu db "%d",0
formatscan db "%s",0
formatcompresie db "%d ",0
formatcompresie2 db "%d%c ",0
formatdictionar db "%d %s",10, 0
formatscandict db "%d%s",0
formattext db "%s%c ",0
formattext2 db "%s ",0
formatafisare db "%d%s",10,0
cale db 100 dup(0)
cale2 db 100 dup(0)
cod db 2 dup(0)
mode1 db "w",0
mode2 db "r",0
dict db "dictionar.txt",0
comp db "compresed.txt",0
text db "text.txt",0
newline db "\n",0
s db 100 dup(0)
nr dd 0
meniuformat db "1 Compresie",13, 10, "2 Decompresie", 13, 10, "3 exit",10,0
nrmeniu dd 0
contor dd 0

.code
lungime macro string
	push offset string
	call strlen
	add esp, 4
endm

sign macro semn, variabila, string2 ;macro care afla daca la finalul unui sir se afla un anumit semn de punctuatie, iar daca exista salveaza semnul intr-o variabila
local farasemn, dupasemn
	push ebx
	mov ebx, 0
	cmp variabila,ebx
	jne dupasemn; daca variabila nu e 0 se trece la final 
	cmp string2[esi], semn
	jne farasemn; daca la finalul stringului nu se afla niciun semn se sare la farasemn
	mov string2[esi], 0; pe ultima pozite din sir semnul se  inlocuieste cu 0
	mov ebx, semn
	mov variabila, ebx ;se salveaza in variabila semnul 
	jmp dupasemn; se sare la finalul maro-ului dupa executia instructiunilor precedente
farasemn:
	mov ebx, 0
	mov variabila, ebx; in variabila se salveaz 0, deci nu exita semn la finalul sirului
dupasemn:
	pop ebx
endm
	

compresie proc
	push ebp
	mov ebp, esp
	sub esp, 24
	
	push offset mode2 
	push [ebp+8]
	call fopen
	add esp, 8
	mov [ebp-4], eax ; am deschis fisierul primit de la utilizator, ebp-4=pointer fisier utilizator
	
	push offset mode1 
	push offset dict
	call fopen
	add esp, 8
	mov [ebp-8], eax ;am deschis fisierul dictionar, ebp-8=pointer dictionar
	
	push offset mode1
	push offset comp
	call fopen
	add esp, 8
	mov [ebp-12],eax ; am deschis fisierul in care scriem textul comprimat, ebp-12=pointer fisier comprimat
	
	mov ebx, 0
	mov contor, ebx; initalizare contor cu 0
	
	jmp whileloop ;sarim la portiunea de cod unde am definit un while
	executie:
			mov ebx, 1
			mov  [ebp-16], ebx ;ebp-16=variabila care ia val 1 daca e prima data intalnim cuvantul din sirul s, altfel ia val 0
			
			lungime s
			mov [ebp-20],eax ;ebp-20=nr de caractere din sirul s
			
			xor edi, edi
			mov esi, 0
			jmp for11; sarim la verificarea conditiei pt for1 
			
			for1:
				xor ebx, ebx
				mov bl, s[esi]
				push ebx
				call tolower ;folosind functia tolower, daca avem litere mari aceste se vor transforma in litere mici
				add esp, 4
				mov s[esi], al
				inc esi 
				inc edi
				for11:
				cmp edi, [ebp-20]; comparam edi cu nr de caractere din s(coditie de adevar pt for1)
				jl for1 ; daca edi<[ebp-20] atunci se trece la executarea instructiunilor din for
			
			mov esi, [ebp-20]; mutam in esi nr de caractere din sirul s
			sub esi, 1
			
			mov ebx, 0
			mov [ebp-24], ebx; ;[ebp-24]= variabila locala in care stocam semnul de punctuatie de la finalul sirului s, daca acesta exista
			sign '.', [ebp-24], s 
			sign '?', [ebp-24], s
			sign ',', [ebp-24], s
			sign '!', [ebp-24], s
			
			xor esi, esi
			xor edi, edi
			jmp for22; se sare la verificarea conditei pt for2 
			for2:
				lea ebx, cuvinte[esi].sir;
				push ebx
				push offset s
				call strcmp 	; comparam s cu cuvintele scrise in sirul cuvinte  
				add esp, 8
				cmp eax, 0
				jne incrementEDI; daca eax!=0 atunci cuvanutul din sirul cuvinte nu coincide cu s si se sare la incrementarea contorului
				
				mov ebx, 0
				cmp [ebp-24], ebx; se compara variabila in care avem semnul de punctuatie cu 0
				je IFelse ; daca variabila e 0 atunci se sare la IFelse
					push [ebp-24]; variabila cu semn
					push edi; este egal cu cheia elementului din sirul cuvinte care coincide cu string-ul din s
					push offset formatcompresie2
					push [ebp-12]; pointer spre fisierul comprimat 
					call fprintf; scriem in fiserul cu text comprimat cuvantul din s cu semn de punctuatie dupa cheia sa
					add esp, 16
					mov ebx , 0
					mov [ebp-16], ebx; punem 0 in variabila care ne indica daca procesam stringul din s pentru prima data 
					jmp incrementEDI; sarim la incrementarea contorului pt for2
				IFelse:
					push edi; este egal cu cheia elementului din sirul cuvinte care coincide cu string-ul din s
					push offset formatcompresie
					push [ebp-12]; pointer spre fisierul comprimat
					call fprintf; scriem in fiserul cu text comprimat cuvantul din s
					add esp, 12
					mov ebx, 0
					mov [ebp-16], ebx; punem 0 in variabila care ne indica daca procesam stringul din s pentru prima data 
				incrementEDI:
				inc edi 
				add esi, 34 ;incrementam cu dimeniunea structurii cuvant contorul care ne ajuta sa parcurgem sirul cuvinte
				
				for22:
				cmp edi, contor ;comparam edi cu contror( edi<contor conditie pt for2)
				jl for2; sarim la executarea instructiunilor din for2
				
				mov ebx,1
				cmp [ebp-16], ebx
				jne whileloop; daca ebp-16 nu e 1 atunci se trece la whileloop, altfel se scrie in sirul cuvinte un cuvant nou
				
				; punem in esi valoarea care ne da elementul din sirul cuvinte corespunzator valorii curente a contorului
				xor esi, esi
				xor eax, eax
				mov ebx, 34
				mov eax, contor 
				mul ebx
				mov esi, eax
				
				lea ebx, cuvinte[esi].sir
				push offset s
				push ebx
				call strcpy; copiem in cuvinte[esi].sir continutul din s
				add esp, 8
				
				xor eax, eax
				mov eax, contor 
				mov cuvinte[esi].key, eax; copiem in cuvinte[esi].key valoarea curenta a contorului
				
				
				mov ebx, 0
				cmp [ebp-24], ebx
				je else2; daca in ebp-24 nu  se afla un semn de punctuatie se sare la else2, atfle se continua codul
					push [ebp-24]
					push contor
					push offset formatcompresie2
					push [ebp-12]
					call fprintf; scriem in fiserul cu text comprimat cuvantul din s cu semn de punctuatie dupa cheia sa
					add esp, 16
					jmp afterelse
				else2:
					push contor
					push offset formatcompresie
					push [ebp-12]
					call fprintf; scriem in fiserul cu text comprimat cuvantul din s
					add esp, 12
				afterelse:
				mov ebx, 1
				add contor, ebx; incrementa contrul cu 1 caci am gasit un cuvant nou
				
	whileloop:     ;definim while(fscanf(fisier cu text,"%s",s)>0) coditie ca partea de cod de la eticheta executie sa se poata executa
			push offset s
			push offset formatscan
			push [ebp-4]
			call fscanf
			add esp, 12
			cmp eax, 0
			jg  executie
	
	xor esi, esi; folosim esi ca sa parcurgem sirul de structuri cuvinte
	xor edi, edi; folosim edi ca contor pt for
	
	jmp fordict1; sarim sa verificam conditia de for 
	
	fordict:       
		lea ebx, cuvinte[esi].sir
		push ebx
		push cuvinte[esi].key
		push offset formatdictionar
		push [ebp-8]
		call fprintf; scriem in dictionar key si sirul de caractere corespunzator fiecarui element din sirul cuvinte
		add esp, 16
		
		add esi, 34 ; incrementam esi cu dimensiunea unei structuri cuvant
		inc edi; incrementam contorul for-ului cu 1
	fordict1:
		cmp edi, contor
		jl fordict ; daca inca edi este mai mic decat contorul se trece la executia for-ului
		
	;inchidem cele 3 fisiere 
	push [ebp-4]
	call fclose
	add esp, 4
	push [ebp-8]
	call fclose
	add esp, 4
	push [ebp-12]
	call fclose
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret 4
compresie endp

decompresie proc
	push ebp
	mov ebp, esp
	sub esp, 16
	
	push offset mode2 
	push [ebp+8]
	call fopen
	add esp, 8
	mov [ebp-4], eax ; am deschis fisierul cu textul comprimat, ebp-4=pointer fisier comprimat
	
	push offset mode2 
	push [ebp+12]
	call fopen
	add esp, 8
	mov [ebp-8], eax ;am deschis fisierul dictionar, ebp-8=pointer dictionar
	
	push offset mode1
	push offset text
	call fopen
	add esp, 8
	mov [ebp-12],eax ; am deschis fisierul in care scriem textul decomprimat, ebp-12=pointer fisier decomprimat
	
	mov ebx, 0
	mov contor, 0; initiazlizare contor cu 0
	xor esi, esi
	jmp whileloop2
		executie2:
			lea ebx, cuvinte[esi].sir
			push ebx
			push cuvinte[esi].key
			push offset formatafisare
			call printf; scriem fiecare cuvant scanat si codul sau corespunzator
			add esp, 12
			mov ebx, 1
			add contor, ebx ;incrementeam contorul care tine evidenta cuvintelor scanate in sirul cuvinte
			add esi, 34; ;incrementam esi cu dimenisunea structurii cuvant
	whileloop2:
		lea ebx, cuvinte[esi].sir
		lea edx, cuvinte[esi].key
		push ebx
		push edx
		push offset formatscandict
		push [ebp-8]
		call fscanf; scanam din dictionar in sirul cuvinte fiecare cuvant pe rand 
		add esp, 16
		cmp eax, 1 ; nr elemente scantate >1 (coditie de repetite pt  whileloop2)
		jg executie2; daca conditia e adevarata se sare la executatea instructiuniilor din whileloop2
		
	jmp whileloop3
		executie3:
			push offset nr 
			push offset formatcompresie
			push offset cod
			call sscanf ;scanam in variabila nr, cheia continuta de sirul cod
			add esp, 12
			lungime cod
			
			cmp eax, 2
			jne sirsimplu ; dacam lungimea sirului cod!=2 atunci sarim la codsimpul (adica sirul nu contine semn de punctuatie la final)
			
			sub eax, 1
			xor ebx, ebx
			mov bl, cod[eax]
			mov [ebp-16], ebx; mutam in variabila ebp-16 semnul de punctuatie ce precedeaza cheia din cod
			
			xor esi, esi; folosim esi pt a parcurge sirul cuvinte
			xor edi, edi; folosim edi ca contor pentru fordecom2
			
			jmp fordecomp11; sarim la fordecom11 pt a verifica conditia pt fordecomp1
			fordecomp1:
				mov ebx, nr
				cmp ebx, cuvinte[esi].key ; comparam codul citit din fisierul comprimat pe rand cu fiecare key din dictionar
				jne incrementcomp1; trecem la incrementare contor, daca codul nu coincide cu cheia 
				lea ebx, cuvinte[esi].sir
				push [ebp-16]
				push ebx
				push offset formattext
				push [ebp-12]
				call fprintf; dacam cod==key atunci scriem cuvantul corespunzator codului in fisierul decomprimat
				add esp, 16
				incrementcomp1:
				add esi, 34
				inc edi
				fordecomp11:
				cmp edi, contor
				jl fordecomp1; edi<contor coditie pt fordecomp1
				jmp whileloop3; dupa terminarea instructiunilor de pe ramura if se sare la whileloop3
				
			sirsimplu:
				xor edi, edi; folosim edi ca contor pentru fordecom2
				xor esi ,esi; folosim esi pt a parcurge sirul cuvinte 
				jmp fordecomp22; sarim la fordecom22 pt a verifica conditia pt fordecomp2
				fordecomp2:
					mov ebx, nr
					cmp ebx, cuvinte[esi].key ; comparam codul citit din fisierul comprimat pe rand cu fiecare key din dictionar
					jne incrementcomp2; daca codul nu corespunde cu cheia actuala sarim la incrementare contorului, altfel continuam
					lea ebx, cuvinte[esi].sir
					push ebx
					push offset formattext2; scriem in fisierul cu text decomprimat sirul de caractere corespunzator chei 
					push [ebp-12]
					call fprintf; dacam cod==key atunci scriem cuvantul corespunzator codului in fisierul decomprimat
					add esp, 12
				incrementcomp2:
				inc edi
				add esi, 34
				fordecomp22:
				cmp edi, contor 
				jl fordecomp2 ;edi<contor conditie pt fordecomp2
					
					
	whileloop3:
		push offset cod ;variabila in care stocam un sir de caractere citit din fisierul comprimat ex: "1" sau "1."
		push offset formatscan
		push [ebp-4]
		call fscanf; citim prima cheia din fisierul cu text comprimat si eventual semnul ce urmeaza dupa ea in sirul cod
		add esp , 12
		cmp eax , 1; fscanf(text comprimat,"%s",cod)==1 condite pt whileloop3
		je executie3; daca conditia e adevarata se executa instructiunile din whileloop3
		
	;inchidem fisierele 
	push [ebp-4]
	call fclose
	add esp, 4
	push [ebp-8]
	call fclose
	add esp, 4
	push [ebp-12]
	call fclose
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret 4
decompresie endp

selectare macro nr ;aceste macro selecteaza ce operatie ce v-a executa in fuctie de comanda aleasea de utilizator
local inceput, optiunea2, optiunea3

	push ebx
inceput:
	push offset meniuformat
	call printf
	add esp, 4
	push offset nr
	push offset scanmeniu
	call scanf; se selecteaza operatia 
	add esp, 8
	
	mov ebx, nr
	cmp ebx, 1 
	jne optiunea2 ;daca nr(operatia selectata de utilizator) este 1 atunci se contiua, altfel se sare la operatia 2
	
	push offset mesaj
	call printf ; se afiseaza un mesaj care ii cere utilizatorului calea absoluta spre fisierul ce v-a fi comprimat
	add esp, 4
	
	push offset cale
	push offset formatscan
	call scanf ;se citeste calea spre fisierul ce trebuie comprimat
	add esp, 8
	
	push offset cale
	call compresie ; se apeleaza functia de comprimare a fiserului
	add esp, 4
	
optiunea2:
	mov ebx, nr
	cmp ebx, 2
	jne optiunea3; daca nr(operatia selectata de utilizator) este 2 atunci se contiua, altfel se sare la operatia 3
	
	push offset mesaj2
	call printf ; se afiseaza un mesaj care cere calea absoluta spre fisierul ce va fi decomprimat
	add esp, 4
	
	push offset cale
	push offset formatscan
	call scanf; se scaneaza calea spre fiserul ce va fi decomprimt
	add esp, 8
	
	push offset mesaj3
	call printf ;se afiseza un mesaj care cere calea absoluta  spre dictionarul corespunzator fisierului comprimat
	add esp, 4
	
	push offset cale2
	push offset formatscan ;se citeste calea spre dictionarul fiserul
	call scanf
	add esp, 8
	
	push offset cale2
	push offset cale
	call decompresie; se apleaza functia de decompresie
	add esp, 8

optiunea3: ;operatia 3=exit, se termina programul
	mov ebx, nr
	cmp ebx, 3
	jne inceput; daca nrmeniu nu e egal cu 3(exit) atunci se trece la selectarea unei noi operatii
	pop ebx
endm

start:
	selectare nrmeniu
	
	push 0
	call exit
	
end start