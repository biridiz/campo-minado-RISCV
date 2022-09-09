# LUIZ ROBERTO DENDENA - 17211010127
		.data
campo:				.space		576   # esta versão suporta campo de até 12 x 12 posições de memória
salva_S0:			.word		0
salva_ra:			.word		0
salva_ra1:			.word		0

str_nova_linha:			.asciz		"\n"
str_tamanho_campo:		.asciz		"Tamanho do tabuleiro:\n"
str_op_tamanho_campo:	.asciz		"(1)- Hard 8x8\n(2)- Medium 10x10\n(3)- Easy 12x12\n(0)- Sair\n"
str_simbolo_traco:		.asciz		" - "
str_flag:				.asciz		" F "
str_bomba:				.asciz		" B "

str_menu_jogadas:		.asciz		"Menu de jogadas:\n"
str_op_jogadas:			.asciz		"(1)- Para abrir uma posição\n(2)- Para inserir uma bandeira\n(3)- Para remover uma bandeira\n(0)- Sair\n"
str_ler_linha:			.asciz		"Linha: "
str_ler_coluna:			.asciz		"Coluna: "
str_game_over:			.asciz		"\n\n   **** CABUUMMMM ****\n   Você é meio ruinzin né\n   Tente novamente\n\n"

str_op_invalida:		.asciz		"Opção inválida\n"

str_espaco_em_branco:	.asciz		" "

		.text
	
main:
		jal		menu_interface
		
		la 		a0, campo		# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		jal		inicializa_matriz
	
		la 		a0, campo		# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		jal		INSERE_BOMBA
	
		la 		a0, campo		# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		jal 	calcula_bombas
		
		jal 	menu_jogadas
	
		nop
		
sair:
		li		a7, 93
		add 	a0, t0, zero
		ecall
		

#######################################
## INICIALIZA TODAS AS POSIÇÕES COM 0 #
#######################################	
inicializa_matriz:
		# calcula tamanho do campo de acordo com a entrada
		mul		t0, a1, a1
		li		t1, 4
		mul		t2, t0, t1   # tamanho do campo
		add		t0, a0, zero # endereco inicial do campo
	
percorre_campo_inicializa:
		beq		t2, zero, fim_percorre_campo_inicializa
	
		# insere 0
		li 		t3, 0
		sw 		t3, 0(t0)
		
		# atualiza contaderes e indices 
		addi	t0, t0, 4
		addi	t2, t2, -4
		j 		percorre_campo_inicializa

fim_percorre_campo_inicializa:
		ret
		

#######################################
####### MENU INICIAL DO JOGO ##########
#######################################
menu_interface:	
		# imprime texto de entrada
		li		a7, 4
		la		a0, str_tamanho_campo
		ecall	
		# imprime opcoes de tamanho
		li		a7, 4
		la		a0, str_op_tamanho_campo
		ecall
		# le o tamanho do tabuleiro
		li		a7, 5
		add 	a0, t0, zero
		ecall
		
		li		t0, 1
		li		t1, 2
		li		t2, 3
		beq		a0, zero, sair
		beq		a0, t0, define_tamanho_8
		beq		a0, t1, define_tamanho_10
		beq		a0, t2, define_tamanho_12
		
		# senao imprime mensagem de erro e chama a funcao novamente
		li		a7, 4
		la		a0, str_op_invalida
		ecall
		
		j		menu_interface

define_tamanho_8:
		addi	a3, zero, 8
		ret
		
define_tamanho_10:
		addi	a3, zero, 10
		ret
		
define_tamanho_12:
		addi	a3, zero, 12
		ret


#######################################
## INSERÇÃO DE BOMBAS NO TABULEIRO ####
#######################################
INSERE_BOMBA:
		la		t0, salva_S0
		sw  	s0, 0 (t0)			# salva conteudo de s0 na memoria
		la		t0, salva_ra
		sw  	ra, 0 (t0)			# salva conteudo de ra na memoria
		
		add 	t0, zero, a0		# salva a0 em t0 - endereço da matriz campo
		add 	t1, zero, a1		# salva a1 em t1 - quantidade de linhas 

