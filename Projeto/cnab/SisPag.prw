#include "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ sispag   ³ Autor ³ Anderson Rodrigues    ³ Data ³ 29/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera informacoes para arquivos sispag de tributos e        |±±
±±³          | pagto de fornecedores                                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para ICTS		                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SisPag(cOpcao)

Local cReturn   := ""
Local nReturn   := 0
Local cAgencia  := " "
Local cNumCC    :=" " 
Local cDVAgencia:= " "
Local cDVNumCC  := " "


If cOpcao == "1"    // obter numero de conta e agencia

    cAgencia :=  Alltrim(SA2->A2_AGENCIA)
/*
   If AT("-",cAgencia) > 0
      cAgencia := Substr(cAgencia,1,AT("-",cAgencia)-1)
   Endif
*/
 

// Obtem o digito da agencia

    cDVAgencia :=  Alltrim(SA2->A2_DVAGE)
/*
   If AT("-",cDVAgencia) > 0
     cDVAgencia := Substr(cDVAgencia,AT("-",cDVAgencia)+1,1)
   Else
     cDVAgencia := Space(1)
   Endif
*/

// Obtem o numero da conta corrente

   cNumCC :=  Alltrim(SA2->A2_NUMCON)
/*        
   If AT("-",cNumCC) > 0
     cNumCC := Substr(cNumCC,1,AT("-",cNumCC)-1)
   Endif
*/

// obtem o digito da conta corrente

   cDVNumCC :=  Alltrim(SA2->A2_DVCTA)
/*  
   If AT("-",cDVNumCC) > 0
     cDVNumCC := Substr(cDVNumCC,AT("-",cDVNumCC)+1,2)
   Else
     cDVNumCC := Space(1)
   Endif
*/
		
	
	If SA2->A2_BANCO == "341"  // se for o próprio Itaú - credito em C/C
		
		nReturn:= "0"+cAgencia+space(1)+Replicate("0",7)+cNumCC+space(1)+cDVNumCC
		
	Else  // para os outros bancos - DOC
		
		If Len(Alltrim(cDvNumCC)) > 1
			nReturn:= StrZero(Val(cAgencia),5)+space(1)+StrZero(val(cNumCC),12)+cDvNumCC
		Else
			nReturn:= StrZero(Val(cAgencia),5)+space(1)+StrZero(val(cNumCC),12)+space(1)+cDvNumCC
		EndIf
		
	EndIf
	
ElseIf cOpcao == "2"  // valor a pagar
	
	_nVlTit:= SE2->E2_SALDO+SE2->E2_ACRESC-(SE2->E2_DECRESC)    
	
	nReturn := Strzero((_nVlTit * 100),15)
	
ElseIf  cOpcao == "3"  // Verifica o DV Geral
	
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,33,1)
	Else
		nReturn:= Substr(SE2->E2_CODBAR,5,1)
	EndIf
	
ElseIf  cOpcao == "4"       // FATOR DE VENCIMENTO
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,34,4)
	Else
		nReturn:= Substr(SE2->E2_CODBAR,6,4)
	EndIf
	
ElseIf  cOpcao == "5"       // Valor constante do codigo de barras
	
  If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nValor := Substr(SE2->E2_CODBAR,38,10)
	Else
		nValor := Substr(SE2->E2_CODBAR,10,10)
  EndIf
		
	nReturn := Strzero(Val(nValor),10)
	
ElseIf  cOpcao == "6"       // Campo Livre
	
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+;
		Substr(SE2->E2_CODBAR,22,10)
	Else
		nReturn := Substr(SE2->E2_CODBAR,20,25)
	EndIf
	
ElseIf cOpcao == "7"  // pagamento de tributos