QTD_BOMBAS:
		addi 	t2, zero, 15 		# seta para 15 bombas	
		add 	t3, zero, zero 		# inicia contador de bombas com 0
		addi 	a7, zero, 30 		# ecall 30 pega o tempo do sistema em milisegundos (usado como semente
		ecall 				
		add 	a1, zero, a0		# coloca a semente em a1
INICIO_LACO:
		beq 	t2, t3, FIM_LACO
		add 	a0, zero, t1 		# carrega limite para %	(resto da divisão)
		jal 	PSEUDO_RAND
		add 	t4, zero, a0		# pega linha sorteada e coloca em t4
		add 	a0, zero, t1 		# carrega limite para % (resto da divisão)
   		jal 	PSEUDO_RAND
		add 	t5, zero, a0		# pega coluna sorteada e coloca em t5

LE_POSICAO:	
		mul  	t4, t4, t1
		add  	t4, t4, t5  		# calcula (L * tam) + C
		add  	t4, t4, t4  		# multiplica por 2
		add  	t4, t4, t4  		# multiplica por 4
		add  	t4, t4, t0  		# calcula Base + deslocamento
		lw   	t5, 0(t4)   		# Le posicao de memoria LxC
VERIFICA_BOMBA:		
		addi 	t6, zero, 9			# se posição sorteada já possui bomba
		beq  	t5, t6, PULA_ATRIB	# pula atribuição 
		sw   	t6, 0(t4)			# senão coloca 9 (bomba) na posição
		addi 	t3, t3, 1			# incrementa quantidade de bombas sorteadas
PULA_ATRIB:
		j		INICIO_LACO

FIM_LACO:						# recupera registradores salvos
		la		t0, salva_S0
		lw  	s0, 0(t0)		# recupera conteudo de s0 da memória
		la		t0, salva_ra
		lw  	ra, 0(t0)		# recupera conteudo de ra da memória		
		jr 		ra					# retorna para funcao que fez a chamada

PSEUDO_RAND:
		addi 	t6, zero, 125  		# carrega constante t6 = 125
		lui  	t5, 682			# carrega constante t5 = 2796203
		addi 	t5, t5, 1697 		# 
		addi 	t5, t5, 1034 		# 	
		mul  	a1, a1, t6			# a = a * 125
		rem  	a1, a1, t5			# a = a % 2796203
		rem  	a0, a1, a0			# a % lim
		bge  	a0, zero, EH_POSITIVO  	# testa se valor eh positivo
		addi 	s2, zero, -1           	# caso não 
		mul  	a0, a0, s2		    		# transforma em positivo
EH_POSITIVO:	
		ret				# retorna em a0 o valor obtidO


#######################################
## CALCULA NÚMERO DE BOMBAS PRÓXIMAS ##
#######################################
calcula_bombas:
		la		t0, salva_S0
		sw  	s0, 0 (t0)			# salva conteudo de s0 na memoria
		la		t0, salva_ra
		sw  	ra, 0 (t0)			# salva conteudo de ra na memoria
		
		# calcula tamanho do campo de acordo com a entrada
		mul	 	t0, a1, a1
		addi 	t1, zero, 4
		mul	 	a2, t0, t1 			# tamanho do campo
	
		add		t0, a0, zero 		# endereco inicial do campo
		add		s0, a0, zero 		# endereco inicial do campo (estático) usado para deslocamento
		add 	t1, a2, zero 		# indice com tamanho do campo
	
		li 		t2, 0 # linha
		li 		t3, 0 # coluna

percorre_campo_calcula_bombas:
		beq 	t1, zero, fim_percorre_campo_calcula_bombas
		beq		t3, a3, proxima_linha
	
		lw 		t5, 0(t0)				# carrega o valor da posição na matriz[i]
		li 		t4, 9					# se for igual a 9
		beq 	t5, t4, calcular		# calcula para as posições no entorno da bomba
	
		addi	t3, t3, 1				# incrementa coluna
		addi	t0, t0, 4				# avança posição na matriz
		addi	t1, t1, -4				# decrementa índice
	
		j percorre_campo_calcula_bombas
		
proxima_linha:
		addi	t2, t2, 1				# incrementa linha
		add 	t3, zero, zero		    # rst coluna
		addi	t0, t0, 4				# avança posição na matriz
		addi	t1, t1, -4				# decrementa índice
	
		j percorre_campo_calcula_bombas
		