If SEA->EA_MODELO $ "16/18" //Darf Normal / Darf Simples
	     
		cTributo	:= Iif(SEA->EA_MODELO=="16","02","03")					//018-019 - 02 = DARF Normal / 03 = DARF Simples
		cCodRec		:=  SUBSTR(SE2->E2_CODREC,1,4)										//020-023
		cTpInscr 	:= "2"                     			 				            	//024-024 - 1 = CPF / 2 = CNPJ
		cCNPJ		:= StrZero(Val(SM0->M0_CGC),14)						//025-038
		dPeriodo	:= GravaData(SE2->E2_E_APUR,.F.,5)						//039-046 - DDMMAAAA
		cReferen	:= Replicate("0",17-Len(AllTrim(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)))) + AllTrim(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA))		//047-063
		nValor		:= StrZero(SE2->E2_VLCRUZ*100,14)						//064-077
		nValorMult	:=  REPL("0",14)                                              	//078-091
        //nValorMult	:= STRZERO(SE2->E2_ACRESC*100,14)                                              	//078-091		
		nValorJuros := STRZERO(SE2->E2_ACRESC*100,14)						//092-105
		nValor		:= STRZERO(SE2->E2_VLCRUZ*100,14)	           	//106-119   
		dVencto	:= GRAVADATA(SE2->E2_VENCREA,.F.,5) 						//120-127 - DDMMAAAA  
		dDtPagto	:= GRAVADATA(SE2->E2_VENCREA,.F.,5) 					//128-135 - DDMMAAAA
		cBrancos	:= space(30)										               	//136-165
		cContrib	:= Substr(SM0->M0_NOMECOM,1,30)						//166-195
		
		nReturn:= cTributo + cCodRec +  cTpInscr + (cCNPJ) + dPeriodo + Padr(cReferen,17)+(nValor)+(nValorMult)+(nValorJuros)+;
		                  (nValor) + dVencto + dDtPagto + cBrancos + cContrib
	
	ElseIf SEA->EA_MODELO == "17" // GPS
	
		cTributo	:= "01"																//018-019 - 01 = GPS
		cCodRec	:=  SUBSTR(SE2->E2_CODREC,1,4)														//020-023
		dPeriodo	:=  StrZero(MONTH(SE2->E2_E_APUR),2)+STR(YEAR(SE2->E2_E_APUR),4)	//024-029 - MMAAAA
		cCNPJ		:= Posicione("SM0",1,"01"+xFilial("SE2"),"M0_CGC")                    				//030-043 
		nVlrTri		:= STRZERO(SE2->E2_VALOR*100,14)				//044-057
		nVlrEnt		:=  STRZERO(SE2->E2_ACRESC*100,14) 									//058-071
		nValorMult	:=  STRZERO(SE2->E2_JUROS*100,14)										//072-085
//		nVlrArrec	:= STRZERO(SE2->E2_VLCRUZ*100,14)					//086-099
		nVlrArrec	:= STRZERO((SE2->(E2_SALDO+E2_ACRESC)*100),14) // 086-099
		dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)								//100-107 - DDMMAAAA
		cBrancos	:= space(8)															//108-115
		cInfoComp	:= space(50)														//116-165
		cContrib	:= Substr(SM0->M0_NOMECOM,1,30)                    				//166-195
		
		nReturn:= cTributo + cCodRec + dPeriodo	+ cCNPJ	+ nVlrTri + nVlrEnt + nValorMult + nVlrArrec + dDtPagto	 + cBrancos	+ cInfoComp	+ cContrib
	
	ElseIf SEA->EA_MODELO == "22" // GARE -> Deve-se criar esse modelo 22 - GARE - SP ICMS na tabela 58 do SX5
	
		cTributo	:= "05"																//018-019 - 05 = ICMS
		cCodRec	:= SUBSTR(SE2->E2_CODREC,1,4)													//020-023
		cTpInscr 	:= "2"                     											//024-024 - 1 = CPF / 2 = CNPJ
		cCNPJ		:= SUBSTR(SM0->M0_CGC,1,14)									//025-038
		cInsEst		:= SUBSTR(SM0->M0_INSC,1,12)														//039-050
		cDivAtiv  	:=STRZERO(VAL(SE2->E2_E_DIVID),13)													//051-063 //Verificar ??
		dPeriodo	:= STRZERO(MONTH(SE2->E2_E_APUR),2)+STR(YEAR(SE2->E2_E_APUR),4)	//064-069 - MMAAAA
		cParcNot	:= space(13)														//070-082 //Verificar ???
		nVlrRec		:= StrZero((SE2->E2_SALDO*100),14)								//083-096
		nValorJuro	:= STRZERO(SE2->E2_ACRESC*100,14)									//097-110
		nValorMult	:= REPL("0",14)                                                      				//111-124
		nValor		:= STRZERO((SE2->E2_VLCRUZ*100),14)					//125-138
		dVencto	:= GravaData(SE2->E2_VENCREA,.F.,5)										//139-146 - DDMMAAAA
		dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)								//147-154 - DDMMAAAA
	    cCnae		:= SubStr(SM0->M0_CNAE,1,5)										//155-159
		cBrancos	:= space(6)															//160-165
		cContrib	:= Substr(SM0->M0_NOMECOM,1,30)									//166-195
		
		nReturn:= cTributo + cCodRec +  cTpInscr + cCNPJ + cInsEst + cDivAtiv + dPeriodo + cParcNot + nVlrRec + nValorJuros + nValorMult +;
		nValor + dVencto + dDtPagto + cCnae + cBrancos + cContrib
	
	  ElseIf SEA->EA_MODELO == "35" // FGTS
	
		cTributo	:= "11"																//018-019 - 01 = FGTS
		cCodRec		:= Substr(SE2->E2_CODREC,1,4)													//020-023
		cTpInscr 	:= "2"                     											//024-024 - 1 = CPF / 2 = CNPJ
		cCNPJ		:= StrZero(Val(SM0->M0_CGC),14)                     				//030-043 
		nCodbar		:= SE2->E2_CODBAR													//039-086
		nIdent		:= SE2->E2_IDENT													//087-102
		nLacre		:= SE2->E2_LACRE													//103-111
		nDglacre	:= SE2->E2_DGLACR													//112-113
		cContrib	:= Substr(SM0->M0_NOMECOM,1,30)                    					//114-143
		dDtPagto	:= GravaData(SE2->E2_VENCREA,.F.,5)							   		//144-151 - DDMMAAAA
		nVlrArrec	:= STRZERO((SE2->E2_SALDO)*100,14)									//152-165
		cBrancos	:= space(30)														//166-195
				
		nReturn:= cTributo + cCodRec + cTpInscr	+ cCNPJ	+ nCodbar + nIdent + nLacre + nDglacre + cContrib + dDtPagto + nVlrArrec + cBrancos
	
	EndIf
	
ElseIf  cOpcao == "8"       // Valor nominal
	
  If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nValor := Substr(SE2->E2_CODBAR,38,10)
	Else
		nValor := Substr(SE2->E2_CODBAR,10,10)
  EndIf
  
	If Val(nValor) > 0	
	   nReturn := Strzero(Val(nValor*100),15)
	Else 
		nReturn:= Strzero(SE2->E2_SALDO*100,15)   
    EndIf

ElseIf  cOpcao == "9"       // Fator de Vencimento e Valor pelo codigo de barras opcao 4 e 5 juntas
    //Fator de Vencimento
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nReturn := Substr(SE2->E2_CODBAR,34,4)
	Else
		nReturn:= Substr(SE2->E2_CODBAR,6,4)
	EndIf
	
  //Valor codigo de barras
  If Len(Alltrim(SE2->E2_CODBAR)) > 44
		nValor := Substr(SE2->E2_CODBAR,38,10)
	Else
		nValor := Substr(SE2->E2_CODBAR,10,10)
  EndIf
		
	nReturn := Strzero(Val(nReturn),4)+Strzero(Val(nValor),10)
    	 
EndIf

Return(nReturn)     