fim_percorre_campo_calcula_bombas:
		la		t0, salva_S0
		lw  	s0, 0(t0)		# recupera conteudo de s0 da memória
		la		t0, salva_ra
		lw  	ra, 0(t0)		# recupera conteudo de ra da memória		
		jr 		ra					# retorna para funcao que fez a chamada
	
calcular:
		nop
		
calcula_linha_atual:
		mul		t5, t2, a3 		# Linha x Numero de total colunas
		jal		insere_esquerda
		mul		t5, t2, a3 		# Linha x Numero de total colunas
		jal		insere_direita
		
calcula_linha_de_cima:
		beq  	t2, zero, calcula_linha_de_baixo	# esta na primeira linha
		
		addi 	t4, t2, -1 		# Linha - 1
		mul		t5, t4, a3 		# Nova Linha x Numero de total colunas
		jal		insere_meio
		addi 	t4, t2, -1 		# Linha - 1
		mul		t5, t4, a3 		# Nova Linha x Numero de total colunas
		jal		insere_esquerda
		addi 	t4, t2, -1 		# Linha - 1
		mul		t5, t4, a3 		# Nova Linha x Numero de total colunas
		jal		insere_direita
		
calcula_linha_de_baixo:
		addi	t4, a3, -1
		beq  	t2, t4, avanca 	# esta na ultima linha
		
		addi 	t4, t2, 1 		# Linha + 1
		mul		t5, t4, a3 		# Nova Linha x Numero de total colunas
		jal		insere_meio
		addi 	t4, t2, 1 		# Linha + 1
		mul		t5, t4, a3 		# Nova Linha x Numero de total colunas
		jal		insere_esquerda
		addi 	t4, t2, 1 		# Linha + 1
		mul		t5, t4, a3 		# Nova Linha x Numero de total colunas
		jal		insere_direita
		
avanca:
		addi	t3, t3, 1
		addi	t0, t0, 4
		addi	t1, t1, -4
		j 		percorre_campo_calcula_bombas

insere_meio:
		add 	t6, t5, t3		# + Coluna atual
		j		incrementa
		
insere_direita:
		addi	t6, a3, -1		# ajusta para matriz inicada em 0x0
		beq		t3, t6, voltar 	# se a coluna é a ultima retorna
		addi	t6, t3, 1		# senão
		add 	t6, t5, t6		# + Coluna atual + 1
		j		incrementa
		
insere_esquerda:
		beq		t3, zero, voltar # se é a primeira coluna retorna
		addi	t6, t3, -1		# senão
		add 	t6, t5, t6		# + Coluna atual - 1
		j		incrementa
		
incrementa:
		li  	t4, 4			# multĺica por 4
		mul		t6, t6, t4		# para econtrar endereço
		add		t6, t6, s0		# + deslocamento
		lw   	t5, 0(t6)   	# Le posicao de memoria LxC
		li 		t4 , 9			# se posição sorteada possui bomba
		beq  	t5, t4, voltar	# pula atribuição 
		addi	t5, t5, 1		# senão
		sw   	t5, 0(t6)		# incrementa 1
		ret

voltar:
		ret
		

#######################################
###### MENU PRINCIPAL DO JOGO #########
#######################################
menu_jogadas:
		# imprime texto de entrada
		li		a7, 4
		la		a0, str_menu_jogadas
		ecall
	
		li		a7, 4
		la		a0, str_op_jogadas
		ecall
	
		# le a jogada
		li		a7, 5
		add 	a0, t0, zero
		ecall
	
		li 		t0, 1
		li 		t1, 2
		li		t2, 3
		li		t3, 0
		beq		t0, a0, abrir_posicao
		beq		t1, a0, inserir_bandeira
		beq		t2, a0, remover_bandeira
		beq		t3, a0, sair
		
		# senao imprime mensagem de erro e chama a funcao novamente
		li		a7, 4
		la		a0, str_op_invalida
		ecall
		
		j		menu_jogadas
	
abrir_posicao:
		jal		ler_jogada
		jal		encontra_posicao
		
		lw 		t5, 0(a0) 				# carrega o valor matriz[i]
		
		li 		t6, 9					# se o valor é 9 possui bomba
		beq 	t5, t6, game_over
		
		li		t6, 10					# se o valor é 10, tem bandeira entao nao deve permitir abrir posicao
		beq		t5, t6, imprime_opcao_invalida
		
		# se for zero add -100 para abrir
		beq 	t5, zero, abrir_o_zero
		# senao
		
abrir_numero_maior_que_zero:
		li		t6, -2			# multiplica por -2
		lw 		t5, 0(a0)
		mul		t4, t6, t5
		add		t6, t4, t5		# diminui pelo valor da posicao
		sw		t6, 0(a0)		# grava o numero negativo
		
		la 		a0, campo	# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		j		mostra_campo
		
abrir_o_zero:
		li 		t5, -100
		sw		t5, 0(a0)
		
		la 		a0, campo	# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		j		mostra_campo
		
imprime_opcao_invalida:
		li		a7, 4
		la		a0, str_op_invalida
		ecall
		j		menu_jogadas
	
inserir_bandeira:
		jal		ler_jogada
		jal		encontra_posicao
		# atribui o valor 10 na posição
		li		t5, 10		
		sw		t5, 0(a0)
		
		la 		a0, campo	# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		j		mostra_campo
	
remover_bandeira:
		jal		ler_jogada
		jal		encontra_posicao
		# atribui o valor 0 na posição
		li		t5, 0
		sw		t5, 0(a0)
		
		la 		a0, campo	# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
		j		mostra_campo
	
ler_jogada:
		li		a7, 4				# le a linha
		la		a0, str_ler_linha
		ecall
		li		a7, 5
		add 	a0, t0, zero
		ecall
		# se for menor que 1 ou maior que a3 jogada invalida
		li		t0, 1
		blt		a0, t0, fora_do_alcance_da_matriz
		bgt		a0, a3, fora_do_alcance_da_matriz
		# senao atribui
		add		a5, a0, zero
	
		li		a7, 4				# le a coluna
		la		a0, str_ler_coluna
		ecall
		li		a7, 5
		add 	a0, t0, zero
		ecall
		# se for  menor que 1 ou maior que a3 jogada invalida
		li		t0, 1
		blt		a0, t0, fora_do_alcance_da_matriz
		bgt		a0, a3, fora_do_alcance_da_matriz
		# senao atribui
		add		a6, a0, zero 
		
		ret
		
fora_do_alcance_da_matriz:
		li		a7, 4
		la		a0, str_op_invalida
		ecall
		j		ler_jogada

encontra_posicao:
		la 		t0, campo	# endereço inicial do campo	
		addi	a5,	a5, -1	# decrementa para trabalhar com indices inciados em 0
		addi	a6, a6, -1
	
		addi 	t2, a5, -1 # decrementa numero de linha
		mul	 	t3, a5, a3 # multiplica linha por total de coluna
		add  	t4, t3, a6 # + coluna (encontra posicao)
		
		li		t1, 4		# multiplica por
		mul		t1,	t4, t1	# 4
		add		a0,	t0, t1	# + deslocamento
	
		ret


###########################################
# IMPRESSÃO DO TABULEIRO APÓS CADA JOGADA #
###########################################
mostra_campo:
		# calcula tamanho do campo de acordo com a entrada
		mul		t0, a1, a1
		addi	t1, zero, 4
		mul		a2, t0, t1 # tamanho do campo
	
		add		t0, a0, zero # endereco inicial do campo
		add 	t1, a1, zero # numero de linhas do campo
		add 	t2, a2, zero # tamanho do campo
		add		t3, zero, zero # indice para dividir linhas e colunas
	
percorre_campo_imprime:
		# percorre o campo e faz a substituição para as strings que devem ser impressas na interface
		beq		t2, zero, fim_percorre_campo_imprime
		beq		t3, t1, imprime_nova_linha
	
		# se matriz[i] == 10 imprime bandeira
		li 		t6, 10
		lw 		t5, 0(t0)
		beq 	t5, t6, imprime_flag
		
		# se matriz[i] == -100 imprime 0
		li 		t6, -100
		lw 		t5, 0(t0)
		beq 	t5, t6, imprime_zero
		
		# se matriz[i] < 0 imprime (matriz[i] * (-2)) + matriz[i]
		lw 		t5, 0(t0)
		blt 	t5, zero, imprime
	
		# imprime saida padrão para casas não exploradas
		li		a7, 4
		la		a0, str_simbolo_traco
		ecall
		
		# atualiza contaderes e indices 
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_imprime

fim_percorre_campo_imprime:
		li		a7, 4
		la		a0, str_nova_linha
		ecall
	
		j 		menu_jogadas
	
imprime_nova_linha:
		li		a7, 4
		la		a0, str_nova_linha
		ecall
		add		t3, zero, zero
		j 		percorre_campo_imprime
	
imprime_flag:
		li		a7, 4
		la		a0, str_flag
		ecall
	
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_imprime
		
imprime_zero:
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		li		a7, 1
		li		a0, 0
		ecall
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
	
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_imprime
		
imprime:
		li		t6, -2
		mul		t4, t6, t5
		add		t6, t4, t5
		
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		li		a7, 1
		add		a0, zero, t6
		ecall
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_imprime
	

#######################################
#### IMPRESSÃO FINAL DO TABULEIRO #####
#######################################
game_over:
		li		a7, 4
		la		a0, str_nova_linha
		ecall
		
mostra_campo_game_over:
		la 		a0, campo	# endereço inicial do campo
		add		a1, a3, zero	# quantidade de linhas do campo
	
		# calcula tamanho do campo de acordo com a entrada
		mul		t0, a1, a1
		addi	t1, zero, 4
		mul		a2, t0, t1 # tamanho do campo
	
		add		t0, a0, zero # endereco inicial do campo
		add 	t1, a1, zero # numero de linhas do campo
		add 	t2, a2, zero # tamanho do campo
		add		t3, zero, zero # indice para dividir linhas e colunas
		
percorre_campo_game_over_imprime:
		# percorre o campo e faz a substituição para as strings que devem ser impressas na interface
		beq		t2, zero, fim_percorre_campo_game_over_imprime
		beq		t3, t1, imprime_nova_linha_game_over
		
		# tratar zero que já havia sido aberto antes
		li 		t6, -100
		lw 		t5, 0(t0)
		beq 	t5, t6, imprime_zero_game_over
		
		# tratar outro número que já havia sido aberto
		lw 		t5, 0(t0)
		blt 	t5, zero, imprime_game_over
		
		# tratar impressão de bandeiras
		li 		t6, 10
		lw 		t5, 0(t0)
		beq 	t5, t6, imprime_flag_game_over
		
		# tratar impressão de bombas
		li 		t6, 9
		lw 		t5, 0(t0)
		beq 	t5, t6, imprime_bomba_game_over
		
		# imprime restante da matriz
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		lw		t6, 0(t0)
		li		a7, 1
		add		a0, zero, t6
		ecall
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		
		# atualiza contadores e índices
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_game_over_imprime
		
imprime_nova_linha_game_over:
		li		a7, 4
		la		a0, str_nova_linha
		ecall
		add		t3, zero, zero
		j 		percorre_campo_game_over_imprime
		
fim_percorre_campo_game_over_imprime:
		li		a7, 4
		la		a0, str_nova_linha
		ecall
		li		a7, 4
		la		a0, str_game_over
		ecall
	
		j	 	main
	
imprime_zero_game_over:
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		li		a7, 1
		li		a0, 0
		ecall
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
	
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_game_over_imprime
		
imprime_game_over:
		li		t6, -2
		mul		t4, t6, t5
		add		t6, t4, t5
		
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		li		a7, 1
		add		a0, zero, t6
		ecall
		li		a7, 4
		la		a0, str_espaco_em_branco
		ecall
		
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_game_over_imprime
		
imprime_flag_game_over:
		li		a7, 4
		la		a0, str_flag
		ecall
	
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_game_over_imprime
		
imprime_bomba_game_over:
		li		a7, 4
		la		a0, str_bomba
		ecall
	
		addi	t0, t0, 4
		addi	t2, t2, -4
		addi	t3, t3, 1
		j 		percorre_campo_game_over_imprime

